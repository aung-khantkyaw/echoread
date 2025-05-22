import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      // Extract path after "upload/.../<folderName>/..."
      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath; // e.g., "book_cover/ejd1yymzzdrqnxfisahg.webp"
      } else {
        return null;
      }
    } else {
      print('Upload failed: ${response.statusCode}');
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

      // Extract path after "upload/<folderName>/..."
      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath; // e.g., "ebooks/book_title.pdf"
      } else {
        return null;
      }
    } else {
      print('PDF upload failed: ${response.statusCode}');
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

      // Extract path after "upload/<folderName>/..."
      final folderIndex = segments.indexOf(folderName);
      if (folderIndex != -1) {
        final filePath = segments.sublist(folderIndex).join('/');
        return filePath; // e.g., "book_audio/song_id.m4a"
      } else {
        return null;
      }
    } else {
      print('Audio upload failed: ${response.statusCode}');
      return null;
    }
  }
}