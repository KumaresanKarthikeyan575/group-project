import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'researcher_login.dart';
import 'places_services.dart'; // <-- Import the places service

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
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  // --- Start: Changes for Places Service ---
  final _placesService = PlacesService();
  List<String> _institutionSuggestions = [];

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
  // --- End: Changes for Places Service ---

  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _blockchainService.researcherAddDetails(
        widget.username,
        _fullNameController.text,
        _orgController.text,
        _designationController.text,
        _domainController.text,
        _cityController.text,
        _stateController.text,
        _countryController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully! Please log in.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ResearcherLoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Welcome, ${widget.username}!", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text("Please provide your professional details to complete registration."),
              const SizedBox(height: 20),
              TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),

              // --- Start: UI Changes for Places Service ---
              TextFormField(
                controller: _orgController,
                decoration: const InputDecoration(labelText: 'Organization / Institution', border: OutlineInputBorder()),
                onChanged: _fetchInstitutions, // Fetch suggestions as user types
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              if (_institutionSuggestions.isNotEmpty)
                SizedBox(
                  height: 150, // Limit the height of the suggestions list
                  child: Card(
                    elevation: 3,
                    child: ListView.builder(
                      itemCount: _institutionSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _institutionSuggestions[index];
                        return ListTile(
                          title: Text(suggestion),
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
                ),
              // --- End: UI Changes for Places Service ---

              const SizedBox(height: 16),
              TextFormField(controller: _designationController, decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _domainController, decoration: const InputDecoration(labelText: 'Research Domain', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _countryController, decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: _isLoading ? null : _submitDetails,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

