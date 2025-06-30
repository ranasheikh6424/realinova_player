import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestAllMediaPermissions() async {
    bool allGranted = true;

    if (Platform.isAndroid) {
      final androidVersion = int.parse(Platform.version.split(' ')[0].split('.').first);

      if (androidVersion >= 13) {
        // Android 13+ granular permissions
        final permissions = [
          Permission.audio,
          Permission.videos,
          Permission.photos,
        ];

        for (var permission in permissions) {
          final granted = await _request(permission);
          if (!granted) {
            allGranted = false;
          }
        }
      } else {
        // Older Android versions
        final storageGranted = await _request(Permission.storage);
        if (!storageGranted) {
          allGranted = false;
        }
      }
    }

    return allGranted;
  }

  Future<bool> _request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }
    final result = await permission.request();
    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      print("${permission.toString()} permanently denied");
    } else {
      print("${permission.toString()} denied");
    }
    return false;
  }
}
