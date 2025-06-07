import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pdf_generator.dart';
import 'preview_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Bill',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const TransportBillForm(),
    );
  }
}

class TransportBillForm extends StatefulWidget {
  const TransportBillForm({super.key});

  @override
  State<TransportBillForm> createState() => _TransportBillFormState();
}

class _TransportBillFormState extends State<TransportBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceController = TextEditingController();
  final _dateController = TextEditingController();
  final _truckController = TextEditingController();
  final _recipientController = TextEditingController();
  final _containerController = TextEditingController();
  final _unloadingController = TextEditingController();
  final _axleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _hireController = TextEditingController();
  final _tollController = TextEditingController();
  final _weighingController = TextEditingController();
  final _haltingController = TextEditingController();
  final _advanceController = TextEditingController();
  final _driverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _dateController.dispose();
    _truckController.dispose();
    _recipientController.dispose();
    _containerController.dispose();
    _unloadingController.dispose();
    _axleController.dispose();
    _destinationController.dispose();
    _hireController.dispose();
    _tollController.dispose();
    _weighingController.dispose();
    _haltingController.dispose();
    _advanceController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transport Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Invoice Details
              _buildSectionHeader('Invoice Details'),
              _buildTextFormField(
                _invoiceController,
                'SL.No',
                isRequired: true,
              ),
              _buildTextFormField(_dateController, 'Date', isReadOnly: true),
              _buildTextFormField(
                _truckController,
                'Truck No.',
                isRequired: true,
              ),

              // Recipient Details
              _buildSectionHeader('Recipient Details'),
              _buildTextFormField(
                _recipientController,
                'To (Consignee Name)',
                isRequired: true,
              ),

              // Container Details
              _buildSectionHeader('Container Details'),
              _buildTextFormField(
                _containerController,
                'CONTAINER No.',
                isRequired: true,
              ),
              _buildTextFormField(
                _unloadingController,
                'UNLOADING CHARGE',
                isNumber: true,
              ),
              _buildDropdownField(_axleController, '20/40 ', ['20 ', '40 ']),
              _buildTextFormField(_destinationController, 'DESTINATION'),
              _buildTextFormField(_hireController, 'HIRE', isNumber: true),
              _buildTextFormField(_tollController, 'TOLL', isNumber: true),
              _buildTextFormField(
                _weighingController,
                'W. CHARGE',
                isNumber: true,
              ),
              _buildTextFormField(
                _haltingController,
                'HALTING CHARGE',
                isNumber: true,
              ),
              _buildTextFormField(
                _advanceController,
                'ADVANCE',
                isNumber: true,
              ),

              // Driver Details
              _buildSectionHeader('Driver Details'),
              _buildTextFormField(_driverController, 'Driver Name'),

              // Generate Button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePdf,
                child: const Text('Generate Transport Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    bool isNumber = false,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: isReadOnly,
        validator:
            isRequired
                ? (value) => value?.isEmpty ?? true ? 'Required field' : null
                : null,
      ),
    );
  }

  Widget _buildDropdownField(
    TextEditingController controller,
    String label,
    List<String> options,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            options.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (newValue) {
          controller.text = newValue ?? '';
        },
        validator: (value) => value?.isEmpty ?? true ? 'Please select' : null,
      ),
    );
  }

  Future<void> _generatePdf() async {
    if (_formKey.currentState!.validate()) {
      final pdfFile = await generateTransportBill(
        invoiceNumber: _invoiceController.text,
        date: _dateController.text,
        truckNumber: _truckController.text,
        recipientName: _recipientController.text,
        containerNumber: _containerController.text,
        unloadingCharge: _unloadingController.text,
        axleType: _axleController.text,
        destination: _destinationController.text,
        hireCharge: _hireController.text,
        tollCharge: _tollController.text,
        weighingCharge: _weighingController.text,
        haltingCharge: _haltingController.text,
        advanceAmount: _advanceController.text,
        driverName: _driverController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(pdfFile: pdfFile),
        ),
      );
    }
  }
}
