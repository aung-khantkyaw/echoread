import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../config/cloudinary_config.dart';

class PdfViewScreen extends StatelessWidget {
  final String publicId;
  const PdfViewScreen({super.key, required this.publicId});

  @override
  Widget build(BuildContext context) {
    print(publicId);
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer')),
      body: SfPdfViewer.network(
        // Try this known-good URL for testing purposes
        CloudinaryConfig.baseUrl(publicId, MediaType.ebook),
        onDocumentLoadFailed: (details) {
          print('PDF Load Failed: ${details.description}');
        },
        onDocumentLoaded: (details) {
          print('PDF Document Loaded Successfully!');
        },
      ),
    );
  }
}