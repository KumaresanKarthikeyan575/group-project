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
  final int _chainId = 11155111; // Sepolia Testnet Chain ID

  late Web3Client _client;
  late Credentials _credentials;

  // You must redeploy your contracts and put the new addresses here
  final String _researcherContractAddress = "0x5b6296f760e862ce3c5760dc15bf383afef033cd";
  late DeployedContract _researcherContract;

  final String _manufacturerContractAddress = "0x870d8ab2dc04e3bb21f9d890c58fad4586101225";
  late DeployedContract _manufacturerContract;

  // The public async initializer.
  Future<void> initialize() async {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);

    final researcherAbi = await rootBundle.loadString('assets/abi/ResearcherAuth.json');
    _researcherContract = DeployedContract(
      ContractAbi.fromJson(researcherAbi, 'ResearcherAuth'),
      EthereumAddress.fromHex(_researcherContractAddress),
    );

    final manufacturerAbi = await rootBundle.loadString('assets/abi/ManufacturerAuth.json');
    _manufacturerContract = DeployedContract(
      ContractAbi.fromJson(manufacturerAbi, 'ManufacturerAuth'),
      EthereumAddress.fromHex(_manufacturerContractAddress),
    );
  }

  // Generic function to send a transaction
  Future<String> _sendTransaction(DeployedContract contract, String functionName, List<dynamic> params) async {
    final function = contract.function(functionName);
    return await _client.sendTransaction(
      _credentials,
      Transaction.callContract(contract: contract, function: function, parameters: params),
      chainId: _chainId,
    );
  }

  // Generic function to make a read-only call
  Future<List<dynamic>> _callFunction(DeployedContract contract, String functionName, List<dynamic> params) async {
    final function = contract.function(functionName);
    return await _client.call(contract: contract, function: function, params: params);
  }

  // --- Researcher specific functions ---
  Future<String> researcherSignUp(String u, String e, String m, String p) => _sendTransaction(_researcherContract, 'signUp', [u, e, m, p]);
  Future<String> researcherAddDetails(String u, String fn, String o, String d, String rd, String c, String s, String co) => _sendTransaction(_researcherContract, 'addOrUpdateDetails', [u, fn, o, d, rd, c, s, co]);
  Future<String> researcherLogin(String u, String p) => _sendTransaction(_researcherContract, 'login', [u, p]);
  Future<String> researcherLogout() => _sendTransaction(_researcherContract, 'logout', []);
  Future<List<dynamic>> getResearcherDetails(String u) async => (await _callFunction(_researcherContract, 'getResearcherDetails', [u]))[0];

  // --- Manufacturer specific functions ---
  Future<String> manufacturerSignUp(String u, String e, String m, String p) => _sendTransaction(_manufacturerContract, 'signUp', [u, e, m, p]);
  Future<String> manufacturerAddDetails(String u, String bn, String bt, String dl, String c, String s, String pc) => _sendTransaction(_manufacturerContract, 'addOrUpdateDetails', [u, bn, bt, dl, c, s, pc]);
  Future<String> manufacturerLogin(String u, String p) => _sendTransaction(_manufacturerContract, 'login', [u, p]);
  Future<String> manufacturerLogout() => _sendTransaction(_manufacturerContract, 'logout', []);
  Future<List<dynamic>> getManufacturerDetails(String u) async => (await _callFunction(_manufacturerContract, 'getManufacturerDetails', [u]))[0];
}

