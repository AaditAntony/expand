import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PreviewScreen extends StatelessWidget {
  final File pdfFile;

  const PreviewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Bill Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Transport Bill ${DateTime.now().toString()}',
        subject: 'Transport Bill',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing PDF: $e')));
    }
  }
}
