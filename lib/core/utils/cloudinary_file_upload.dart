import 'dart:developer';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class CloudinaryFileUpload {
  final cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    cache: false,
  );

  Future<String?> uploadImageToCloudinary(File imageFile, String folderName) async {
    final fileNameWithoutExtension = path.basenameWithoutExtension(imageFile.path);
    final fileExt = path.extension(imageFile.path).replaceAll('.', '');
    final publicId = '$folderName/$fileNameWithoutExtension';

    try {
      await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folderName,
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return '$publicId.$fileExt';
    } catch (e) {
      log('❌ Image upload failed: $e');
      return null;
    }
  }

  Future<String?> _uploadRawFileToCloudinary(
      File file,
      String folderName,
      String resourceType,
      String contentType,
      String publicIdSuffix,
      ) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      log('Cloudinary config is missing.');
      return null;
    }

    if (!file.existsSync()) {
      log('File does not exist: ${file.path}');
      return null;
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    final fileName = path.basename(file.path);
    final fileNameWithoutExtension = path.basenameWithoutExtension(file.path);
    final fileExt = path.extension(file.path).replaceAll('.', '');

    final safeFileName = fileNameWithoutExtension.replaceAll(RegExp(r'[^\w\u1000-\u109F\-]'), '_');

    final publicId = publicIdSuffix.isEmpty
        ? '$folderName/$safeFileName'
        : '$folderName/part_${publicIdSuffix}_$safeFileName';

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        return '$publicId.$fileExt';
      } else {
        final respStr = await response.stream.bytesToString();
        log('Upload failed: ${response.statusCode} | $respStr');
        return null;
      }
    } catch (e) {
      log('Error during upload: $e');
      return null;
    }
  }

  Future<String?> uploadPdfToCloudinary(File pdfFile, String folderName) async {
    return _uploadRawFileToCloudinary(pdfFile, folderName, 'raw', 'application/pdf', '');
  }

  Future<String?> uploadAudioToCloudinary(
      File audioFile,
      String folderName, {
        String publicIdSuffix = '',
      }) async {
    final ext = path.extension(audioFile.path).toLowerCase();

    String mimeType;
    switch (ext) {
      case '.wav':
        mimeType = 'audio/wav';
        break;
      case '.ogg':
        mimeType = 'audio/ogg';
        break;
      case '.mp3':
        mimeType = 'audio/mpeg';
        break;
      default:
        mimeType = 'audio/mpeg';
    }

    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final timestamp = formatter.format(now);

    String rawName = publicIdSuffix.isNotEmpty ? publicIdSuffix : '';
    rawName = '${rawName}_$timestamp';


    return _uploadRawFileToCloudinary(
      audioFile,
      folderName,
      'video',
      mimeType,
      rawName,
    );
  }
}
