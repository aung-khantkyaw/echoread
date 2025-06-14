import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryFileDelete {
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  Future<bool> deleteCloudinaryFile(String publicId, {String resourceType = 'raw'}) async {
    if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      print('⚠️ Missing Cloudinary credentials.');
      return false;
    }

    final url = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$cloudName/resources/$resourceType/upload',
      {'public_ids[]': publicId}, // <-- MUST be a query param
    );

    final basicAuth = 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': basicAuth,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Successfully deleted: $publicId');
        return true;
      } else {
        print('❌ Failed to delete: ${response.statusCode} | ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Exception deleting Cloudinary file: $e');
      return false;
    }
  }
}
