import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

class PdfViewScreen extends StatelessWidget {
  final String publicId;
  final String title;
  const PdfViewScreen({super.key, required this.publicId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SfPdfViewer.network(
        CloudinaryConfig.baseUrl(publicId, MediaType.ebook),
        onDocumentLoadFailed: (details) {
          log('PDF Load Failed: ${details.description}');
        },
        onDocumentLoaded: (details) {
          log('PDF Document Loaded Successfully!');
        },
      ),
    );
  }
}