import 'package:flutter/material.dart';
import 'blockchain_service.dart'; // Import the service
import 'role_selection.dart';   // Import your first screen

// The main function MUST be async to use 'await'.
Future<void> main() async {
  // This line is CRITICAL. It ensures that Flutter's widget binding is
  // initialized before any async operations are performed.
  WidgetsFlutterBinding.ensureInitialized();

  // This line is the CORE of the fix. We are telling the app to
  // wait until the blockchain service is fully loaded and configured
  // before proceeding to build and run the UI.
  try {
    await BlockchainService.instance.initialize();
    print("Blockchain Service Initialized Successfully.");
  } catch (e) {
    // If initialization fails, print the error. In a real app, you might
    // want to show an error screen to the user.
    print("Error initializing Blockchain Service: $e");
  }

  // Only after the service is ready, we run the app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Blockchain Auth App',
      debugShowCheckedModeBanner: false,
      // The app starts at the RoleSelectionPage as intended.
      home: RoleSelectionPage(),
    );
  }
}



