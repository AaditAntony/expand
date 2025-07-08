import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import '../../viewmodels/preview_viewmodel.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final File? pdfFile;
  final String? pdfUrl;

  const PreviewScreen({super.key, this.pdfFile, this.pdfUrl})
    : assert(pdfFile != null || pdfUrl != null);

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late Future<Uint8List> _pdfData;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    final previewViewModel = ref.read(previewViewModelProvider);
    _pdfData = previewViewModel.getPdfData(widget.pdfFile, widget.pdfUrl);
  }

  @override
  void dispose() {
    // ref.read(previewViewModelProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewViewModel = ref.read(previewViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Bill Preview'),
        actions: [
          IconButton(
            icon:
                _isDownloading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.download),
            onPressed:
                _isDownloading
                    ? null
                    : () async {
                      setState(() => _isDownloading = true);
                      try {
                        final data = await _pdfData;
                        await previewViewModel.downloadPdf(
                          data,
                          'transport_bill_${DateTime.now().millisecondsSinceEpoch}',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e')),
                        );
                      } finally {
                        setState(() => _isDownloading = false);
                      }
                    },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                final data = await _pdfData;
                await previewViewModel.sharePdf(data);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sharing PDF: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return PdfPreview(
            build: (format) => snapshot.data!,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
          );
        },
      ),
    );
  }
}
