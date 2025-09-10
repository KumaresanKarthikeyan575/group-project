// Home.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String id;
  final String name;
  final String organization;

  const HomePage({
    super.key,
    required this.id,
    required this.name,
    required this.organization,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showDashboard = false;

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
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.dashboard_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  _showDashboard = !_showDashboard;
                });
              },
            ),
          ),
          if (_showDashboard)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: size.width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x22000000),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID: ${widget.id}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    Text(
                      'Name: ${widget.name}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    Text(
                      'Organization: ${widget.organization}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          Center(
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
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add Formula Registration logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6091),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text(
                      'Formula Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add Apply for License logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6091),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text(
                      'Apply for License',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Center(
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
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