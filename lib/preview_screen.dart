import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PreviewScreen extends StatefulWidget {
  final File? pdfFile;
  final String? pdfUrl;

  const PreviewScreen({super.key, this.pdfFile, this.pdfUrl})
    : assert(pdfFile != null || pdfUrl != null);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late Future<Uint8List> _pdfData;
  final Dio _dio = Dio();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _pdfData = _getPdfData();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  Future<Uint8List> _getPdfData() async {
    if (widget.pdfFile != null) {
      return await widget.pdfFile!.readAsBytes();
    } else if (widget.pdfUrl != null) {
      final response = await _dio.get(
        widget.pdfUrl!,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    }
    throw Exception('No PDF source provided');
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);
    try {
      final dir = Directory('/storage/emulated/0/Download');
      final file = File(
        '${dir.path}/transport_bill_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final data = await _getPdfData();
      await file.writeAsBytes(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _sharePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_share.pdf');
      final data = await _getPdfData();
      await file.writeAsBytes(data);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Bill Preview'),
        actions: [
          IconButton(
            icon:
                _isDownloading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadPdf,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _sharePdf),
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
