import 'package:expand/services/%20pdf_generator.dart';
import 'package:expand/viewmodels/auth_viewmodel.dart';
import 'package:expand/views/bills/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../viewmodels/bill_viewmodel.dart';
import '../../viewmodels/counter_viewmodel.dart';
import 'preview_screen.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  const BillFormScreen({super.key});

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
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
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final counter = await ref.read(counterViewModelProvider).getCounter();
    setState(() {
      _invoiceController.text = counter.toString();
    });
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
      appBar: AppBar(
        title: const Text('Transport Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionHeader('Invoice Details'),
              _buildTextFormField(
                _invoiceController,
                'SL.No',
                isRequired: true,
                toSetBillNumber: true,
              ),
              _buildTextFormField(_dateController, 'Date', isReadOnly: false),
              _buildTextFormField(
                _truckController,
                'Truck No.',
                isRequired: true,
              ),
              _buildSectionHeader('Recipient Details'),
              _buildTextFormField(
                _recipientController,
                'To (Consignee Name)',
                isRequired: true,
              ),
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
              _buildSectionHeader('Driver Details'),
              _buildTextFormField(_driverController, 'Driver Name'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isGenerating ? null : _generatePdf,
                child:
                    _isGenerating
                        ? const CircularProgressIndicator()
                        : const Text('Generate Transport Bill'),
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
    bool toSetBillNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon:
              toSetBillNumber
                  ? IconButton(
                    onPressed: () {
                      ref
                          .read(counterViewModelProvider)
                          .setCounter(int.parse(_invoiceController.text));
                    },
                    icon: const Icon(Icons.change_circle),
                  )
                  : null,
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
            options
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
        onChanged: (newValue) {
          controller.text = newValue ?? '';
        },
        validator: (value) => value?.isEmpty ?? true ? 'Please select' : null,
      ),
    );
  }

  Future<void> _generatePdf() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isGenerating = true);
      try {
        // Changed this line to use PdfGenerator class
        final pdfFile = await PdfGenerator.generateTransportBill(
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

        final bill = Bill(
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
          totalAmount:
              _calculateTotal(
                _unloadingController.text,
                _hireController.text,
                _tollController.text,
                _weighingController.text,
                _haltingController.text,
                _advanceController.text,
              ).toString(),
          pdfUrl: '',
          userId: ref.read(authViewModelProvider).getCurrentUser()?.uid ?? '',
          createdAt: DateTime.now(),
        );

        final pdfUrl = await ref
            .read(billViewModelProvider)
            .saveTransportBill(bill: bill, pdfFile: pdfFile);

        await ref.read(counterViewModelProvider).incrementCounter();
        await _loadCounter();

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PreviewScreen(pdfFile: pdfFile, pdfUrl: pdfUrl),
          ),
        );

        _formKey.currentState?.reset();
        _dateController.clear();
        _truckController.clear();
        _recipientController.clear();
        _containerController.clear();
        _unloadingController.clear();
        _axleController.clear();
        _destinationController.clear();
        _hireController.clear();
        _tollController.clear();
        _weighingController.clear();
        _haltingController.clear();
        _advanceController.clear();
        _driverController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating bill: $e')));
      } finally {
        if (mounted) {
          setState(() => _isGenerating = false);
        }
      }
    }
  }

  int _calculateTotal(
    String unloading,
    String hire,
    String toll,
    String weighing,
    String halting,
    String advance,
  ) {
    return (int.tryParse(unloading) ?? 0) +
        (int.tryParse(hire) ?? 0) +
        (int.tryParse(toll) ?? 0) +
        (int.tryParse(weighing) ?? 0) +
        (int.tryParse(halting) ?? 0) -
        (int.tryParse(advance) ?? 0);
  }
}
