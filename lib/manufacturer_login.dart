import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming these imports are available from your project structure.
import 'blockchain_service.dart';
import 'home.dart';
import 'manufacturer_signup.dart';

// --- Design System Constants (Self-Contained) ---
// By defining these here, we maintain consistency without needing a separate file.

/// A centralized place for app colors.
class _AppColors {
  static const Color primary = Color(0xFF6D2077);
  static const Color primaryLight = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
}

/// Consistent spacing values for layout.
class _AppSpacings {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 20.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}


// --- Main Widget ---

class ManufacturerLoginPage extends StatefulWidget {
  const ManufacturerLoginPage({super.key});

  @override
  State<ManufacturerLoginPage> createState() => _ManufacturerLoginPageState();
}

class _ManufacturerLoginPageState extends State<ManufacturerLoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _blockchainService = BlockchainService.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  // For subtle entrance animations
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
    // Crucial for preventing memory leaks
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1. Validate the form first - a production-ready essential.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Give haptic feedback for a better user experience
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      await _blockchainService.manufacturerLogin(
        _usernameController.text.trim(), // Trim whitespace
        _passwordController.text.trim(),
      );

      if (mounted) {
        final details = await _blockchainService.getManufacturerDetails(_usernameController.text.trim());
        Map<String, dynamic> userProfile = {
          'username': details[1],
          'businessName': details[5],
          'businessType': details[6],
          'isVerified': details[12],
        };
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userProfile: userProfile, userRole: UserRole.manufacturer),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: _AppColors.error,
            behavior: SnackBarBehavior.floating, // Modern snackbar style
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
          // The decorative header
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: CustomPaint(
              painter: HeaderPainter(),
            ),
          ),
          // The main content with animations
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginForm(size),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main login form card.
  Widget _buildLoginForm(Size size) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
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
            const Icon(Icons.shield_outlined, color: _AppColors.primary, size: 50),
            const SizedBox(height: _AppSpacings.m),
            const Text(
              "Manufacturer Portal",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: _AppColors.textDark,
              ),
            ),
            const SizedBox(height: _AppSpacings.s),
            const Text(
              "Sign in to access your dashboard",
              style: TextStyle(fontSize: 16, color: _AppColors.textLight),
            ),
            const SizedBox(height: _AppSpacings.xl),
            _buildUsernameField(),
            const SizedBox(height: _AppSpacings.l),
            _buildPasswordField(),
            const SizedBox(height: _AppSpacings.xxl),
            _buildLoginButton(),
            const SizedBox(height: _AppSpacings.xl),
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  /// Builds the username text field.
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: "Username",
        prefixIcon: const Icon(Icons.person_outline),
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
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a username' : null,
    );
  }

  /// Builds the password text field.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _AppColors.textLight,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
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
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a password' : null,
    );
  }

  /// Builds the main login button.
  Widget _buildLoginButton() {
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
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        )
            : const Text("Sign In"),
      ),
    );
  }

  /// Builds the link to the sign-up page.
  Widget _buildSignUpLink() {
    return RichText(
      text: TextSpan(
        text: "Don’t have an account? ",
        style: const TextStyle(color: _AppColors.textLight, fontSize: 14, fontFamily: 'Inter'),
        children: [
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: _AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManufacturerSignUpPage()),
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
