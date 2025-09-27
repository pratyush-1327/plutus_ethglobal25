import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class Web3Service {
  static Map<int, String> get _networkRpcUrls => AppConfig.networkRpcUrls;

  static Map<String, String> get _contractAddresses =>
      AppConfig.contractAddresses;

  final int chainId;
  late String _rpcUrl;

  Web3Service({required this.chainId}) {
    // Validate configuration before initializing
    AppConfig.validateConfiguration();
    _rpcUrl = _networkRpcUrls[chainId] ?? _networkRpcUrls[1]!;
  }

  Future<List<String>> getTokenBalances(
      String walletAddress, List<String> tokenAddresses) async {
    // Mock implementation - replace with actual web3dart calls
    debugPrint('Fetching token balances for $walletAddress');
    debugPrint('Tokens: $tokenAddresses');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock balances
    return tokenAddresses.map((token) => '1000.0').toList();
  }

  Future<List<int>> getUserLPPositions(String walletAddress) async {
    // Mock implementation - replace with actual web3dart calls
    debugPrint('Fetching LP positions for $walletAddress');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock position IDs
    return [1, 2, 3];
  }

  Future<Map<String, dynamic>> getPositionDetails(int positionId) async {
    // Mock implementation - replace with actual web3dart calls
    debugPrint('Fetching details for position $positionId');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock position data
    return {
      'tokenId': positionId,
      'token0': '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf', // USDC
      'token1': '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
      'fee': 3000,
      'tickLower': -887220,
      'tickUpper': 887220,
      'liquidity': '1000000000000000000',
    };
  }

  Future<TransactionData> buildClaimFeesTransaction(
      String walletAddress, int positionId) async {
    debugPrint('Building claim fees transaction for position $positionId');

    // Simulate building transaction
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock transaction data
    return TransactionData(
      to: _contractAddresses['UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER']!,
      data:
          '0x0c49ccbe000000000000000000000000000000000000000000000000000000000000000$positionId'
          '000000000000000000000000${walletAddress.substring(2)}'
          '000000000000000000000000${walletAddress.substring(2)}',
      gasLimit: '200000',
      gasPrice: '20000000000', // 20 Gwei
      value: '0',
    );
  }

  Future<String> getTokenSymbol(String tokenAddress) async {
    // Mock implementation
    const tokenSymbols = {
      '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf': 'USDC',
      '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2': 'WETH',
      '0x0000000000000000000000000000000000000000': 'ETH',
    };

    return tokenSymbols[tokenAddress] ?? 'UNKNOWN';
  }

  Future<double> getTokenPrice(String tokenAddress) async {
    // Mock implementation
    const tokenPrices = {
      '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf': 1.0, // USDC
      '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2': 2380.95, // ETH
      '0x0000000000000000000000000000000000000000': 2380.95, // ETH
    };

    return tokenPrices[tokenAddress] ?? 0.0;
  }

  String getExplorerUrl(String txHash) {
    switch (chainId) {
      case 1:
        return 'https://etherscan.io/tx/$txHash';
      case 137:
        return 'https://polygonscan.com/tx/$txHash';
      case 10:
        return 'https://optimistic.etherscan.io/tx/$txHash';
      default:
        return 'https://etherscan.io/tx/$txHash';
    }
  }
}

class TransactionData {
  final String to;
  final String data;
  final String gasLimit;
  final String gasPrice;
  final String value;

  TransactionData({
    required this.to,
    required this.data,
    required this.gasLimit,
    required this.gasPrice,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'to': to,
        'data': data,
        'gasLimit': gasLimit,
        'gasPrice': gasPrice,
        'value': value,
      };
}

class WalletConnectService {
  static WalletConnectService? _instance;

  WalletConnectService._();

  static WalletConnectService get instance {
    _instance ??= WalletConnectService._();
    return _instance!;
  }

  Future<String?> connectWallet(String walletType) async {
    debugPrint('Connecting to $walletType wallet...');

    // Mock wallet connection
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different connection scenarios
    if (walletType == 'MetaMask') {
      return '0x742b15eCfC4B7b4B87c82A7b7a1b4F61bB3F6C6a'; // Mock address
    } else if (walletType == 'WalletConnect') {
      return '0x8ba1f109551bD432803012645Hac136c0c8b4B1c';
    } else if (walletType == 'Coinbase') {
      return '0x123456789abcdef123456789abcdef1234567890';
    }

    throw Exception('Failed to connect to $walletType');
  }

  Future<void> disconnect() async {
    debugPrint('Disconnecting wallet...');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<String> signMessage(String message) async {
    debugPrint('Signing message: $message');
    await Future.delayed(const Duration(seconds: 1));

    // Mock signature
    return '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1b';
  }

  Future<String> sendTransaction(TransactionData transaction) async {
    debugPrint('Sending transaction: ${transaction.toJson()}');
    await Future.delayed(const Duration(seconds: 3));

    // Mock transaction hash
    return '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab';
  }
}
