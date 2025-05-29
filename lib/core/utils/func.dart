import 'dart:io';
import 'dart:developer';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIsLoggedIn() async {
  await Future.delayed(Duration(seconds: 3));
  final prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool('isLoggedIn');
  return isLoggedIn ?? false;
}

Future<Map<String, dynamic>?> getUserDetail() async {
  final prefs = await SharedPreferences.getInstance();

  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (!isLoggedIn) return null;

  return {
    'uid': prefs.getString('userId') ?? '',
    'name': prefs.getString('userName') ?? '',
    'email': prefs.getString('userEmail') ?? '',
    'role': prefs.getString('userRole') ?? '',
    'profile_img': prefs.getString('userProfileImg') ?? '',
  };
}

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.request();
  return status.isGranted;
}

// Wrapper for compute()
Future<List<String>> splitPdfByPageWrapper(Map<String, dynamic> args) {
  return splitPdfByPage(File(args['filePath']), args['pagesPerChunk']);
}

Future<List<String>> splitAudioByDurationWrapper(Map<String, dynamic> args) {
  return splitAudioByDuration(File(args['filePath']), args['durationMinutes']);
}

// PDF Split Logic
Future<List<String>> splitPdfByPage(File pdfFile, int pagesPerChunk) async {
  log('File Path : $pdfFile');
  final uri = Uri.parse('https://echo-read-media-split-merge.onrender.com/api/pdf/split');
  // final uri = Uri.parse('http://192.168.100.28:3000/api/pdf/split');
  final request = http.MultipartRequest('POST', uri)
    ..fields['pages_per_chunk'] = pagesPerChunk.toString()
    ..files.add(
      await http.MultipartFile.fromPath(
        'pdf',
        pdfFile.path,
        filename: path.basename(pdfFile.path),
      ),
    );

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);

    final files = data['files'];
    if (files is List) {
      return List<String>.from(files);
    } else {
      throw Exception('Invalid response format');
    }
  } else {
    throw Exception('Failed to split PDF (status: ${response.statusCode})');
  }
}


// Audio Split Logic
Future<List<String>> splitAudioByDuration(File audioFile, int durationMinutes) async {
  try {
    final uri = Uri.parse('https://echo-read-media-split-merge.onrender.com/api/audio/split');
    // final uri = Uri.parse('http://192.168.100.28:3000/api/audio/split');
    final request = http.MultipartRequest('POST', uri)
      ..fields['duration'] = durationMinutes.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: utf8.decode(utf8.encode(path.basename(audioFile.path))),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (data['files'] != null && data['files'] is List) {
        return List<String>.from(data['files']);
      } else {
        throw Exception('Invalid response format from split API');
      }
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Split API failed: $respStr');
    }
  } catch (e) {
    rethrow;
  }
}
