import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'home.dart';
import 'researcher_signup.dart';

class ResearcherLoginPage extends StatefulWidget {
  const ResearcherLoginPage({super.key});

  @override
  State<ResearcherLoginPage> createState() => _ResearcherLoginPageState();
}

class _ResearcherLoginPageState extends State<ResearcherLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // --- MODIFIED LOGIC START ---
      // We call the login transaction. If it fails (e.g., wrong password),
      // the smart contract will revert, and this will throw an error.
      await _blockchainService.researcherLogin(
        _usernameController.text,
        _passwordController.text,
      );

      // If we reach this line without an error, the login was successful.
      if (mounted) {
        final details = await _blockchainService.getResearcherDetails(_usernameController.text);

        Map<String, dynamic> userProfile = {
          'username': details[1],
          'fullName': details[5],
          'organization': details[6],
          'designation': details[7],
          'researchDomain': details[8],
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userProfile: userProfile, userRole: UserRole.researcher)),
        );
      }
      // --- MODIFIED LOGIC END ---
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: Check credentials or error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: CustomPaint(
              painter: HeaderPainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 140),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                width: size.width * 0.87,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text("Researcher Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.grey.shade900,
                          )),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "Enter Username",
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E6091)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E6091)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6091),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 12),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don’t have an account? ",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: ' Sign Up',
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ResearcherSignUpPage()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = 220.0;
    final width = size.width;

    Rect rect = Rect.fromLTWH(0, 0, width, height);
    Gradient gradient = const LinearGradient(
      colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Paint paint = Paint()..shader = gradient.createShader(rect);

    Path path = Path();
    path.lineTo(0, height - 30);
    path.quadraticBezierTo(width / 2, height + 15, width, height - 30);
    path.lineTo(width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

