import 'dart:math' as math;

class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final String downloadUrl;
  final String? releaseNotes;

  const AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    required this.downloadUrl,
    this.releaseNotes,
  });

  /// Compares [remoteVersion] with [currentVersion].
  /// Returns `true` if [remoteVersion] is strictly newer than [currentVersion].
  static bool isRemoteNewer(String currentVersion, String remoteVersion) {
    final curParts = _extractVersionNumbers(currentVersion);
    final remParts = _extractVersionNumbers(remoteVersion);

    if (curParts.isEmpty || remParts.isEmpty) {
      return false;
    }

    final maxLen = math.max(curParts.length, remParts.length);
    for (int i = 0; i < maxLen; i++) {
      final c = i < curParts.length ? curParts[i] : 0;
      final r = i < remParts.length ? remParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  static List<int> _extractVersionNumbers(String version) {
    final sanitized = version.trim().replaceAll(RegExp(r'^[vV]'), '');
    final mainPart = sanitized.split(RegExp(r'[-+]')).first;
    return mainPart
        .split('.')
        .map((segment) => int.tryParse(segment) ?? 0)
        .toList();
  }
}
