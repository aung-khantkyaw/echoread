import 'dart:io';
import 'dart:ui';

import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

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

Future<List<File>> splitPdfByPage(File pdfFile, int chunkPageCount) async {
  final bytes = await pdfFile.readAsBytes();
  final document = PdfDocument(inputBytes: bytes);

  final List<File> chunkFiles = [];
  final totalPages = document.pages.count;

  for (int i = 0; i < totalPages; i += chunkPageCount) {
    final newDoc = PdfDocument();

    for (int j = i; j < i + chunkPageCount && j < totalPages; j++) {
      final template = document.pages[j].createTemplate();
      newDoc.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
    }

    final chunkBytes = newDoc.saveSync();
    newDoc.dispose();

    final chunkFile = File('${pdfFile.path}_chunk_$i.pdf');
    await chunkFile.writeAsBytes(chunkBytes);
    chunkFiles.add(chunkFile);
  }

  document.dispose();
  return chunkFiles;
}

Future<List<File>> splitAudioByDuration(File inputFile, int chunkDurationInSeconds) async {
  final tempDir = await getTemporaryDirectory();
  final inputPath = inputFile.path;
  final outputBaseName = path.basenameWithoutExtension(inputPath);
  final outputExt = path.extension(inputPath);
  final outputDir = path.join(tempDir.path, 'audio_chunks_${DateTime.now().millisecondsSinceEpoch}');
  Directory(outputDir).createSync(recursive: true);

  final totalDuration = await getAudioDuration(inputPath);
  final numChunks = (totalDuration / chunkDurationInSeconds).ceil();

  List<File> chunks = [];

  for (int i = 0; i < numChunks; i++) {
    final outFile = File(path.join(outputDir, '${outputBaseName}_chunk_$i$outputExt'));
    final startTime = i * chunkDurationInSeconds;

    await FFmpegKit.execute(
      '-i "$inputPath" -ss $startTime -t $chunkDurationInSeconds -c copy "${outFile.path}"',
    );

    if (await outFile.exists()) {
      chunks.add(outFile);
    }
  }

  return chunks;
}

Future<int> getAudioDuration(String filePath) async {
  final session = await FFprobeKit.getMediaInformation(filePath);
  final info = session.getMediaInformation();
  final duration = info?.getDuration();
  if (duration == null) throw Exception('Audio duration not found');
  return double.parse(duration).round();
}