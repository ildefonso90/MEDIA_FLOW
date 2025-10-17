import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final audioStatus = await Permission.audio.request();
        final videoStatus = await Permission.videos.request();
        
        return audioStatus.isGranted || videoStatus.isGranted;
      } else if (sdkInt >= 30) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          final manageStatus = await Permission.manageExternalStorage.request();
          return manageStatus.isGranted;
        }
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final audioGranted = await Permission.audio.isGranted;
        final videoGranted = await Permission.videos.isGranted;
        return audioGranted || videoGranted;
      } else if (sdkInt >= 30) {
        final storageGranted = await Permission.storage.isGranted;
        final manageGranted = await Permission.manageExternalStorage.isGranted;
        return storageGranted || manageGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
