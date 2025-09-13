import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'researcher_details.dart'; // New page for step 2
import 'researcher_login.dart';

class ResearcherSignUpPage extends StatefulWidget {
  const ResearcherSignUpPage({super.key});

  @override
  State<ResearcherSignUpPage> createState() => _ResearcherSignUpPageState();
}

class _ResearcherSignUpPageState extends State<ResearcherSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _blockchainService = BlockchainService.instance;
  bool _isLoading = false;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _blockchainService.researcherSignUp(
        _usernameController.text,
        _emailController.text,
        _mobileController.text,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please add your details.')),
        );
        // Navigate to the details page after step 1 is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResearcherDetailsPage(username: _usernameController.text)),
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
      appBar: AppBar(title: const Text('Researcher Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Username cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Mobile number cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: _isLoading ? null : _createAccount,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account & Continue'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResearcherLoginPage()));
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

