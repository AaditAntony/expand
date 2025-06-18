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

  // Save transport bill to Firestore and upload PDF to Storage
  Future<String> saveTransportBill({
    // Changed return type to String
    required Map<String, dynamic> billData,
    required File pdfFile,
  }) async {
    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload PDF to Storage with user-specific path
      final pdfRef = _storage.ref().child(
        'transport_bills/${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await pdfRef.putFile(pdfFile);
      final pdfUrl = await pdfRef.getDownloadURL(); // Get the download URL

      // Save data to Firestore with PDF URL and user ID
      await _firestore.collection('transport_bills').add({
        ...billData,
        'pdfUrl': pdfUrl,
        'userId': _auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return pdfUrl; // Return the download URL
    } catch (e) {
      throw Exception('Failed to save bill: $e');
    }
  }

  // Search bills by consignee name for the current user
  Future<List<QueryDocumentSnapshot>> searchBillsByConsignee(
    String consigneeName,
  ) async {
    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection('transport_bills')
              .where('userId', isEqualTo: _auth.currentUser!.uid)
              .where('recipientName', isEqualTo: consigneeName)
              .orderBy('createdAt', descending: true)
              .get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }
}
