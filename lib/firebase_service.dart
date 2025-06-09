import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save transport bill to Firestore and upload PDF to Storage
  Future<void> saveTransportBill({
    required Map<String, dynamic> billData,
    required File pdfFile,
  }) async {
    try {
      // Upload PDF to Storage
      final pdfRef = _storage.ref().child(
        'transport_bills/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await pdfRef.putFile(pdfFile);
      final pdfUrl = await pdfRef.getDownloadURL();

      // Save data to Firestore with PDF URL
      await _firestore.collection('transport_bills').add({
        ...billData,
        'pdfUrl': pdfUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save bill: $e');
    }
  }

  // Search bills by consignee name
  Future<List<QueryDocumentSnapshot>> searchBillsByConsignee(
    String consigneeName,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('transport_bills')
              .where('recipientName', isEqualTo: consigneeName)
              .orderBy('createdAt', descending: true)
              .get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }
}
