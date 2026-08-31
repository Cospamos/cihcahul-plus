import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? releaseNotes;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
  });
}

/// Checks `github.com/Cospamos/cihcahul-plus` releases for a newer build
/// than the one currently installed, and can download + hand a found
/// update to the system installer.
class UpdateService {
  static const String _repo = "Cospamos/cihcahul-plus";

  /// Returns update info when the latest GitHub release is newer than the
  /// running app, or `null` when there's nothing to offer (up to date, no
  /// releases yet, or the request failed — e.g. no network).
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.github.com/repos/$_repo/releases/latest"),
        headers: {"Accept": "application/vnd.github+json"},
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String? ?? '').trim();
      final latestVersion = tag.startsWith('v') ? tag.substring(1) : tag;
      if (latestVersion.isEmpty) return null;

      final assets = (data['assets'] as List<dynamic>? ?? []);
      String? downloadUrl;
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
      if (downloadUrl == null) return null;

      final packageInfo = await PackageInfo.fromPlatform();
      if (!_isNewer(latestVersion, packageInfo.version)) return null;

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: data['body'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String latest, String current) {
    final l = _versionParts(latest);
    final c = _versionParts(current);
    final len = l.length > c.length ? l.length : c.length;
    for (var i = 0; i < len; i++) {
      final lp = i < l.length ? l[i] : 0;
      final cp = i < c.length ? c[i] : 0;
      if (lp != cp) return lp > cp;
    }
    return false;
  }

  static List<int> _versionParts(String version) {
    return version
        .split(RegExp(r'[.+\-]'))
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }

  /// Downloads [downloadUrl] to the app's cache directory, reporting
  /// progress via [onProgress] (0.0-1.0, or null when the total size isn't
  /// known), then hands the file to the system's package installer — the
  /// user only has to confirm the install prompt from there.
  static Future<void> downloadAndInstall(
    String downloadUrl, {
    void Function(double? progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cihcahul_plus_update.apk');

    final response = await http.Client().send(
      http.Request('GET', Uri.parse(downloadUrl)),
    );
    if (response.statusCode != 200) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }

    final total = response.contentLength;
    var received = 0;
    final sink = file.openWrite();
    await response.stream
        .map((chunk) {
          received += chunk.length;
          onProgress?.call(
            total != null && total > 0 ? received / total : null,
          );
          return chunk;
        })
        .pipe(sink);
    await sink.close();

    await OpenFilex.open(file.path);
  }
}
