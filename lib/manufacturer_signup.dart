// This is the updated BusinessRegister.dart
import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'manufacturer_login.dart';

class ManufacturerSignUpPage extends StatefulWidget {
  const ManufacturerSignUpPage({Key? key}) : super(key: key);

  @override
  State<ManufacturerSignUpPage> createState() => _ManufacturerSignUpPageState();
}

class _ManufacturerSignUpPageState extends State<ManufacturerSignUpPage> {
  int _currentStep = 0;
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  // Controllers for all fields
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final businessNameController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  String? businessType;
  String? state;

  // This method is now called on the final submit.
  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    try {
      // Step 1: Sign up the account
      await _blockchainService.manufacturerSignUp(
        usernameController.text,
        emailController.text,
        mobileController.text,
        passwordController.text,
      );

      // Step 2: Add the business details
      await _blockchainService.manufacturerAddDetails(
        usernameController.text,
        businessNameController.text,
        businessType!,
        licenseNumberController.text,
        cityController.text,
        state!,
        pincodeController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please login.")),
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
    // Using the stepper UI from your BusinessRegister.dart
    // The main change is in the `onStepContinue` logic.
    return Scaffold(
      appBar: AppBar(title: const Text("Register Your Business")),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Final step, call the registration function
            _submitRegistration();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? "Submit" : "Continue"),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Back"),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Account
          Step(
            title: const Text("Account"),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextFormField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
                TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextFormField(controller: mobileController, decoration: const InputDecoration(labelText: 'Mobile')),
                TextFormField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              ],
            ),
          ),
          // Step 2: Business
          Step(
            title: const Text("Business"),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                TextFormField(controller: businessNameController, decoration: const InputDecoration(labelText: 'Business Name')),
                DropdownButtonFormField<String>(
                  value: businessType,
                  items: ["Retailer", "Distributor", "Wholesaler"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => businessType = v),
                  decoration: const InputDecoration(labelText: 'Business Type'),
                ),
                TextFormField(controller: licenseNumberController, decoration: const InputDecoration(labelText: 'Drug License Number')),
              ],
            ),
          ),
          // Step 3: Address
          Step(
            title: const Text("Address"),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                TextFormField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                DropdownButtonFormField<String>(
                  value: state,
                  items: ["Tamil Nadu", "Karnataka", "Kerala"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => state = v),
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                TextFormField(controller: pincodeController, decoration: const InputDecoration(labelText: 'Pincode')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
