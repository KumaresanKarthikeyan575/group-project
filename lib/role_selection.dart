import 'package:flutter/material.dart';
import 'researcher_login.dart';
import 'manufacturer_login.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(
              painter: HeaderPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                      ]
                  ),
                ),
                const SizedBox(height: 50),
                _buildRoleButton(
                  context,
                  'Researcher',
                  Icons.science_outlined,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResearcherLoginPage()),
                  ),
                ),
                const SizedBox(height: 30),
                _buildRoleButton(
                  context,
                  'Medicine Manufacturer',
                  Icons.business_center_outlined,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManufacturerLoginPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1E6091), backgroundColor: Colors.white,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}

// Re-using the header painter for a consistent look
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double height = 300.0;
    final double width = size.width;

    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    const Gradient gradient = LinearGradient(
      colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final Path path = Path();
    path.lineTo(0, height - 40);
    path.quadraticBezierTo(width / 2, height + 40, width, height - 40);
    path.lineTo(width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
