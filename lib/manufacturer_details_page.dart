import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'manufacturer_login.dart';

class ManufacturerDetailsPage extends StatefulWidget {
  final String username;

  const ManufacturerDetailsPage({super.key, required this.username});

  @override
  State<ManufacturerDetailsPage> createState() => _ManufacturerDetailsPageState();
}

class _ManufacturerDetailsPageState extends State<ManufacturerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  // Controllers for business and address details
  final businessNameController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  String? businessType;
  String? state;

  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Call the addOrUpdateDetails function with the username passed from the previous page
      await _blockchainService.manufacturerAddDetails(
        widget.username,
        businessNameController.text,
        businessType!,
        licenseNumberController.text,
        cityController.text,
        state!,
        pincodeController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration complete! Please log in.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ManufacturerLoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
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
      appBar: AppBar(title: const Text("Register Manufacturer: Step 2")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Your Business Details", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text("For user: ${widget.username}", style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 20),

                // Business Details
                TextFormField(controller: businessNameController, decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: businessType,
                  items: ["Retailer", "Distributor", "Wholesaler"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => businessType = v),
                  decoration: const InputDecoration(labelText: 'Business Type', border: OutlineInputBorder()),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(controller: licenseNumberController, decoration: const InputDecoration(labelText: 'Drug License Number', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 20),

                // Address Details
                TextFormField(controller: cityController, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: state,
                  items: ["Tamil Nadu", "Karnataka", "Kerala", "Puducherry"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => state = v),
                  decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(controller: pincodeController, decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: _isLoading ? null : _submitDetails,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
