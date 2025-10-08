import 'package:flutter/material.dart';
// These imports are assumed to be correctly defined in your project
import 'blockchain_service.dart';
import 'researcher_login.dart';
import 'places_services.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';

// Assuming the following services are defined elsewhere:
// class BlockchainService { static final instance = BlockchainService(); Future<void> researcherAddDetails(String username, String fullName, String org, String designation, String domain, String city, String state, String country) async {} }
// class PlacesService { Future<List<String>> getInstitutions(String input) async => Future.value([]); }


class ResearcherDetailsPage extends StatefulWidget {
  final String username;
  const ResearcherDetailsPage({super.key, required this.username});

  @override
  State<ResearcherDetailsPage> createState() => _ResearcherDetailsPageState();
}

class _ResearcherDetailsPageState extends State<ResearcherDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _orgController = TextEditingController();
  final _designationController = TextEditingController();
  final _domainController = TextEditingController();

  // Controllers to hold CSCPickerPlus output
  String _country = '';
  String _state = '';
  String _city = '';

  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  final _placesService = PlacesService();
  List<String> _institutionSuggestions = [];

  // --- Helper Methods ---

  /// Fetches institution suggestions from the PlacesService.
  Future<void> _fetchInstitutions(String input) async {
    if (input.isEmpty) {
      setState(() => _institutionSuggestions = []);
      return;
    }
    try {
      final suggestions = await _placesService.getInstitutions(input);
      setState(() {
        // Limit suggestions for a cleaner UI
        _institutionSuggestions = suggestions.take(5).toList();
      });
    } catch (e) {
      debugPrint("Error fetching institutions: $e");
    }
  }

  /// Handles form submission and blockchain interaction.
  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate location fields using the state variables updated by CSCPicker
    if (_country.isEmpty || _state.isEmpty || _city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Country, State, and City')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _blockchainService.researcherAddDetails(
        widget.username,
        _fullNameController.text,
        _orgController.text,
        _designationController.text,
        _domainController.text,
        _city,
        _state,
        _country,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully! Please log in.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ResearcherLoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Builds a modern, professional TextFormField with a filled style.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)),
        labelText: label,
        // Modern, professional filled style
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Remove default border for 'filled'
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  /// Helper method for consistent Card grouping and section titles.
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2, // Slight lift for visual separation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const Divider(height: 20, thickness: 1.5),
            ...children.map((widget) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: widget,
            )),
          ],
        ),
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Define a primary color for a professional application theme
    // Note: If you have a MaterialApp theme, this should respect it.
    // For this example, we'll ensure a professional look.
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Researcher Profile'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary, // Strong primary color
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Welcome Header
                  Text(
                    "Hello, ${widget.username}!",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Provide your professional details to complete registration.",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // --- Personal Info Card ---
                  _buildSectionCard(
                    title: "👤 Personal Information",
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Full Name is required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Professional Info Card ---
                  _buildSectionCard(
                    title: "🏢 Professional Details",
                    children: [
                      // Organization Input and Suggestions
                      _buildTextField(
                        controller: _orgController,
                        label: "Organization / Institution",
                        icon: Icons.business_outlined,
                        validator: (v) => v!.isEmpty ? 'Organization is required' : null,
                        onChanged: _fetchInstitutions,
                      ),
                      if (_institutionSuggestions.isNotEmpty)
                        Card(
                          margin: const EdgeInsets.only(top: 8),
                          elevation: 1, // Lower elevation for suggestions
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListView.builder(
                            shrinkWrap: true,
                            // Limit suggestions to keep UI clean
                            itemCount: _institutionSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _institutionSuggestions[index];
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: const Icon(Icons.school, size: 20),
                                title: Text(suggestion, style: theme.textTheme.bodyMedium),
                                onTap: () {
                                  setState(() {
                                    _orgController.text = suggestion;
                                    _institutionSuggestions = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      // Designation
                      _buildTextField(
                        controller: _designationController,
                        label: "Designation",
                        icon: Icons.work_outline,
                        validator: (v) => v!.isEmpty ? 'Designation is required' : null,
                      ),
                      // Domain
                      _buildTextField(
                        controller: _domainController,
                        label: "Research Domain (e.g., AI, Genetics, Metallurgy)",
                        icon: Icons.science_outlined,
                        validator: (v) => v!.isEmpty ? 'Research Domain is required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Location Info Card ---
                  _buildSectionCard(
                    title: "📍 Location",
                    children: [
                      // Location Picker (Visually Integrated)
                      CSCPickerPlus (
                        countryStateLanguage: CountryStateLanguage.englishOrNative,
                        onCountryChanged: (value) {
                          setState(() {
                            _country = value ?? '';
                            _state = '';
                            _city = '';
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            _state = value ?? '';
                            _city = '';
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            _city = value ?? '';
                          });
                        },
                        // Styling the picker to match the rest of the form
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade50, // Match the text field fill color
                        ),
                        // Dropdown styles to match input aesthetics
                        selectedItemStyle: theme.textTheme.bodyLarge,
                        dropdownHeadingStyle: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      // Using the internal state variables for location validation/submission
                      // We don't need text fields for location anymore, simplifying the UI.
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button (Strong CTA)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox.shrink()
                          : const Icon(Icons.send, color: Colors.white),
                      label: _isLoading
                          ? const Center(
                          child: SizedBox(
                            height: 24, width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                      )
                          : const Text("Submit Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _submitDetails,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loader Overlay (Remains the same)
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}