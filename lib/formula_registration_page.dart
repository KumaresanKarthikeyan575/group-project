import 'package:flutter/material.dart';
import 'blockchain_service.dart';

class FormulaRegistrationPage extends StatefulWidget {
  const FormulaRegistrationPage({super.key});

  @override
  State<FormulaRegistrationPage> createState() => _FormulaRegistrationPageState();
}

class _FormulaRegistrationPageState extends State<FormulaRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  // Controllers for all form fields
  final _batchController = TextEditingController();
  final _medicineNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _dosageController = TextEditingController();
  final _strengthController = TextEditingController();
  final _mfrNameController = TextEditingController();
  final _mfrLicenseController = TextEditingController();
  DateTime? _dom;
  DateTime? _doe;

  Future<void> _selectDate(BuildContext context, bool isDom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDom) {
          _dom = picked;
        } else {
          _doe = picked;
        }
      });
    }
  }

  Future<void> _submitFormula() async {
    // Validate all form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields.')),
      );
      return;
    }
    if (_dom == null || _doe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both manufacture and expiry dates.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert dates to Unix timestamps (seconds since epoch) for Solidity
      final domTimestamp = BigInt.from(_dom!.millisecondsSinceEpoch ~/ 1000);
      final doeTimestamp = BigInt.from(_doe!.millisecondsSinceEpoch ~/ 1000);

      await _blockchainService.registerFormula(
        _batchController.text,
        _medicineNameController.text,
        _ingredientsController.text,
        _dosageController.text,
        _strengthController.text,
        _mfrNameController.text,
        _mfrLicenseController.text,
        domTimestamp,
        doeTimestamp,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formula registered successfully! Waiting for CDSCO verification.')),
        );
        Navigator.pop(context); // Go back to the home page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering formula: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _batchController.dispose();
    _medicineNameController.dispose();
    _ingredientsController.dispose();
    _dosageController.dispose();
    _strengthController.dispose();
    _mfrNameController.dispose();
    _mfrLicenseController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula NFT Registration'),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_batchController, 'Batch Number / Lot Number'),
              _buildTextFormField(_medicineNameController, 'Medicine Name (Trade Name)'),
              _buildTextFormField(_ingredientsController, 'Active Ingredient(s)'),
              _buildTextFormField(_dosageController, 'Dosage Form (e.g., Tablet)'),
              _buildTextFormField(_strengthController, 'Strength (e.g., 500 mg)'),
              _buildTextFormField(_mfrNameController, 'Manufacturer\'s Name'),
              _buildTextFormField(_mfrLicenseController, 'Manufacturer\'s License Number'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDatePicker('Manufacture Date', _dom, () => _selectDate(context, true)),
                  _buildDatePicker('Expiry Date', _doe, () => _selectDate(context, false)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitFormula,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit for Verification', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onPressed) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(date == null ? 'Select Date' : "${date.toLocal()}".split(' ')[0]),
          onPressed: onPressed,
        ),
      ],
    );
  }
}

