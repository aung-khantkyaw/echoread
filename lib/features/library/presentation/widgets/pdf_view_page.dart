import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:echoread/core/widgets/custom_gif_loading.dart';

class PdfMergedViewScreen extends StatefulWidget {
  final List<String> parts; // URLs of splitted PDFs
  final String title;

  const PdfMergedViewScreen({
    super.key,
    required this.parts,
    required this.title,
  });

  @override
  State<PdfMergedViewScreen> createState() => _PdfMergedViewScreenState();
}

class _PdfMergedViewScreenState extends State<PdfMergedViewScreen> {
  Uint8List? mergedPdfBytes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    mergeChunks();
  }

  Future<void> mergeChunks() async {
    log(widget.parts.toString());
    final apiUrl = "https://pdf-merge-api.onrender.com/merge-pdfs";

    // final apiUrl = "https://echo-read-media-split-merge.onrender.com/api/pdf/merge";
    try {
      if (widget.parts.length == 1) {
        // Just load the single PDF directly
        final response = await http.get(Uri.parse(widget.parts.first));
        if (response.statusCode == 200) {
          setState(() {
            mergedPdfBytes = response.bodyBytes;
            isLoading = false;
          });
        } else {
          setState(() {
            error = "Failed to load single PDF: ${response.statusCode}";
            isLoading = false;
          });
        }
      } else {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"urls": widget.parts}),
        );

        if (response.statusCode == 200) {
          setState(() {
            mergedPdfBytes = response.bodyBytes;
            isLoading = false;
          });
        } else {
          setState(() {
            error = "Merge failed (${response.statusCode}): ${utf8.decode(response.bodyBytes)}";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const GifLoader();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: error != null
          ? Center(child: Text(error!))
          : SfPdfViewer.memory(mergedPdfBytes!),
    );
  }
}
