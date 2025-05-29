import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPickerHelper {
  static Future<int> _getAndroidSdkInt() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    return deviceInfo.version.sdkInt;
  }

  static Future<bool> pickImage(Function(File) onImagePicked) async {
    final sdkInt = Platform.isAndroid ? await _getAndroidSdkInt() : 0;

    PermissionStatus permissionStatus;

    if (Platform.isAndroid && sdkInt >= 33) {
      permissionStatus = await Permission.photos.request();
    } else {
      permissionStatus = await Permission.storage.request();
    }

    if (permissionStatus.isGranted) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        onImagePicked(File(picked.path));
        return true;
      } else {
        log('No image selected.');
        return false;
      }
    } else {
      if (permissionStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }

  static Future<String?> pickAudio() async {
    final sdkInt = Platform.isAndroid ? await _getAndroidSdkInt() : 0;

    PermissionStatus permissionStatus;

    if (Platform.isAndroid && sdkInt >= 33) {
      permissionStatus = await Permission.audio.request();
    } else {
      permissionStatus = await Permission.storage.request();
    }

    if (permissionStatus.isGranted) {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      } else {
        log('No audio selected.');
        return null;
      }
    } else {
      if (permissionStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return null;
    }
  }
}
