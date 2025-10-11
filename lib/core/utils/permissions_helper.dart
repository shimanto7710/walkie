import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }


  static Future<bool> requestAudioPermissions() async {
    final micPermission = await requestMicrophonePermission();
    return micPermission;
  }


  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }


  static Future<bool> checkAudioPermissions() async {
    final micPermission = await checkMicrophonePermission();
    return micPermission;
  }


  static Future<void> openSettings() async {
    await openAppSettings();
  }

  static String getPermissionDeniedMessage(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return 'Microphone permission is required for voice calls. Please enable it in settings.';
      default:
        return 'Permission is required. Please enable it in settings.';
    }
  }
}
