import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/bill_repository.dart';
import '../models/bill_model.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});

final billViewModelProvider = Provider<BillViewModel>((ref) {
  return BillViewModel(ref.read(billRepositoryProvider));
});

class BillViewModel {
  final BillRepository _repository;

  BillViewModel(this._repository);

  Future<String> saveTransportBill({
    required Bill bill,
    required File pdfFile,
  }) async {
    return await _repository.saveTransportBill(bill: bill, pdfFile: pdfFile);
  }

  Future<List<Bill>> searchBillsByConsignee(String consigneeName) async {
    return await _repository.searchBillsByConsignee(consigneeName);
  }

  Future<void> migrateExistingData() async {
    await _repository.migrateExistingData();
  }
}
