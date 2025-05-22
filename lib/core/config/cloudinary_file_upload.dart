import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class CloudinaryFileUpload {
  Future<String?> uploadImageToCloudinary(File imageFile, String folderName) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final fileName = basename(imageFile.path);
    final fileNameWithoutExtension = fileName.split('.').first;
    final publicId = '$folderName/$fileNameWithoutExtension';

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset!
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: fileName,
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      final secureUrl = jsonResp['secure_url'];
      final segments = Uri.parse(secureUrl).pathSegments;

      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath;
      } else {
        return null;
      }
    } else {
      log('Upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> uploadPdfToCloudinary(File pdfFile, String folderName) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
    );

    final fileName = basename(pdfFile.path);
    final fileNameWithoutExtension = fileName.split('.').first;
    final publicId = '$folderName/$fileNameWithoutExtension';

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset!
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        pdfFile.path,
        filename: fileName,
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      final secureUrl = jsonResp['secure_url'];
      final segments = Uri.parse(secureUrl).pathSegments;

      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath;
      } else {
        return null;
      }
    } else {
      log('PDF upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> uploadAudioToCloudinary(File audioFile, String folderName) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );

    final fileName = basename(audioFile.path);
    final fileNameWithoutExtension = fileName.split('.').first;
    final publicId = '$folderName/$fileNameWithoutExtension';

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset!
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        filename: fileName,
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      final secureUrl = jsonResp['secure_url'];
      final segments = Uri.parse(secureUrl).pathSegments;

      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath;
      } else {
        return null;
      }
    } else {
      log('Audio upload failed: ${response.statusCode}');
      return null;
    }
  }
}