import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart'; // Using CSC Picker Plus

// --- Dummy imports (replace these with your actual files) ---
import 'blockchain_service.dart';
import 'manufacturer_login.dart';

class _AppColors {
  static const Color primary = Color(0xFF6D2077);
  static const Color primaryLight = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
}

class _AppSpacings {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 20.0;
  static const double xl = 32.0;
}

// -------------------- Main Widget --------------------

class ManufacturerDetailsPage extends StatefulWidget {
  final String username;
  const ManufacturerDetailsPage({Key? key, required this.username}) : super(key: key);

  @override
  State<ManufacturerDetailsPage> createState() => _ManufacturerDetailsPageState();
}

class _ManufacturerDetailsPageState extends State<ManufacturerDetailsPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  final _businessNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _businessType;

  // --- CSC Picker States ---
  String? _countryValue;
  String? _stateValue;
  String? _cityValue;
  bool _locationError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _businessNameController.dispose();
    _licenseNumberController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submitDetails() async {
    final isFormValid = _formKey.currentState!.validate();
    final isLocationValid = _countryValue != null && _stateValue != null && _cityValue != null;

    setState(() => _locationError = !isLocationValid);
    if (!isFormValid || !isLocationValid) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      await _blockchainService.manufacturerAddDetails(
        widget.username,
        _businessNameController.text.trim(),
        _businessType!,
        _licenseNumberController.text.trim(),
        _cityValue!,
        _stateValue!,
        _pincodeController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registration complete! Please log in."),
            backgroundColor: _AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ManufacturerLoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: _AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          SizedBox(width: double.infinity, height: size.height, child: CustomPaint(painter: HeaderPainter())),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildDetailsForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- UI Builders --------------------

  Widget _buildDetailsForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_center_outlined, color: _AppColors.primary, size: 50),
            const SizedBox(height: _AppSpacings.m),
            const Text(
              "Business Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: _AppColors.textDark),
            ),
            const SizedBox(height: _AppSpacings.s),
            Text(
              "Completing profile for: ${widget.username}",
              style: const TextStyle(fontSize: 16, color: _AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _AppSpacings.xl),

            _buildTextField(_businessNameController, "Business Name", Icons.business_outlined),
            const SizedBox(height: _AppSpacings.l),
            _buildBusinessTypeDropdown(),
            const SizedBox(height: _AppSpacings.l),
            _buildTextField(_licenseNumberController, "Drug License Number", Icons.description_outlined),
            const SizedBox(height: _AppSpacings.l),
            _buildLocationPicker(),
            const SizedBox(height: _AppSpacings.l),
            _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: _AppSpacings.xl),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label: label, icon: icon),
      validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
      inputFormatters: keyboardType == TextInputType.number ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _businessType,
      items: ["Retailer", "Distributor", "Wholesaler"]
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _businessType = v),
      decoration: _inputDecoration(label: 'Business Type', icon: Icons.store_mall_directory_outlined),
      validator: (v) => v == null ? 'Please select a business type' : null,
    );
  }

  // ✅ FIXED CSC PICKER LOGIC (use showStates/showCities + defaultCountry enums)
  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CSCPickerPlus(
          // show both state and city dropdowns
          showStates: true,
          showCities: true,

          // flag displayed in dropdown (optional)
          flagState: CountryFlag.ENABLE,

          // language controls (optional)
          countryStateLanguage: CountryStateLanguage.englishOrNative,
          cityLanguage: CityLanguage.native,

          // If you want to preselect a country, use defaultCountry with the CscCountry enum.
          // Example: CscCountry.India
          // Remove/comment this if you don't want a default selection.
          // defaultCountry: CscCountry.India,

          // decorations
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _AppColors.background,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          disabledDropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),

          countryDropdownLabel: "Select Country",
          stateDropdownLabel: "Select State",
          cityDropdownLabel: "Select City",

          // optional styles for the inner dropdown dialog
          selectedItemStyle: const TextStyle(color: Colors.black, fontSize: 14),
          dropdownHeadingStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          dropdownItemStyle: const TextStyle(color: Colors.black, fontSize: 14),

          // callbacks (handle possible nulls defensively)
          onCountryChanged: (value) {
            setState(() {
              _countryValue = value;
              _stateValue = null;
              _cityValue = null;
            });
          },
          onStateChanged: (value) {
            setState(() {
              _stateValue = value;
              _cityValue = null;
            });
          },
          onCityChanged: (value) {
            setState(() {
              _cityValue = value;
            });
          },
        ),

        if (_locationError)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              'Please select a complete location.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _AppColors.primary.withOpacity(0.7)),
      filled: true,
      fillColor: _AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.primary, width: 2.0),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: _isLoading ? null : _submitDetails,
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        )
            : const Text("Complete Registration"),
      ),
    );
  }
}

// -------------------- Header Painter --------------------

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const height = 250.0;
    final width = size.width;
    Rect rect = Rect.fromLTWH(0, 0, width, height);

    Gradient gradient = const LinearGradient(
      colors: [_AppColors.primary, _AppColors.primaryLight],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Paint paint = Paint()..shader = gradient.createShader(rect);
    Path path = Path()
      ..lineTo(0, height - 50)
      ..quadraticBezierTo(width / 2, height, width, height - 50)
      ..lineTo(width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
