import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'manufacturer_details_page.dart'; // Navigate to the new details page
import 'manufacturer_login.dart';

class ManufacturerSignUpPage extends StatefulWidget {
  const ManufacturerSignUpPage({Key? key}) : super(key: key);

  @override
  State<ManufacturerSignUpPage> createState() => _ManufacturerSignUpPageState();
}

class _ManufacturerSignUpPageState extends State<ManufacturerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final username = usernameController.text;
      // Use a unique username for each test to avoid "Username is already taken"
      await _blockchainService.manufacturerSignUp(
        username,
        emailController.text,
        mobileController.text,
        passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created! Please add your business details.")),
        );
        // Navigate to the details page, passing the username to maintain context
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManufacturerDetailsPage(username: username)),
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
      appBar: AppBar(title: const Text("Register Manufacturer: Step 1")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Create Your Account", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                TextFormField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: mobileController, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: _isLoading ? null : _submitAccount,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account & Continue'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManufacturerLoginPage()));
                    },
                    child: const Text("Already have an account? Login"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

