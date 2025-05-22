import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
        print('No image selected.');
        return false;
      }
    } else {
      if (permissionStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }

  static Future<bool> pickAudio(Function(String path) onAudioPicked) async {
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
        onAudioPicked(result.files.single.path!);
        return true;
      } else {
        print('No audio selected.');
        return false;
      }
    } else {
      if (permissionStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }
}
