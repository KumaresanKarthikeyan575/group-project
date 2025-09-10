// SignUp.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:formula/places_services.dart';
import 'main.dart'; // Import for ethClient, sendTransaction, etc.

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  List<String> _institutionSuggestions = [];
  final PlacesService _placesService = PlacesService();

  bool _loading = false;

  Future<void> _fetchInstitutions(String input) async {
    if (input.isEmpty) {
      setState(() => _institutionSuggestions = []);
      return;
    }

    try {
      final suggestions = await _placesService.getInstitutions(input);
      setState(() {
        _institutionSuggestions = suggestions;
      });
    } catch (e) {
      debugPrint("Error fetching institutions: $e");
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final organization = _institutionController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      final txHash = await sendTransaction(
        'usignUp',
        [name, organization, email, password],
        // ensure enough gas
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account Created Successfully! Tx: $txHash')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e, st) {
      debugPrint("Signup error: $e\n$st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomPaint(
              painter: HeaderPainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 140),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x22000000),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField("Full Name", Icons.person, _nameController),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _institutionController,
                        onChanged: _fetchInstitutions,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Institution cannot be empty";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Institution",
                          prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF1E6091)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                      ),
                      if (_institutionSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _institutionSuggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_institutionSuggestions[index]),
                                onTap: () {
                                  _institutionController.text = _institutionSuggestions[index];
                                  setState(() => _institutionSuggestions = []);
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildTextField("Email", Icons.email_outlined, _emailController),
                      const SizedBox(height: 20),
                      _buildTextField("Password", Icons.lock_outline, _passwordController, obscure: true),
                      const SizedBox(height: 20),
                      _buildTextField("Confirm Password", Icons.lock_reset, _confirmController, obscure: true),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E6091),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ", style: TextStyle(fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Center(
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint cannot be empty";
        }
        if (hint == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E6091)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      keyboardType: hint == "Email" ? TextInputType.emailAddress : null,
    );
  }
}

// Header Painter
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double height = 220.0;
    final double width = size.width;

    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    const Gradient gradient = LinearGradient(
      colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final Path path = Path();
    path.lineTo(0, height - 30);
    path.quadraticBezierTo(width / 2, height + 15, width, height - 30);
    path.lineTo(width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
