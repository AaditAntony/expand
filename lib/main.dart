import 'package:expand/counter_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pdf_generator.dart';
import 'preview_screen.dart';
import 'search_screen.dart';
import 'firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Bill',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/search': (context) => const SearchScreen(),
        '/home': (context) => const TransportBillForm(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FirebaseService().migrateExistingData();
            });
            return const TransportBillForm();
          }
          return const LoginScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await firebaseService.signInWithGoogle();
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
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
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    int savedCounter = await Counterpreference.getCounter();
    setState(() {
      _invoiceController.text = savedCounter.toString();
    });
  }

  Future<void> _setCounter() async {
    await Counterpreference.setCounter(int.parse(_invoiceController.text));
  }

  Future<void> _incrementCounter() async {
    await Counterpreference.incrementCounter();
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
              // Invoice Details
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
                      _setCounter();
                    },
                    icon: Icon(Icons.change_circle),
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
      setState(() => _isGenerating = true);
      try {
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

        // Create bill data map
        final billData = {
          'invoiceNumber': _invoiceController.text,
          'date': _dateController.text,
          'truckNumber': _truckController.text,
          'recipientName': _recipientController.text,
          'containerNumber': _containerController.text,
          'unloadingCharge': _unloadingController.text,
          'axleType': _axleController.text,
          'destination': _destinationController.text,
          'hireCharge': _hireController.text,
          'tollCharge': _tollController.text,
          'weighingCharge': _weighingController.text,
          'haltingCharge': _haltingController.text,
          'advanceAmount': _advanceController.text,
          'driverName': _driverController.text,
          'totalAmount':
              _calculateTotal(
                _unloadingController.text,
                _hireController.text,
                _tollController.text,
                _weighingController.text,
                _haltingController.text,
                _advanceController.text,
              ).toString(),
        };

        // Save to Firebase
        final firebaseService = FirebaseService();
        final pdfUrl = await firebaseService.saveTransportBill(
          billData: billData,
          pdfFile: pdfFile,
        );
        await _incrementCounter();
        _loadCounter();
        // Check if widget is still mounted before navigation
        if (!mounted) return;

        // Navigate to preview screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PreviewScreen(pdfFile: pdfFile, pdfUrl: pdfUrl),
          ),
        );

        // Clear the form after returning from PreviewScreen
        _formKey.currentState?.reset();
        // _invoiceController.clear();
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
