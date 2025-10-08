import 'package:flutter/material.dart';
import 'blockchain_service.dart';

class _AppColors {
  static const Color primary = Color(0xFF6D2077);
  static const Color primaryLight = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
}

class FormulaRegistrationPage extends StatefulWidget {
  const FormulaRegistrationPage({super.key});

  @override
  State<FormulaRegistrationPage> createState() =>
      _FormulaRegistrationPageState();
}

class _FormulaRegistrationPageState extends State<FormulaRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  // Controllers
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields.')),
      );
      return;
    }
    if (_dom == null || _doe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Please select both manufacture and expiry dates.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
          const SnackBar(
            backgroundColor: _AppColors.success,
            content: Text('✅ Formula registered successfully! Waiting for CDSCO verification.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _AppColors.error,
            content: Text('Error registering formula: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _AppColors.background,
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _AppColors.primary,
                    _AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text(
              'Formula NFT Registration',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter Formula Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      _buildTextFormField(
                        controller: _batchController,
                        label: 'Batch Number / Lot Number',
                        icon: Icons.qr_code_2_outlined,
                      ),
                      _buildTextFormField(
                        controller: _medicineNameController,
                        label: 'Medicine Name (Trade Name)',
                        icon: Icons.medical_services_outlined,
                      ),
                      _buildTextFormField(
                        controller: _ingredientsController,
                        label: 'Active Ingredient(s)',
                        icon: Icons.biotech_outlined,
                      ),
                      _buildTextFormField(
                        controller: _dosageController,
                        label: 'Dosage Form (e.g., Tablet)',
                        icon: Icons.local_pharmacy_outlined,
                      ),
                      _buildTextFormField(
                        controller: _strengthController,
                        label: 'Strength (e.g., 500 mg)',
                        icon: Icons.science_outlined,
                      ),
                      _buildTextFormField(
                        controller: _mfrNameController,
                        label: 'Manufacturer\'s Name',
                        icon: Icons.factory_outlined,
                      ),
                      _buildTextFormField(
                        controller: _mfrLicenseController,
                        label: 'Manufacturer\'s License Number',
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              'Manufacture Date',
                              _dom,
                                  () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDatePicker(
                              'Expiry Date',
                              _doe,
                                  () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitFormula,
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        label: const Text(
                          'Submit for Verification',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Overlay loader
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _AppColors.primary),
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: _AppColors.textLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
        (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.calendar_today_outlined,
              color: _AppColors.primary),
          label: Text(
            date == null ? 'Select Date' : "${date.toLocal()}".split(' ')[0],
            style: const TextStyle(fontSize: 15, color: _AppColors.textDark),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: _AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
