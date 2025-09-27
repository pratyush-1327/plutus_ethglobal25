import 'package:flutter/foundation.dart';
import '../services/web3_service.dart';
import '../services/wallet_service.dart';
import '../services/test_data_service.dart';

enum WalletConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

enum SupportedNetwork {
  ethereum('Ethereum Mainnet', 1, '0x627EEA'),
  polygon('Polygon', 137, '0x8247E5'),
  optimism('Optimism', 10, '0xFF0420');

  const SupportedNetwork(this.name, this.chainId, this.colorHex);

  final String name;
  final int chainId;
  final String colorHex;
}

class WalletProvider extends ChangeNotifier {
  WalletConnectionStatus _connectionStatus =
      WalletConnectionStatus.disconnected;
  String? _connectedAddress;
  SupportedNetwork _selectedNetwork = SupportedNetwork.ethereum;
  String? _walletType;
  final WalletConnectService _walletConnectService =
      WalletConnectService.instance;
  final WalletService _realWalletService = WalletService.instance;

  WalletConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectedAddress => _connectedAddress;
  SupportedNetwork get selectedNetwork => _selectedNetwork;
  String? get walletType => _walletType;

  bool get isConnected => _connectionStatus == WalletConnectionStatus.connected;

  String get truncatedAddress {
    if (_connectedAddress == null) return '';
    if (_connectedAddress!.length < 10) return _connectedAddress!;
    return '${_connectedAddress!.substring(0, 6)}...${_connectedAddress!.substring(_connectedAddress!.length - 4)}';
  }

  Future<void> connectWallet({required String walletType}) async {
    _connectionStatus = WalletConnectionStatus.connecting;
    _walletType = walletType;
    notifyListeners();

    try {
      String? address;

      // Use real wallet service based on wallet type
      if (kIsWeb) {
        switch (walletType.toLowerCase()) {
          case 'metamask':
            address = await _realWalletService.connectMetaMask();
            break;
          case 'walletconnect':
            address = await _realWalletService.connectWalletConnect();
            break;
          case 'coinbase':
            address = await _realWalletService.connectCoinbaseWallet();
            break;
          default:
            throw Exception('Unsupported wallet type: $walletType');
        }
      } else {
        // Fallback to mock service for non-web platforms
        address = await _walletConnectService.connectWallet(walletType);
      }

      if (address != null) {
        _connectedAddress = address;
        _connectionStatus = WalletConnectionStatus.connected;
        debugPrint('Connected to $walletType wallet: $_connectedAddress');
      } else {
        throw Exception('Failed to get wallet address');
      }
    } catch (e) {
      _connectionStatus = WalletConnectionStatus.error;
      debugPrint('Failed to connect wallet: $e');
    }

    notifyListeners();
  }

  Future<void> connectWalletByAddress({
    required String address,
    required String walletType,
  }) async {
    _connectionStatus = WalletConnectionStatus.connecting;
    _walletType = walletType;
    notifyListeners();

    try {
      // Validate the address format
      if (!_isValidEthereumAddress(address)) {
        throw Exception('Invalid Ethereum address format');
      }

      // For manual address connection, we just store the address
      // This is a read-only connection for portfolio viewing
      _connectedAddress = address.toLowerCase();
      _connectionStatus = WalletConnectionStatus.connected;

      // Check if this is a test wallet and log test data availability
      if (TestDataService.testWallets.containsKey(_connectedAddress)) {
        debugPrint('Test wallet detected - rich test data available');
      }

      debugPrint(
          'Connected to $walletType wallet by address: $_connectedAddress');
    } catch (e) {
      _connectionStatus = WalletConnectionStatus.error;
      debugPrint('Failed to connect wallet by address: $e');
    }

    notifyListeners();
  }

  bool _isValidEthereumAddress(String address) {
    // Basic Ethereum address validation
    final cleanAddress = address.trim();
    if (cleanAddress.length != 42) return false;
    if (!cleanAddress.startsWith('0x')) return false;

    // Check if all characters after 0x are valid hex
    final hexPart = cleanAddress.substring(2);
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart);
  }

  void disconnect() async {
    if (kIsWeb) {
      await _realWalletService.disconnect();
    } else {
      await _walletConnectService.disconnect();
    }
    _connectionStatus = WalletConnectionStatus.disconnected;
    _connectedAddress = null;
    _walletType = null;
    notifyListeners();
  }

  void switchNetwork(SupportedNetwork network) async {
    _selectedNetwork = network;

    // If connected via real wallet service, try to switch network
    if (kIsWeb && isConnected) {
      try {
        await _realWalletService.switchNetwork(network.chainId);
        debugPrint('Switched to ${network.name}');
      } catch (e) {
        debugPrint('Failed to switch network: $e');
        // Don't fail the UI update even if network switch fails
      }
    }

    notifyListeners();
  }

  Future<void> addToken(String tokenAddress) async {
    // TODO: Implement add token functionality
    debugPrint('Adding token: $tokenAddress');
  }
}
