import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

  final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset!
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: basename(imageFile.path),
    ));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final jsonResp = json.decode(respStr);
    return jsonResp['secure_url']; // Cloudinary URL of the uploaded image
  } else {
    print('Upload failed: ${response.statusCode}');
    return null;
  }
}