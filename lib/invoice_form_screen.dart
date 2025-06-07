import 'package:flutter/material.dart';
import 'preview_share_screen.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final formKey = GlobalKey<FormState>();
  final data = <String, String>{};

  final fields = [
    'Sl. No',
    'Date',
    'Truck No',
    'To',
    'Container No',
    'Unloading Charge',
    '20/40 Axle',
    'Destination',
    'Hire',
    'Toll',
    'W. Charge',
    'Halting Charge',
    'Advance',
    'Total Amount',
    'Driver Name',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Details')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              ...fields.map(
                (field) => TextFormField(
                  decoration: InputDecoration(labelText: field),
                  onSaved: (val) => data[field] = val ?? '',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  formKey.currentState?.save();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewShareScreen(data: data),
                    ),
                  );
                },
                child: const Text('Generate & Share PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
