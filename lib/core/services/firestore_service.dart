import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

class HabitHistoryCloudBundle {
  final Map<String, String> rates; // dateStr -> completionRate
  final Map<String, Map<String, bool>>
  completions; // dateStr -> {habitId: isCompleted}

  const HabitHistoryCloudBundle({
    this.rates = const {},
    this.completions = const {},
  });
}

class FirestoreService {
  final FirebaseFirestore? _firestoreInstance;
  final FirebaseAuth? _authInstance;

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestoreInstance = firestore,
       _authInstance = auth;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;

  String? get _userId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  // Check if user is logged in
  bool get isUserLoggedIn {
    try {
      return _userId != null;
    } catch (_) {
      return false;
    }
  }

  // Get user start day from cloud
  Future<String?> getUserStartDay() async {
    if (!isUserLoggedIn || _userDoc == null) return null;
    try {
      final userDoc = await _userDoc!.get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      return userData?['startDay'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Get user document reference
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // Get habits collection reference
  CollectionReference? get _habitsCollection {
    return _userDoc?.collection('habits');
  }

  // Get deleted habits collection reference
  CollectionReference? get _deletedHabitsCollection {
    return _userDoc?.collection('deleted_habits');
  }

  // Tombstone retention window (30 days) to prevent unbounded accumulation
  static const Duration tombstoneRetentionPeriod = Duration(days: 30);

  // Fetch only active tombstones within the retention window
  Future<QuerySnapshot?> _fetchActiveTombstones({
    Duration retention = tombstoneRetentionPeriod,
  }) async {
    if (!isUserLoggedIn || _deletedHabitsCollection == null) return null;

    try {
      final cutoff = Timestamp.fromDate(DateTime.now().subtract(retention));
      return await _deletedHabitsCollection!
          .where('deletedAt', isGreaterThanOrEqualTo: cutoff)
          .get();
    } catch (_) {
      try {
        return await _deletedHabitsCollection!.get();
      } catch (_) {
        return null;
      }
    }
  }

  /// Garbage collection: Purges tombstones older than the retention period from Firestore
  Future<void> cleanupExpiredTombstones({
    Duration retention = tombstoneRetentionPeriod,
  }) async {
    if (!isUserLoggedIn || _deletedHabitsCollection == null) return;

    try {
      final cutoff = Timestamp.fromDate(DateTime.now().subtract(retention));
      final expiredSnapshot = await _deletedHabitsCollection!
          .where('deletedAt', isLessThan: cutoff)
          .limit(100)
          .get();

      if (expiredSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in expiredSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error cleaning up expired tombstones: $e');
    }
  }

  // Upload habits and metadata to Firestore
  Future<void> uploadHabits(List<HabitModel> habits, {String? startDay}) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // 1. Update User Profile Metadata
      final userData = {
        'email': _auth.currentUser?.email,
        'displayName': _auth.currentUser?.displayName,
        'lastSync': timestamp,
        'metadata': {
          'platform': 'flutter',
          'lastAppVersion': '1.0.0', // Could be dynamic
        },
      };

      if (startDay != null) {
        userData['startDay'] = startDay;
      }

      batch.set(_userDoc!, userData, SetOptions(merge: true));

      // 2. Upload Habits using professional toFirestore()
      for (var habit in habits) {
        final habitDoc = _habitsCollection!.doc(habit.id);
        batch.set(habitDoc, habit.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Download habits from Firestore
  Future<List<HabitModel>> downloadHabits() async {
    if (!isUserLoggedIn) return [];

    try {
      final snapshot = await _habitsCollection!.get();
      final habits = snapshot.docs
          .map((doc) => HabitModel.fromFirestore(doc))
          .toList();

      // Sort by index for correct order across devices
      habits.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
      return habits;
    } catch (e) {
      rethrow;
    }
  }

  // Sync habits (smart merge)
  Future<List<HabitModel>> syncHabits(
    List<HabitModel> localHabits, {
    List<String> localTombstones = const [],
    String? localStartDay,
  }) async {
    if (!isUserLoggedIn) return localHabits;

    try {
      // 1. Fetch User Data (StartDay, etc.)
      final userDoc = await _userDoc!.get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final cloudStartDay = userData?['startDay'] as String?;
      final String? finalStartDay = cloudStartDay ?? localStartDay;

      // 2. Process Deletions (Tombstones)
      if (localTombstones.isNotEmpty) {
        await deleteHabits(localTombstones);
      }

      // 3. Parallel Download (Habits and Active Deleted Tombstones)
      final results = await Future.wait([
        downloadHabits(),
        _fetchActiveTombstones(),
      ]);

      final List<HabitModel> cloudHabits = results[0] as List<HabitModel>;
      final QuerySnapshot? deletedSnapshot = results[1] as QuerySnapshot?;

      final deletedHabitsMap = {
        if (deletedSnapshot != null)
          for (var doc in deletedSnapshot.docs) doc.id: true,
      };
      final localMap = {for (var h in localHabits) h.id: h};
      final cloudMap = {for (var h in cloudHabits) h.id: h};

      // 4. Merge Logic (Last Write Wins)
      final mergedHabits = <HabitModel>[];
      final allIds = {...localMap.keys, ...cloudMap.keys};

      for (var id in allIds) {
        final local = localMap[id];
        final cloud = cloudMap[id];

        if (local == null) {
          if (!deletedHabitsMap.containsKey(id)) {
            mergedHabits.add(cloud!);
          }
        } else if (cloud == null) {
          if (!deletedHabitsMap.containsKey(id)) {
            mergedHabits.add(local);
          }
        } else {
          final localTime =
              local.updatedAt ?? local.completedAt ?? local.createdAt;
          final cloudTime =
              cloud.updatedAt ?? cloud.completedAt ?? cloud.createdAt;

          mergedHabits.add(localTime.isAfter(cloudTime) ? local : cloud);
        }
      }

      // 5. Final State Upload
      await uploadHabits(mergedHabits, startDay: finalStartDay);

      // 6. Asynchronous Garbage Collection for expired tombstones (non-blocking)
      unawaited(cleanupExpiredTombstones());

      return mergedHabits;
    } catch (e) {
      return localHabits;
    }
  }

  // Delete multiple habits from Firestore (with Tombstones) in a single batch
  Future<void> deleteHabits(List<String> habitIds) async {
    if (!isUserLoggedIn || habitIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      for (final habitId in habitIds) {
        batch.delete(_habitsCollection!.doc(habitId));
        batch.set(_deletedHabitsCollection!.doc(habitId), {
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      // Ignored
    }
  }

  // Delete a habit from Firestore (with Tombstone)
  Future<void> deleteHabit(String habitId) async {
    await deleteHabits([habitId]);
  }

  // Upload individual habit completion or daily completion to Firestore
  Future<void> uploadHabitCompletion(
    String habitId,
    String date,
    bool isCompleted, {
    String? completionRate,
  }) async {
    if (!isUserLoggedIn) return;

    try {
      final docRef = _userDoc!.collection('habitHistory').doc(date);
      final updateData = <String, dynamic>{
        'date': date,
        'completions': {
          habitId: isCompleted,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (completionRate != null) {
        updateData['completionRate'] = completionRate;
      }
      await docRef.set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error uploading habit completion to Firestore: $e');
    }
  }

  // Upload habit history (Heatmap data + optional completions map)
  Future<void> uploadHabitHistory(
    String date,
    String completionRate, {
    Map<String, bool>? completions,
  }) async {
    if (!isUserLoggedIn) return;

    try {
      final data = <String, dynamic>{
        'date': date,
        'completionRate': completionRate,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (completions != null && completions.isNotEmpty) {
        data['completions'] = completions;
      }
      await _userDoc!
          .collection('habitHistory')
          .doc(date)
          .set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      // Ignored
    }
  }

  // Download comprehensive habit history bundle (both heatmap rates and per-habit completions)
  Future<HabitHistoryCloudBundle> downloadHabitHistoryBundle() async {
    if (!isUserLoggedIn) return const HabitHistoryCloudBundle();

    try {
      final snapshot = await _userDoc!.collection('habitHistory').get();
      final Map<String, String> rates = {};
      final Map<String, Map<String, bool>> completions = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'] as String? ?? doc.id;
        final rate = data['completionRate']?.toString();
        if (date.isNotEmpty && rate != null) {
          rates[date] = rate;
        }

        final rawComps = data['completions'];
        if (rawComps is Map) {
          final Map<String, bool> habitMap = {};
          rawComps.forEach((k, v) {
            habitMap[k.toString()] = v == true || v == 'true' || v == 1;
          });
          if (habitMap.isNotEmpty) {
            completions[date] = habitMap;
          }
        }
      }
      return HabitHistoryCloudBundle(
        rates: rates,
        completions: completions,
      );
    } catch (e) {
      debugPrint('Error downloading habit history bundle: $e');
      return const HabitHistoryCloudBundle();
    }
  }

  // Download habit history rates (Heatmap compatibility)
  Future<Map<String, String>> downloadHabitHistory() async {
    final bundle = await downloadHabitHistoryBundle();
    return bundle.rates;
  }

  // Theme Management
  Future<void> uploadTheme(
    String themeName,
    ThemeMode mode,
    bool useCustomBg,
    Color? customBgColor,
  ) async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.collection('settings').doc('theme').set({
        'themeName': themeName,
        'themeMode': mode.index, // Store index for easier parsing
        'useCustomBg': useCustomBg,
        'customBgColor': customBgColor?.toARGB32(), // Use modern method
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignored
    }
  }

  Future<Map<String, dynamic>?> downloadTheme() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _userDoc!.collection('settings').doc('theme').get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  // AI Settings Management
  Future<void> uploadCustomApiKey(String apiKey) async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.collection('settings').doc('ai').set({
        'apiKey': apiKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to upload custom API key to Firestore: $e');
    }
  }

  Future<String?> downloadCustomApiKey() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _userDoc!.collection('settings').doc('ai').get();
      if (doc.exists) {
        final data = doc.data();
        return data?['apiKey'] as String?;
      }
    } catch (e) {
      debugPrint('Failed to download custom API key from Firestore: $e');
    }
    return null;
  }

  Future<void> deleteCustomApiKey() async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.collection('settings').doc('ai').delete();
    } catch (e) {
      debugPrint('Failed to delete custom API key from Firestore: $e');
    }
  }

  // Sync full habit history including both daily rates and per-habit completions
  Future<HabitHistoryCloudBundle> syncHabitHistoryWithCompletions({
    required Map<String, String> localRates,
    required Map<String, Map<String, bool>> localCompletions,
  }) async {
    if (!isUserLoggedIn) {
      return HabitHistoryCloudBundle(
        rates: localRates,
        completions: localCompletions,
      );
    }

    try {
      final cloudBundle = await downloadHabitHistoryBundle();

      // Merge daily completion rates
      final mergedRates = Map<String, String>.from(localRates);
      for (var entry in cloudBundle.rates.entries) {
        if (!mergedRates.containsKey(entry.key)) {
          mergedRates[entry.key] = entry.value;
        }
      }

      // Merge per-habit completions
      final mergedCompletions = <String, Map<String, bool>>{};
      // 1. Seed with cloud completions
      for (var dateEntry in cloudBundle.completions.entries) {
        mergedCompletions[dateEntry.key] = Map<String, bool>.from(
          dateEntry.value,
        );
      }
      // 2. Merge local completions
      for (var dateEntry in localCompletions.entries) {
        final date = dateEntry.key;
        final localMap = dateEntry.value;
        if (!mergedCompletions.containsKey(date)) {
          mergedCompletions[date] = Map<String, bool>.from(localMap);
        } else {
          final targetMap = mergedCompletions[date]!;
          for (var habitEntry in localMap.entries) {
            targetMap.putIfAbsent(habitEntry.key, () => habitEntry.value);
          }
        }
      }

      // Collect items to upload to Cloud Firestore
      final allDates = {...mergedRates.keys, ...mergedCompletions.keys};
      final List<Map<String, dynamic>> updates = [];

      for (var date in allDates) {
        final cloudRate = cloudBundle.rates[date];
        final mergedRate = mergedRates[date];
        final cloudComps = cloudBundle.completions[date] ?? {};
        final mergedComps = mergedCompletions[date] ?? {};

        bool needsUpload = false;
        if (mergedRate != null && cloudRate != mergedRate) {
          needsUpload = true;
        }
        if (mergedComps.isNotEmpty) {
          for (var entry in mergedComps.entries) {
            if (cloudComps[entry.key] != entry.value) {
              needsUpload = true;
              break;
            }
          }
        }

        if (needsUpload) {
          updates.add({
            'date': date,
            'completionRate': ?mergedRate,
            if (mergedComps.isNotEmpty) 'completions': mergedComps,
          });
        }
      }

      // Batch upload history updates to avoid sequential requests
      if (updates.isNotEmpty) {
        for (var i = 0; i < updates.length; i += 400) {
          final chunk = updates.sublist(
            i,
            i + 400 > updates.length ? updates.length : i + 400,
          );
          final batch = _firestore.batch();
          for (var update in chunk) {
            final docRef = _userDoc!
                .collection('habitHistory')
                .doc(update['date'] as String);
            batch.set(
              docRef,
              {
                ...update,
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
          }
          await batch.commit();
        }
      }

      return HabitHistoryCloudBundle(
        rates: mergedRates,
        completions: mergedCompletions,
      );
    } catch (e) {
      debugPrint('Error syncing full habit history: $e');
      return HabitHistoryCloudBundle(
        rates: localRates,
        completions: localCompletions,
      );
    }
  }

  Future<Map<String, String>> syncHabitHistory(
    Map<String, String> localHistory,
  ) async {
    final bundle = await syncHabitHistoryWithCompletions(
      localRates: localHistory,
      localCompletions: const {},
    );
    return bundle.rates;
  }

  Future<DateTime?> getLastSyncTime() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _userDoc!.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final timestamp = data?['lastSync'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Stream<List<HabitModel>> listenToHabits() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _habitsCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> deleteAllUserData() async {
    if (!isUserLoggedIn) return;

    try {
      // 1. Delete habits in batch
      final habitsSnapshot = await _habitsCollection!.get();
      if (habitsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in habitsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 2. Delete habitHistory in batch
      final historySnapshot = await _userDoc!.collection('habitHistory').get();
      if (historySnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in historySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 3. Delete deleted_habits (tombstones) in batch
      if (_deletedHabitsCollection != null) {
        final tombstonesSnapshot = await _deletedHabitsCollection!.get();
        if (tombstonesSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in tombstonesSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      // 4. Delete settings in batch
      final settingsSnapshot = await _userDoc!.collection('settings').get();
      if (settingsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in settingsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 5. Delete root user document
      await _userDoc!.delete();
    } catch (e) {
      debugPrint('Error deleting all user data from Firestore: $e');
    }
  }

  // Save FCM Token to user document
  Future<void> saveFcmToken(String token) async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  // Remove FCM Token from user document
  Future<void> removeFcmToken() async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.set({
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to remove FCM token: $e');
    }
  }
}
