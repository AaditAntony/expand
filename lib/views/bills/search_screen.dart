import 'package:expand/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bill_model.dart';
import '../../viewmodels/search_viewmodel.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Bill> _searchResults = [];
  bool _isLoading = false;
  bool _isDownloading = false;

  @override
  void dispose() {
    _searchController.dispose();
    // ref.read(searchViewModelProvider).dispose();
    super.dispose();
  }

  Future<void> _searchBills() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final results = await ref
          .read(searchViewModelProvider)
          .searchBills(searchTerm);
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
    final searchViewModel = ref.read(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authViewModelProvider).signOut();
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
                      final bill = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(bill.recipientName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice: ${bill.invoiceNumber}'),
                              Text('Truck: ${bill.truckNumber}'),
                              Text('Date: ${bill.date}'),
                              if (bill.advanceAmount != null &&
                                  bill.advanceAmount != '0' &&
                                  bill.advanceAmount.isNotEmpty)
                                Text('Advance: ₹${bill.advanceAmount}'),
                              Text('Total: ₹${bill.totalAmount}'),
                            ],
                          ),
                          trailing:
                              _isDownloading
                                  ? const CircularProgressIndicator()
                                  : IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () async {
                                      setState(() => _isDownloading = true);
                                      try {
                                        await searchViewModel
                                            .downloadAndOpenPdf(bill.pdfUrl);
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      } finally {
                                        setState(() => _isDownloading = false);
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
                                            bill.invoiceNumber,
                                          ),
                                          _buildDetailRow('Date', bill.date),
                                          _buildDetailRow(
                                            'Truck Number',
                                            bill.truckNumber,
                                          ),
                                          _buildDetailRow(
                                            'Container',
                                            bill.containerNumber,
                                          ),
                                          _buildDetailRow(
                                            'Destination',
                                            bill.destination,
                                          ),
                                          _buildDetailRow(
                                            'Hire Charge',
                                            '₹${bill.hireCharge}',
                                          ),
                                          _buildDetailRow(
                                            'Toll Charge',
                                            '₹${bill.tollCharge}',
                                          ),
                                          _buildDetailRow(
                                            "Advanced Amount",
                                            '₹${bill.advanceAmount}',
                                          ),
                                          _buildDetailRow(
                                            'Total Amount',
                                            '₹${bill.totalAmount}',
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
