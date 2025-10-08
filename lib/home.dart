import 'package:flutter/material.dart';
// Assuming these imports are correctly defined in your project
import 'blockchain_service.dart';
import 'formula_registration_page.dart';
import 'role_selection.dart'; // Must contain UserRole enum

// Assuming UserRole enum is defined here or imported:
// enum UserRole { researcher, manufacturer }

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

  // --- Theme Helpers ---
  // Define primary colors based on the role gradient for consistent theming
  Color get _primaryColor {
    return widget.userRole == UserRole.manufacturer
        ? const Color(0xFF9C27B0) // Purple/Magenta
        : const Color(0xFF5B86E5); // Blue
  }

  Color get _secondaryColor {
    return widget.userRole == UserRole.manufacturer
        ? const Color(0xFF6D2077)
        : const Color(0xFF36D1DC);
  }

  // --- Logic ---

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

  // --- UI Components ---

  /// Builds a clean row for displaying profile details.
  Widget _buildDetailRow(String title, String value, {Color valueColor = Colors.black87, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a modular card for grouping details or actions.
  Widget _buildDashboardCard({
    required Widget content,
    required String title,
    IconData? icon,
    required BuildContext context,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: _primaryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1.5),
            content,
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final String username = widget.userProfile['username'] ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA), // Light background for contrast
      body: Stack(
        children: [
          // --- 1. Header Background (Custom Painter) ---
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: CustomPaint(
              // Increased height to ensure wave effect is prominent
              painter: HeaderPainter(
                isManufacturer: widget.userRole == UserRole.manufacturer,
                height: size.height * 0.35,
              ),
            ),
          ),

          // --- 2. Content (SafeArea & Scrollable List) ---
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0), // Padding to lift content off the top wave
              children: [
                // Welcome Text - Placed inside ListView for proper flow
                Center(
                  child: Text(
                    'Welcome, $username',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Spacing between header text and first card

                // --- A. Profile Summary Card ---
                _buildDashboardCard(
                  title: "Profile Summary",
                  icon: Icons.account_circle,
                  context: context,
                  content: Column(
                    children: [
                      if(widget.userRole == UserRole.researcher) ...[
                        _buildDetailRow('Full Name', widget.userProfile['fullName'], context: context),
                        _buildDetailRow('Organization', widget.userProfile['organization'], context: context),
                        _buildDetailRow('Designation', widget.userProfile['designation'], context: context),
                        _buildDetailRow('Domain', widget.userProfile['researchDomain'], context: context),
                      ] else ...[
                        _buildDetailRow('Business Name', widget.userProfile['businessName'], context: context),
                        _buildDetailRow('Business Type', widget.userProfile['businessType'], context: context),
                        _buildDetailRow(
                            'Verification Status',
                            widget.userProfile['isVerified'] ? 'Verified' : 'Pending',
                            valueColor: widget.userProfile['isVerified'] ? Colors.green.shade600 : Colors.orange.shade600,
                            context: context
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // --- B. Researcher Specific Action Card ---
                if(widget.userRole == UserRole.researcher)
                  _buildDashboardCard(
                    title: "Key Actions",
                    icon: Icons.bolt,
                    context: context,
                    content: Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.token_outlined, color: Colors.white),
                        label: const Text('Register Formula NFT', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormulaRegistrationPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor, // Use role-specific primary color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),

                // --- C. General Actions (Logout) ---
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// --- Custom Painter for the Header ---
class HeaderPainter extends CustomPainter {
  final bool isManufacturer;
  final double height; // Dynamic height passed in

  HeaderPainter({required this.isManufacturer, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final double waveHeight = height;
    final double width = size.width;

    // Gradient colors based on role
    final List<Color> colors = isManufacturer
        ? [const Color(0xFF6D2077), const Color(0xFF9C27B0)] // Purple/Magenta
        : [const Color(0xFF36D1DC), const Color(0xFF5B86E5)]; // Teal/Blue

    final Rect rect = Rect.fromLTWH(0, 0, width, waveHeight);
    final Gradient gradient = LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    final Path path = Path();

    // Draw the main rectangle down to the wave point
    path.lineTo(0, waveHeight - 50);

    // Quadratic Bezier curve for a smooth wave effect
    path.quadraticBezierTo(width / 2, waveHeight + 50, width, waveHeight - 50);

    // Complete the path back to the top right corner
    path.lineTo(width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // Should repaint if height changes
}
