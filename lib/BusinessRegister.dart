import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BusinessRegister extends StatefulWidget {
  const BusinessRegister({Key? key}) : super(key: key);

  @override
  State<BusinessRegister> createState() => _BusinessRegisterState();
}

class _BusinessRegisterState extends State<BusinessRegister> {
  int _currentStep = 0;
  bool _obscurePassword = true;

  // Form keys for each step
  final _accountFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String? businessType;
  String? state;
  String? _selectedFileName;

  InputDecoration _boxDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  ButtonStyle _blueButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _nextStep() {
    bool isValid = false;

    // Validate only the current step's form
    if (_currentStep == 0) {
      isValid = _accountFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isValid = _businessFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isValid = _addressFormKey.currentState?.validate() ?? false;
    }

    if (isValid) {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Form Submitted Successfully")),
        );
      }
    } else {
      // Provide feedback if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Register Your Business",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          steps: [
            // Step 1: Account
            Step(
              title: const Text("Account"),
              isActive: _currentStep >= 0,
              content: Form(
                key: _accountFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: _boxDecoration("Username", Icons.person),
                      validator: (value) =>
                      value!.isEmpty ? "Username is required" : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            decoration: _boxDecoration("Email", Icons.email),
                            validator: (value) =>
                            value!.isEmpty ? "Email is required" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: _blueButtonStyle(),
                          child: const Text("Verify"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: _boxDecoration("Mobile", Icons.phone),
                            validator: (value) =>
                            value!.isEmpty ? "Mobile is required" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: _blueButtonStyle(),
                          child: const Text("Verify"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: _boxDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Password is required" : null,
                    ),
                  ],
                ),
              ),
            ),

            // Step 2: Business
            Step(
              title: const Text("Business"),
              isActive: _currentStep >= 1,
              content: Form(
                key: _businessFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: businessNameController,
                      decoration: _boxDecoration("Business Name", Icons.business),
                      validator: (value) =>
                      value!.isEmpty ? "Business name is required" : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: _boxDecoration("Business Type", Icons.category),
                      value: businessType,
                      items: ["Retailer", "Distributor", "Wholesaler"]
                          .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => businessType = value),
                      validator: (value) =>
                      value == null ? "Business type is required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: licenseNumberController,
                      decoration: _boxDecoration(
                          "Drug License Number", Icons.confirmation_number),
                      validator: (value) =>
                      value!.isEmpty ? "License number is required" : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      style: _blueButtonStyle(),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload License Copy"),
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Selected File: $_selectedFileName",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Step 3: Address
            Step(
              title: const Text("Address"),
              isActive: _currentStep >= 2,
              content: Form(
                key: _addressFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: _boxDecoration("Address", Icons.home),
                      validator: (value) =>
                      value!.isEmpty ? "Address is required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cityController,
                      decoration: _boxDecoration("City", Icons.location_city),
                      validator: (value) =>
                      value!.isEmpty ? "City is required" : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: _boxDecoration("State", Icons.map),
                      value: state,
                      items: [
                        "Tamil Nadu",
                        "Karnataka",
                        "Kerala",
                        "Maharashtra"
                      ]
                          .map((st) =>
                          DropdownMenuItem(value: st, child: Text(st)))
                          .toList(),
                      onChanged: (value) => setState(() => state = value),
                      validator: (value) =>
                      value == null ? "State is required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: _boxDecoration("Pincode", Icons.pin),
                      validator: (value) =>
                      value!.isEmpty ? "Pincode is required" : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
          controlsBuilder: (context, details) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: _blueButtonStyle(),
                    child: Text(_currentStep == 2 ? "Submit" : "Continue"),
                  ),
                  const SizedBox(width: 10),
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text("Back"),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    businessNameController.dispose();
    licenseNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
}