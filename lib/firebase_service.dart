import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(
          credential,
        );
        final User? user = authResult.user;
        return user;
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String> saveTransportBill({
    required Map<String, dynamic> billData,
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

      // Normalize the recipient name for searching
      final recipientName = billData['recipientName'] as String;
      final normalizedName =
          recipientName
              .toLowerCase()
              .replaceAll(
                RegExp(r'\s+'),
                ' ',
              ) // Replace multiple spaces with single space
              .trim();

      // Store both original and normalized versions
      final updatedBillData = {
        ...billData,
        'recipientName': recipientName, // original with proper case
        'recipientNameSearch': normalizedName, // normalized for searching
        'pdfUrl': pdfUrl,
        'userId': _auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('transport_bills').add(updatedBillData);
      return pdfUrl;
    } catch (e) {
      throw Exception('Failed to save bill: $e');
    }
  }

  // Search bills by consignee name for the current user
  Future<List<QueryDocumentSnapshot>> searchBillsByConsignee(
    String consigneeName,
  ) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Normalize the search term the same way we stored it
      final normalizedSearch =
          consigneeName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

      // Create a search term that matches any part of the name
      final searchTerm = normalizedSearch.replaceAll(
        ' ',
        '',
      ); // Remove all spaces for broader matching

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

      // For more precise matching, you can filter client-side
      final filteredResults =
          querySnapshot.docs.where((doc) {
            final storedName = doc['recipientNameSearch'] as String;
            return storedName.contains(normalizedSearch);
          }).toList();

      return filteredResults;
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }
}
