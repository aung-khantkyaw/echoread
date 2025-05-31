import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfMergedViewScreen extends StatefulWidget {
  final List<String> parts;
  final String title;
  final String bookId;

  const PdfMergedViewScreen({
    super.key,
    required this.parts,
    required this.title,
    required this.bookId,
  });

  @override
  State<PdfMergedViewScreen> createState() => _PdfMergedViewScreenState();
}

class _PdfMergedViewScreenState extends State<PdfMergedViewScreen> {
  Uint8List? mergedPdfBytes;
  bool isLoading = true;
  String? error;
  String? readingStatusDocId;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int? _totalPages;
  int _remainingMinutes = 0;
  Timer? _timer;
  bool isMarkedComplete = false;
  bool _isOnLastPage = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    if (!await hasInternetConnection()) {
      setState(() {
        error = "No internet connection.";
        isLoading = false;
      });
      return;
    }

    await mergeChunks();

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);
  }

  Future<void> createReadingStatus({required int totalPages}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final query = await _firestore
          .collection('reading_status')
          .where('userId', isEqualTo: user.uid)
          .where('bookId', isEqualTo: widget.bookId)
          .where('isComplete', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        readingStatusDocId = query.docs.first.id;
        final data = query.docs.first.data();
        _remainingMinutes = data['remainingMinutes'] ?? 0;
        isMarkedComplete = data['isComplete'] ?? false; // Make sure to load isMarkedComplete
        log("Existing reading_status found. Remaining minutes: $_remainingMinutes");
      } else {
        _remainingMinutes = totalPages;
        final docRef = await _firestore.collection('reading_status').add({
          'userId': user.uid,
          'bookId': widget.bookId,
          'startDate': Timestamp.now(),
          'isComplete': false,
          'lastReadPage': 1,
          'remainingMinutes': _remainingMinutes,
        });
        readingStatusDocId = docRef.id;
        log("New reading_status created. Initial remaining minutes: $_remainingMinutes");
        showSnackBar(context, "Start read ${widget.title}",
            type: SnackBarType.success);
      }
    } catch (e) {
      log('Error creating reading status: $e');
    }
  }

  Future<int?> getLastReadPage() async {
    if (readingStatusDocId == null) return null;

    try {
      final doc = await _firestore
          .collection('reading_status')
          .doc(readingStatusDocId)
          .get();
      final data = doc.data();
      if (data != null && data.containsKey('lastReadPage')) {
        return data['lastReadPage'];
      }
    } catch (e) {
      log('Failed to get last read page: $e');
    }
    return null;
  }

  Future<void> mergeChunks() async {
    const apiUrl =
        "https://echo-read-media-split-merge.onrender.com/api/pdf/merge";

    if (widget.parts.isEmpty) {
      setState(() {
        error = "No PDF parts provided";
        isLoading = false;
      });
      return;
    }

    try {
      if (widget.parts.length == 1) {
        final response = await http.get(Uri.parse(widget.parts.first));
        if (response.statusCode == 200) {
          mergedPdfBytes = response.bodyBytes;
        } else {
          error = "Failed to load single PDF: ${response.statusCode}";
        }
      } else {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"urls": widget.parts}),
        );

        if (response.statusCode == 200) {
          mergedPdfBytes = response.bodyBytes;
        } else {
          error = "Merge failed (${response.statusCode})";
        }
      }
    } catch (e) {
      error = "Error: $e";
    }
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_remainingMinutes > 0) {
        _remainingMinutes--;
        updateRemainingTime(_remainingMinutes);
        setState(() {});

      } else {
        _timer?.cancel();
        log('Timer finished, remaining minutes is 0.');
      }
    });
    log('Timer started for PdfMergedViewScreen');
    showSnackBar(context, 'Timer started for PdfMergedViewScreen');
  }

  Future<void> updateRemainingTime(int minutes) async {
    if (readingStatusDocId == null) return;
    try {
      await _firestore
          .collection('reading_status')
          .doc(readingStatusDocId)
          .update({
        'remainingMinutes': minutes,
      });
    } catch (e) {
      log('Failed to update remaining time: $e');
    }
  }

  Future<void> updateLastReadPage(int pageNumber) async {
    if (readingStatusDocId == null) return;
    try {
      await _firestore
          .collection('reading_status')
          .doc(readingStatusDocId)
          .update({
        'lastReadPage': pageNumber,
      });
      log("Updated last read page to $pageNumber");
      if (_totalPages != null && pageNumber == _totalPages) {
        setState(() {
          _isOnLastPage = true;
        });
      } else {
        setState(() {
          _isOnLastPage = false;
        });
      }
    } catch (e) {
      log('Failed to update last read page: $e');
    }
  }

  Future<void> markAsComplete() async {
    if (readingStatusDocId == null || isMarkedComplete) return;
    try {
      await _firestore
          .collection('reading_status')
          .doc(readingStatusDocId)
          .update({
        'isComplete': true,
        'endDate': Timestamp.now(),
        'remainingMinutes': 0,
      });
      setState(() {
        isMarkedComplete = true;
      });
      showSnackBar(context, "Marked as complete!", type: SnackBarType.success);
    } catch (e) {
      log('Failed to update reading status: $e');
      showSnackBar(context, "Error: $e", type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showCompleteButton = _remainingMinutes <= 0 &&
        _totalPages != null &&
        _isOnLastPage &&
        !isMarkedComplete;

    if (isLoading) return const GifLoader();

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  initialize();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SfPdfViewer.memory(
              mergedPdfBytes!,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) async {
                _totalPages = details.document.pages.count;
                log("Total pages: $_totalPages");

                await createReadingStatus(totalPages: _totalPages!);

                int? lastReadPage = await getLastReadPage();
                if (lastReadPage != null && lastReadPage > 0) {
                  _pdfViewerController.jumpToPage(lastReadPage);
                  if (lastReadPage == _totalPages) {
                    setState(() {
                      _isOnLastPage = true;
                    });
                  }
                }

                if (_remainingMinutes > 0 && !isMarkedComplete) {
                  startTimer();
                } else if (_remainingMinutes <= 0 && _totalPages != null && _pdfViewerController.pageNumber == _totalPages && !isMarkedComplete) {
                  setState(() {
                    _isOnLastPage = true;
                  });
                }
              },
              onPageChanged: (details) {
                updateLastReadPage(details.newPageNumber);
              },
            ),
          ),
          // Button appear at bottom
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: showCompleteButton ? 20 : -100,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: showCompleteButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !showCompleteButton,
                child: ElevatedButton(
                  onPressed: markAsComplete,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Mark as Complete"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    log('Timer paused/cancelled when leaving PdfMergedViewScreen');
    super.dispose();
  }
}