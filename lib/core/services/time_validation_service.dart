import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';

/// Represents the result of date & time validation.
class TimeValidationResult {
  final bool isTampered;
  final String? reason;
  final DateTime deviceTime;
  final DateTime? trustedTime;

  const TimeValidationResult({
    required this.isTampered,
    this.reason,
    required this.deviceTime,
    this.trustedTime,
  });

  factory TimeValidationResult.valid({
    required DateTime deviceTime,
    DateTime? trustedTime,
  }) {
    return TimeValidationResult(
      isTampered: false,
      deviceTime: deviceTime,
      trustedTime: trustedTime,
    );
  }

  factory TimeValidationResult.tampered({
    required String reason,
    required DateTime deviceTime,
    DateTime? trustedTime,
  }) {
    return TimeValidationResult(
      isTampered: true,
      reason: reason,
      deviceTime: deviceTime,
      trustedTime: trustedTime,
    );
  }
}

/// Service dedicated to detecting date/time manipulation or discrepancies.
/// Employs a multi-layered check:
/// 1. Trusted Network Time (Ground Truth) — Always checked first when online; can both catch
///    tampering and automatically heal/reset false historical timestamps.
/// 2. Local Monotonic Rollback check (backed by persistent KeyValueStorage, offline fallback).
/// 3. Database History Rollback check (verifies current date isn't prior to logged completions, offline fallback).
class TimeValidationService {
  static const String keyLastValidTimestampMs = 'LAST_VALID_TIMESTAMP_MS';
  static const Duration networkTolerance = Duration(minutes: 30);
  static const Duration rollbackTolerance = Duration(minutes: 5);

  final KeyValueStorage _storage;
  final AppDatabase _db;
  final http.Client? _httpClient;

  TimeValidationService({
    required KeyValueStorage storage,
    required AppDatabase db,
    http.Client? httpClient,
  }) : _storage = storage,
       _db = db,
       _httpClient = httpClient;

  /// Fast check for offline rollback detection.
  bool isClockRolledBackSynchronously() {
    final lastValidMs = _storage.getInt(keyLastValidTimestampMs);
    if (lastValidMs == null) return false;

    final currentDeviceMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    return currentDeviceMs < (lastValidMs - rollbackTolerance.inMilliseconds);
  }

