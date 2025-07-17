import 'package:expand/viewmodels/bill_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/bill_repository.dart';
import '../models/bill_model.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

final searchViewModelProvider = Provider<SearchViewModel>((ref) {
  return SearchViewModel(ref.read(billViewModelProvider));
});

class SearchViewModel {
  final BillViewModel _billViewModel;
  final Dio _dio = Dio();

  SearchViewModel(this._billViewModel);

  Future<List<Bill>> searchBills(String consigneeName) async {
    return await _billViewModel.searchBillsByConsignee(consigneeName);
  }

  Future<void> downloadAndOpenPdf(String pdfUrl) async {
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

      final String filePath =
          '${dir.path}/Transport_Bill_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _dio.download(pdfUrl, filePath);
      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
