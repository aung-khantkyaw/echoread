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

  Future<String?> uploadFileToCloudinary(
      File file,
      String folder, {
        String? publicIdSuffix,
        CloudinaryResourceType resourceType = CloudinaryResourceType.Raw,
      }) async {
    final fileName = path.basename(file.path);
    final fileNameWithoutExtension = path.basenameWithoutExtension(fileName);
    final fileExt = path.extension(file.path).replaceAll('.', '');
    final publicId = publicIdSuffix != null
        ? '$folder/${fileNameWithoutExtension}_$publicIdSuffix'
        : '$folder/$fileNameWithoutExtension';

    try {
      await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: resourceType,
          folder: folder,
          publicId: publicId,
        ),
      );
      return '$publicId.$fileExt';
    } catch (e) {
      log('❌ Upload failed: $e');
      return null;
    }
  }

  Future<String?> uploadChunkWithRetry(
      File chunk,
      String folder, {
        String? publicIdSuffix,
        CloudinaryResourceType resourceType = CloudinaryResourceType.Raw,
      }) async {
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final filePath = await uploadFileToCloudinary(
          chunk,
          folder,
          publicIdSuffix: publicIdSuffix,
          resourceType: resourceType,
        );

        if (filePath != null) {
          log('✅ Chunk uploaded successfully on attempt ${attempt + 1}: ${chunk.path}');
          return filePath;
        }
      } catch (e) {
        log('⚠️ Error uploading chunk on attempt ${attempt + 1}: $e');
      }

      attempt++;
      if (attempt < maxRetries) {
        log('🔁 Retrying upload for chunk ${chunk.path} (attempt ${attempt + 1})...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    log('❌ Failed to upload chunk after $maxRetries attempts: ${chunk.path}');
    return null;
  }

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
      String resourceType, // e.g., "raw", "video"
      String contentType, // e.g., "application/pdf", "audio/mpeg"
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

    // Replace invalid characters for Cloudinary ID
    final safeFileName = fileNameWithoutExtension.replaceAll(RegExp(r'[^\w\u1000-\u109F\-]'), '_');

    // Modify publicId format to: ebooks/စာရေးကြီး_part1
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