  /// Full validation process. Returns [TimeValidationResult].
  Future<TimeValidationResult> validateTime() async {
    final nowDevice = DateTime.now();
    final nowDeviceUtc = nowDevice.toUtc();
    final currentDeviceMs = nowDeviceUtc.millisecondsSinceEpoch;

    // ─────────────────────────────────────────────────────────────────────────
    // LAYER 1: TRUSTED NETWORK CHECK (Absolute Authority when Online)
    // ─────────────────────────────────────────────────────────────────────────
    final networkUtc = await _fetchNetworkUtcTime();
    if (networkUtc != null) {
      final diff = (nowDeviceUtc.difference(networkUtc)).abs();
      if (diff > networkTolerance) {
        debugPrint(
          'TimeValidationService: Network time mismatch. Diff: ${diff.inMinutes}m, Device: $nowDeviceUtc, Network: $networkUtc',
        );
        return TimeValidationResult.tampered(
          reason: 'Device clock does not match network time',
          deviceTime: nowDevice,
          trustedTime: networkUtc.toLocal(),
        );
      }

      // Valid network time confirmed! The device's clock is 100% genuine right now.
      // HEAL the stored timestamp to this verified network time.
      await _storage.setInt(
        keyLastValidTimestampMs,
        networkUtc.millisecondsSinceEpoch,
      );

      // Clean up any stray completions that might have been logged in the future
      try {
        final currentDateStr = _formatDateStr(networkUtc.toLocal());
        await _cleanupFutureCompletions(currentDateStr);
      } catch (e) {
        debugPrint(
          'TimeValidationService: Error cleaning up future records: $e',
        );
      }

      return TimeValidationResult.valid(
        deviceTime: nowDevice,
        trustedTime: networkUtc.toLocal(),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LAYER 2: OFFLINE FALLBACK CHECKS (Only executed when no network access)
    // ─────────────────────────────────────────────────────────────────────────
    final lastValidMs = _storage.getInt(keyLastValidTimestampMs);

    // Check A: Has the device clock been rolled back before previously verified time?
    if (lastValidMs != null &&
        currentDeviceMs < (lastValidMs - rollbackTolerance.inMilliseconds)) {
      debugPrint(
        'TimeValidationService: Offline rollback detected. Current: $currentDeviceMs < LastValid: $lastValidMs',
      );
      return TimeValidationResult.tampered(
        reason: 'Device clock rolled back before previously recorded session',
        deviceTime: nowDevice,
      );
    }

    // Check B: Is current device date earlier than existing database completions?
    try {
      final maxDateStr = await _getMaxCompletionDate();
      if (maxDateStr != null && maxDateStr.length == 8) {
        final currentDateStr = _formatDateStr(nowDevice);
        if (currentDateStr.compareTo(maxDateStr) < 0) {
          debugPrint(
            'TimeValidationService: Date is earlier than recorded completions ($currentDateStr < $maxDateStr)',
          );
          return TimeValidationResult.tampered(
            reason: 'Device date is earlier than existing habit completions',
            deviceTime: nowDevice,
          );
        }
      }
    } catch (e) {
      debugPrint('TimeValidationService: Error checking completion dates: $e');
    }

    // Offline progress tracking:
    // Only incrementally advance lastValidMs if the jump is within normal human session limits (<= 24 hours).
    // Never blindly store unverified extreme future dates when offline!
    if (lastValidMs == null) {
      await _storage.setInt(keyLastValidTimestampMs, currentDeviceMs);
    } else if (currentDeviceMs >= lastValidMs) {
      final forwardDelta = currentDeviceMs - lastValidMs;
      if (forwardDelta <= const Duration(hours: 24).inMilliseconds) {
        await _storage.setInt(keyLastValidTimestampMs, currentDeviceMs);
      } else {
        debugPrint(
          'TimeValidationService: Suspicious offline forward jump ($forwardDelta ms). Ignoring.',
        );
      }
    }

    return TimeValidationResult.valid(deviceTime: nowDevice);
  }

  /// Removes any habit completions recorded in future dates beyond today.
  Future<void> _cleanupFutureCompletions(String todayStr) async {
    await (_db.delete(
      _db.habitCompletions,
    )..where((t) => t.dateStr.isBiggerThanValue(todayStr))).go();
  }

  /// Query the maximum completion date recorded in the database.
  Future<String?> _getMaxCompletionDate() async {
    final query = _db.selectOnly(_db.habitCompletions)
      ..addColumns([_db.habitCompletions.dateStr.max()]);
    final row = await query.getSingleOrNull();
    return row?.read(_db.habitCompletions.dateStr.max());
  }

  /// Formats [date] as 'YYYYMMDD'.
  String _formatDateStr(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// Attempts to fetch trusted UTC time from trusted public servers via HTTP HEAD.
  Future<DateTime?> _fetchNetworkUtcTime() async {
    final client = _httpClient ?? http.Client();
    final shouldClose = _httpClient == null;

    final endpoints = [
      Uri.parse('https://www.google.com'),
      Uri.parse('https://cloudflare.com'),
    ];

    try {
      for (final uri in endpoints) {
        try {
          final response = await client
              .head(uri)
              .timeout(const Duration(milliseconds: 3500));
          final dateHeader = response.headers['date'];
          if (dateHeader != null && dateHeader.isNotEmpty) {
            final parsed = HttpDate.parse(dateHeader);
            return parsed.toUtc();
          }
        } catch (_) {
          // Attempt next fallback endpoint
        }
      }
    } finally {
      if (shouldClose) {
        client.close();
      }
    }
    return null;
  }
}
