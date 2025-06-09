import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBills() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final results = await _firebaseService.searchBillsByConsignee(
        _searchController.text.trim(),
      );
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
                              Text('Total: ₹${bill['totalAmount']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () async {
                              final url = bill['pdfUrl'];
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
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
