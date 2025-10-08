import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming these imports are available from your project structure.
import 'blockchain_service.dart';
import 'manufacturer_details_page.dart';
import 'manufacturer_login.dart';

// --- Design System Constants (Consistent with Manufacturer Login Theme) ---
// By reusing the same theme constants, we ensure a seamless brand experience.

/// A centralized place for app colors for the Manufacturer theme.
class _AppColors {
  static const Color primary = Color(0xFF6D2077);
  static const Color primaryLight = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
}

/// Consistent spacing values for layout.
class _AppSpacings {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 20.0;
  static const double xl = 32.0;
}


// --- Main Widget ---

class ManufacturerSignUpPage extends StatefulWidget {
  const ManufacturerSignUpPage({Key? key}) : super(key: key);

  @override
  State<ManufacturerSignUpPage> createState() => _ManufacturerSignUpPageState();
}

class _ManufacturerSignUpPageState extends State<ManufacturerSignUpPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  // For the same polished entrance animations
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
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final username = _usernameController.text.trim();

      // The backend call is preserved exactly as it was, but uses .trim() for cleaner data.
      await _blockchainService.manufacturerSignUp(
        username,
        _emailController.text.trim(),
        _mobileController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account created! Please add your business details."),
            backgroundColor: _AppColors.success, // Use a success color
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        // Navigate to the details page, passing the username to maintain context
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManufacturerDetailsPage(username: username)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: _AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: CustomPaint(
              painter: HeaderPainter(), // Using the consistent header painter
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildSignUpForm(),
                ),
              ),
            ),
          ),
          // Back button for better navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(_AppSpacings.s),
              child: BackButton(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
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
            const Icon(Icons.factory_outlined, color: _AppColors.primary, size: 50),
            const SizedBox(height: _AppSpacings.m),
            const Text(
              "Manufacturer Registration",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: _AppColors.textDark,
              ),
            ),
            const SizedBox(height: _AppSpacings.s),
            const Text(
              "Create your secure account",
              style: TextStyle(fontSize: 16, color: _AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _AppSpacings.xl),
            _buildUsernameField(),
            const SizedBox(height: _AppSpacings.l),
            _buildEmailField(),
            const SizedBox(height: _AppSpacings.l),
            _buildMobileField(),
            const SizedBox(height: _AppSpacings.l),
            _buildPasswordField(),
            const SizedBox(height: _AppSpacings.xl),
            _buildSignUpButton(),
            const SizedBox(height: _AppSpacings.xl),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  // --- Form Field Builder Methods ---

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: _inputDecoration(label: "Username", icon: Icons.person_outline),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a username' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(label: "Email", icon: Icons.email_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter an email';
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Please enter a valid email';
        return null;
      },
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(label: "Mobile Number", icon: Icons.phone_android_outlined),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a mobile number' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(label: "Password", icon: Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _AppColors.textLight,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a password';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  /// Helper to create consistent InputDecoration
  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: _AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.primary, width: 2.0),
      ),
    );
  }

  // --- Action Button & Link Builder Methods ---

  Widget _buildSignUpButton() {
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
        onPressed: _isLoading ? null : _submitAccount,
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        )
            : const Text("Create Account & Continue"),
      ),
    );
  }

  Widget _buildLoginLink() {
    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: const TextStyle(color: _AppColors.textLight, fontSize: 14, fontFamily: 'Inter'),
        children: [
          TextSpan(
            text: 'Login',
            style: const TextStyle(
              color: _AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ManufacturerLoginPage()),
                );
              },
          ),
        ],
      ),
    );
  }
}

/// The custom painter for the purple header wave.
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

