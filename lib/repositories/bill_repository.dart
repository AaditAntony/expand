import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/bill_model.dart';

class BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> saveTransportBill({
    required Bill bill,
    required File pdfFile,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload PDF to Storage
      final pdfRef = _storage.ref().child(
        'transport_bills/${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await pdfRef.putFile(pdfFile);
      final pdfUrl = await pdfRef.getDownloadURL();

      // Save bill data to Firestore
      final billData = bill.toMap();
      await _firestore.collection('transport_bills').add(billData);

      return pdfUrl;
    } catch (e) {
      throw Exception('Failed to save bill: $e');
    }
  }

  Future<List<Bill>> searchBillsByConsignee(String consigneeName) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final normalizedSearch =
          consigneeName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      final searchTerm = normalizedSearch.replaceAll(' ', '');

      final querySnapshot =
          await _firestore
              .collection('transport_bills')
              .where('userId', isEqualTo: _auth.currentUser!.uid)
              .where('recipientNameSearch', isGreaterThanOrEqualTo: searchTerm)
              .where(
                'recipientNameSearch',
                isLessThanOrEqualTo: '$searchTerm\uf8ff',
              )
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Bill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }

  Future<void> migrateExistingData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query =
        await _firestore
            .collection('transport_bills')
            .where('userId', isEqualTo: user.uid)
            .get();

    final batch = _firestore.batch();

    for (final doc in query.docs) {
      if (!doc.data().containsKey('recipientNameSearch')) {
        final recipientName = doc['recipientName'] as String;
        final normalizedName =
            recipientName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

        batch.update(doc.reference, {'recipientNameSearch': normalizedName});
      }
    }

    await batch.commit();
  }
}
