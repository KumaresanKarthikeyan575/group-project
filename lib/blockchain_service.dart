import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// This enum helps in identifying the user's role throughout the app.
enum UserRole { researcher, manufacturer }

class BlockchainService {
  // --- Start of Singleton Pattern ---
  BlockchainService._();
  static final BlockchainService instance = BlockchainService._();
  // --- End of Singleton Pattern ---

  // --- CONFIGURATION ---
  final String _rpcUrl = 'https://eth-sepolia.g.alchemy.com/v2/7hMMXwayw6B2KQioz56I6';
  final String _privateKey = '160fe44ba095dee007557d6a639498331b50914c81c418838a0b575e784e2fdb';
  final int _chainId = 11155111;

  late Web3Client _client;
  late Credentials _credentials;

  // --- Contract Addresses (IMPORTANT: DEPLOY AND PASTE NEW ADDRESSES HERE) ---
  final String _researcherContractAddress = "0xaba4b66eeff5825d9410c9fcd578ca901d63041c";
  final String _manufacturerContractAddress = "0x7a7d86a423b26e5c6cc88e90dbfeb194af3f4934";
  final String _formulaNftContractAddress = "0xfc145c861e98ed888e64398b4194ed7b0b79bf2a"; // <-- ADD NEW NFT CONTRACT ADDRESS

  // --- Contract Objects ---
  late DeployedContract _researcherContract;
  late DeployedContract _manufacturerContract;
  late DeployedContract _formulaNftContract; // <-- New contract object

  // --- Contract Functions ---
  // Researcher
  late ContractFunction _researcherSignUp, _researcherLogin, _researcherAddDetails, _researcherGetDetails, _researcherLogout;
  // Manufacturer
  late ContractFunction _manufacturerSignUp, _manufacturerLogin, _manufacturerAddDetails, _manufacturerGetDetails, _manufacturerLogout;
  // NFT
  late ContractFunction _registerFormula; // <-- New function

  Future<void> initialize() async {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);

    // Initialize Researcher Contract
    final researcherAbi = await rootBundle.loadString('assets/abi/ResearcherAuth.json');
    _researcherContract = DeployedContract(ContractAbi.fromJson(researcherAbi, 'ResearcherAuth'), EthereumAddress.fromHex(_researcherContractAddress));

    // Initialize Manufacturer Contract
    final manufacturerAbi = await rootBundle.loadString('assets/abi/ManufacturerAuth.json');
    _manufacturerContract = DeployedContract(ContractAbi.fromJson(manufacturerAbi, 'ManufacturerAuth'), EthereumAddress.fromHex(_manufacturerContractAddress));

    // --- NEW: Initialize FormulaNFT Contract ---
    final formulaNftAbi = await rootBundle.loadString('assets/abi/FormulaNFT.json');
    _formulaNftContract = DeployedContract(ContractAbi.fromJson(formulaNftAbi, 'FormulaNFT'), EthereumAddress.fromHex(_formulaNftContractAddress));

    // Map functions for easy access
    _researcherSignUp = _researcherContract.function('signUp');
    _researcherLogin = _researcherContract.function('login');
    _researcherAddDetails = _researcherContract.function('addOrUpdateDetails');
    _researcherGetDetails = _researcherContract.function('getResearcherDetails');
    _researcherLogout = _researcherContract.function('logout');

    _manufacturerSignUp = _manufacturerContract.function('signUp');
    _manufacturerLogin = _manufacturerContract.function('login');
    _manufacturerAddDetails = _manufacturerContract.function('addOrUpdateDetails');
    _manufacturerGetDetails = _manufacturerContract.function('getManufacturerDetails');
    _manufacturerLogout = _manufacturerContract.function('logout');

    // --- NEW: Map NFT function ---
    _registerFormula = _formulaNftContract.function('registerFormula');
  }

  // Generic helper functions
  Future<String> _sendTransaction(DeployedContract contract, ContractFunction function, List<dynamic> params) async {
    final transaction = Transaction.callContract(contract: contract, function: function, parameters: params);
    return await _client.sendTransaction(_credentials, transaction, chainId: _chainId);
  }

  Future<List<dynamic>> _callFunction(DeployedContract contract, ContractFunction function, List<dynamic> params) async {
    return await _client.call(contract: contract, function: function, params: params);
  }

  // --- Auth Functions (Unchanged) ---
  Future<String> researcherSignUp(String username, String email, String mobile, String password) => _sendTransaction(_researcherContract, _researcherSignUp, [username, email, mobile, password]);
  Future<String> researcherLogin(String username, String password) => _sendTransaction(_researcherContract, _researcherLogin, [username, password]);
  Future<String> researcherAddDetails(String username, String fullName, String org, String designation, String domain, String city, String state, String country) => _sendTransaction(_researcherContract, _researcherAddDetails, [username, fullName, org, designation, domain, city, state, country]);
  Future<List> getResearcherDetails(String username) async => (await _callFunction(_researcherContract, _researcherGetDetails, [username]))[0];
  Future<String> researcherLogout() => _sendTransaction(_researcherContract, _researcherLogout, []);

  Future<String> manufacturerSignUp(String username, String email, String mobile, String password) => _sendTransaction(_manufacturerContract, _manufacturerSignUp, [username, email, mobile, password]);
  Future<String> manufacturerLogin(String username, String password) => _sendTransaction(_manufacturerContract, _manufacturerLogin, [username, password]);
  Future<String> manufacturerAddDetails(String username, String businessName, String businessType, String license, String city, String state, String pincode) => _sendTransaction(_manufacturerContract, _manufacturerAddDetails, [username, businessName, businessType, license, city, state, pincode]);
  Future<List> getManufacturerDetails(String username) async => (await _callFunction(_manufacturerContract, _manufacturerGetDetails, [username]))[0];
  Future<String> manufacturerLogout() => _sendTransaction(_manufacturerContract, _manufacturerLogout, []);

  // --- NEW: Formula NFT Function ---
  Future<String> registerFormula(
      String batchNumber,
      String medicineName,
      String activeIngredients,
      String dosageForm,
      String strength,
      String manufacturerName,
      String manufacturerLicense,
      BigInt dateOfManufacture,
      BigInt dateOfExpiry,
      ) async {
    return await _sendTransaction(_formulaNftContract, _registerFormula, [
      batchNumber,
      medicineName,
      activeIngredients,
      dosageForm,
      strength,
      manufacturerName,
      manufacturerLicense,
      dateOfManufacture,
      dateOfExpiry
    ]);
  }
}

