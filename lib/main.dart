// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'SignUp.dart';
import 'Home.dart';
import 'dart:convert';
import 'package:flutter/gestures.dart';

const String rpcUrl = 'https://eth-sepolia.g.alchemy.com/v2/7hMMXwayw6B2KQioz56I6';
const String privateKey = '5dbd60c982eb9039a67c9fe990527e69db31699dfb337f7e253b68bf32f72383'; // Placeholder: Replace with actual private key (the provided was invalid, use a test key)
const String contractAddress = '0xfea149f14b11a09f5edd5cd415c8081f971f1c41';
const int chainId = 11155111; // Correct chain ID for Polygon Amoy
final http.Client httpClient = http.Client();
final Web3Client ethClient = Web3Client(rpcUrl, httpClient);

final String abiCode = '''
[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "email",
				"type": "string"
			}
		],
		"name": "signup",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "email",
				"type": "string"
			}
		],
		"name": "successlogin",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "organization",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			}
		],
		"name": "usignUp",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			}
		],
		"name": "login",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
''';

DeployedContract getContract() {
  final abi = ContractAbi.fromJson(abiCode, 'Pass');
  final address = EthereumAddress.fromHex(contractAddress);
  return DeployedContract(abi, address);
}

Future<List<dynamic>> callFunction(String functionName, List<dynamic> params) async {
  final contract = getContract();
  final function = contract.function(functionName);
  return await ethClient.call(contract: contract, function: function, params: params);
}

Future<String> sendTransaction(String functionName, List<dynamic> params) async {
  final contract = getContract();
  final function = contract.function(functionName);
  final credentials = EthPrivateKey.fromHex(privateKey);
  final transaction = Transaction.callContract(
    contract: contract,
    function: function,
    parameters: params,
  );
  final txHash = await ethClient.sendTransaction(credentials, transaction, chainId: chainId);
  return txHash;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Start with Login as per instruction
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    try {
      final result = await callFunction('login', [email, password]);
      final success = result[0] as bool;
      final id = result[1] as BigInt;
      final name = result[2] as String;
      final organization = result[3] as String;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(id: id.toString(), name: name, organization: organization),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Username",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.grey.shade900,
                      )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter User ID or Email",
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E6091)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text("Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.grey.shade900,
                      )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E6091)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: Colors.grey.shade600, width: 1),
                      ),
                      const Text(
                        "Remember Me",
                        style: TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E6091),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 12),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don’t have an account? ",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: ' Sign Up',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Center(
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
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

// Custom painter for the arc-like curve of the header
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = 220.0;
    final width = size.width;

    Rect rect = Rect.fromLTWH(0, 0, width, height);
    Gradient gradient = const LinearGradient(
      colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)], // Blue + Teal
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Paint paint = Paint()..shader = gradient.createShader(rect);

    Path path = Path();
    path.lineTo(0, height - 30);
    path.quadraticBezierTo(width / 2, height + 15, width, height - 30);
    path.lineTo(width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}