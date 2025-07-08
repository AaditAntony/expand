import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

final previewViewModelProvider = Provider<PreviewViewModel>((ref) {
  return PreviewViewModel();
});

class PreviewViewModel {
  final Dio _dio = Dio();

  Future<Uint8List> getPdfData(File? pdfFile, String? pdfUrl) async {
    if (pdfFile != null) {
      return await pdfFile.readAsBytes();
    } else if (pdfUrl != null) {
      final response = await _dio.get(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    }
    throw Exception('No PDF source provided');
  }

  Future<void> downloadPdf(Uint8List pdfData, String fileName) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      final String downloadsPath;
      if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      } else {
        final dir = await getDownloadsDirectory();
        downloadsPath = dir?.path ?? '';
      }

      final Directory dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final String filePath = '${dir.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfData);
      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  Future<void> sharePdf(Uint8List pdfData) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_share.pdf');
      await file.writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      throw Exception('Error sharing PDF: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
