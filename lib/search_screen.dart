import 'dart:io';

import 'package:expand/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  bool _isDownloading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _searchBills() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final results = await _firebaseService.searchBillsByConsignee(searchTerm);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching: $e')));
    }
  }

  Future<void> _downloadAndOpenPdf(String pdfUrl) async {
    setState(() => _isDownloading = true);
    try {
      // Request storage permissions (required for Android 10+)
      if (Platform.isAndroid) {
        // Check & request storage permissions
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      // Get the public Downloads directory path
      final String downloadsPath;
      if (Platform.isAndroid) {
        // Android: Use the public Downloads folder
        downloadsPath = '/storage/emulated/0/Download';
      } else {
        // iOS: Use app's documents directory (fallback)
        final dir = await getDownloadsDirectory();
        downloadsPath = dir?.path ?? '';
      }

      // Create the directory if it doesn't exist
      final Directory dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final String filePath =
          '${dir.path}/Transport_Bill_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Download the file
      await _dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Show success message with path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to Downloads: $filePath')),
      );

      // Open the file
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Consignee Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchBills,
                ),
              ),
              onSubmitted: (_) => _searchBills(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _searchResults.isEmpty
                ? const Text('No bills found for this consignee')
                : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final bill =
                          _searchResults[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(bill['recipientName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice: ${bill['invoiceNumber']}'),
                              Text('Truck: ${bill['truckNumber']}'),
                              Text('Date: ${bill['date']}'),
                              if (bill['advanceAmount'] != null &&
                                  bill['advanceAmount'] != 0 &&
                                  bill['advanceAmount'].toString().isNotEmpty)
                                Text('Advance: ₹${bill['advanceAmount']}'),
                              Text('Total: ₹${bill['totalAmount']}'),
                            ],
                          ),
                          trailing:
                              _isDownloading
                                  ? const CircularProgressIndicator()
                                  : IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed:
                                        () =>
                                            _downloadAndOpenPdf(bill['pdfUrl']),
                                  ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Bill Details'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            'Invoice Number',
                                            bill['invoiceNumber'],
                                          ),
                                          _buildDetailRow('Date', bill['date']),
                                          _buildDetailRow(
                                            'Truck Number',
                                            bill['truckNumber'],
                                          ),
                                          _buildDetailRow(
                                            'Container',
                                            bill['containerNumber'],
                                          ),
                                          _buildDetailRow(
                                            'Destination',
                                            bill['destination'],
                                          ),
                                          _buildDetailRow(
                                            'Hire Charge',
                                            '₹${bill['hireCharge']}',
                                          ),
                                          _buildDetailRow(
                                            'Toll Charge',
                                            '₹${bill['tollCharge']}',
                                          ),
                                          _buildDetailRow(
                                            "Advanced Amount",
                                            '₹${bill['advanceAmount']}',
                                          ),
                                          _buildDetailRow(
                                            'Total Amount',
                                            '₹${bill['totalAmount']}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
