// This is the updated Home1.dart
import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'formula_registration_page.dart'; // <-- Import the new page
import 'role_selection.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final UserRole userRole;

  const HomePage({
    super.key,
    required this.userProfile,
    required this.userRole,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _blockchainService = BlockchainService.instance;

  Future<void> _logout() async {
    try {
      if (widget.userRole == UserRole.researcher) {
        await _blockchainService.researcherLogout();
      } else {
        await _blockchainService.manufacturerLogout();
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
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
              painter: HeaderPainter(isManufacturer: widget.userRole == UserRole.manufacturer),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Center(
              child: Text(
                'Welcome, ${widget.userProfile['username']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 30, offset: Offset(0, 12))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                  ),
                  const Divider(height: 20),
                  // Displaying details based on user role
                  if(widget.userRole == UserRole.researcher) ...[
                    _buildDetailRow('Full Name:', widget.userProfile['fullName']),
                    _buildDetailRow('Organization:', widget.userProfile['organization']),
                    _buildDetailRow('Designation:', widget.userProfile['designation']),
                    _buildDetailRow('Domain:', widget.userProfile['researchDomain']),
                    const SizedBox(height: 20),
                    // --- NEW: NFT Button for Researchers only ---
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Formula NFT Registration'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormulaRegistrationPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildDetailRow('Business Name:', widget.userProfile['businessName']),
                    _buildDetailRow('Business Type:', widget.userProfile['businessType']),
                    _buildDetailRow('Verification:', widget.userProfile['isVerified'] ? 'Verified' : 'Pending',
                        valueColor: widget.userProfile['isVerified'] ? Colors.green : Colors.orange),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }
}

class HeaderPainter extends CustomPainter {
  final bool isManufacturer;
  HeaderPainter({required this.isManufacturer});

  @override
  void paint(Canvas canvas, Size size) {
    const double height = 220.0;
    final double width = size.width;
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    final Gradient gradient = LinearGradient(
      colors: isManufacturer
          ? [const Color(0xFF6D2077), const Color(0xFF9C27B0)]
          : [const Color(0xFF36D1DC), const Color(0xFF5B86E5)],
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

