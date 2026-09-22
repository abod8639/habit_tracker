import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _userId != null;

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
        }
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
      final habits = snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();

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
      for (var id in localTombstones) {
        await deleteHabit(id);
      }

      // 3. Parallel Download (Habits and Deleted Tombstones)
      final results = await Future.wait([
        downloadHabits(),
        _deletedHabitsCollection!.get(),
      ]);

      final List<HabitModel> cloudHabits = results[0] as List<HabitModel>;
      final QuerySnapshot deletedSnapshot = results[1] as QuerySnapshot;
      
      final deletedHabitsMap = {for (var doc in deletedSnapshot.docs) doc.id: true};
      final localMap = {for (var h in localHabits) h.id: h};
      final cloudMap = {for (var h in cloudHabits) h.id: h};

      // 4. Merge Logic (Last Write Wins)
      final mergedHabits = <HabitModel>[];
      final allIds = {...localMap.keys, ...cloudMap.keys};

      for (var id in allIds) {
        final local = localMap[id];
        final cloud = cloudMap[id];

        if (local == null) {
          mergedHabits.add(cloud!);
        } else if (cloud == null) {
          if (!deletedHabitsMap.containsKey(id)) {
            mergedHabits.add(local);
          }
        } else {
          final localTime = local.updatedAt ?? local.completedAt ?? local.createdAt;
          final cloudTime = cloud.updatedAt ?? cloud.completedAt ?? cloud.createdAt;

          mergedHabits.add(localTime.isAfter(cloudTime) ? local : cloud);
        }
      }

      // 5. Final State Upload
      await uploadHabits(mergedHabits, startDay: finalStartDay);

      return mergedHabits;
    } catch (e) {
      return localHabits; 
    }
  }

  // Delete a habit from Firestore (with Tombstone)
  Future<void> deleteHabit(String habitId) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();
      batch.delete(_habitsCollection!.doc(habitId));
      batch.set(_deletedHabitsCollection!.doc(habitId), {
        'deletedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      // Ignored
    }
  }

  // Upload habit history (Heatmap data)
  Future<void> uploadHabitHistory(String date, String completionRate) async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.collection('habitHistory').doc(date).set({
        'date': date,
        'completionRate': completionRate,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignored
    }
  }

  // Download habit history
  Future<Map<String, String>> downloadHabitHistory() async {
    if (!isUserLoggedIn) return {};

    try {
      final snapshot = await _userDoc!.collection('habitHistory').get();
      final Map<String, String> history = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'] as String?;
        final rate = data['completionRate'] as String?;
        if (date != null && rate != null) {
          history[date] = rate;
        }
      }
      return history;
    } catch (e) {
      return {};
    }
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
  Future<Map<String, String>> syncHabitHistory(
    Map<String, String> localHistory,
  ) async {
    if (!isUserLoggedIn) return localHistory;

    try {
      final cloudHistory = await downloadHabitHistory();
      final mergedHistory = {...localHistory, ...cloudHistory};

      for (var entry in localHistory.entries) {
        if (!cloudHistory.containsKey(entry.key)) {
          await uploadHabitHistory(entry.key, entry.value);
        }
      }

      return mergedHistory;
    } catch (e) {
      return localHistory;
    }
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
      final habitsSnapshot = await _habitsCollection!.get();
      for (var doc in habitsSnapshot.docs) {
        await doc.reference.delete();
      }

      final historySnapshot = await _userDoc!.collection('habitHistory').get();
      for (var doc in historySnapshot.docs) {
        await doc.reference.delete();
      }

      await _userDoc!.delete();
    } catch (e) {
      // Ignored
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
