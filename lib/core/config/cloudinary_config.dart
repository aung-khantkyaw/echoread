import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';

enum MediaType { image, audio, ebook }

class CloudinaryConfig {
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static String baseUrl(String publicId, MediaType mediaType) {
    final typePath = switch (mediaType) {
      MediaType.image => 'image',
      MediaType.audio => 'video',
      MediaType.ebook => 'raw',
    };

    return 'https://res.cloudinary.com/$cloudName/$typePath/upload/$uploadPreset/$publicId';
  }
}
