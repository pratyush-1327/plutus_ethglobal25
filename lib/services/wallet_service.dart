import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  static WalletService? _instance;
  String? _connectedAddress;
  int? _chainId;

  WalletService._();

  static WalletService get instance {
    _instance ??= WalletService._();
    return _instance!;
  }

  bool get isConnected => _connectedAddress != null;
  String? get connectedAddress => _connectedAddress;
  int? get chainId => _chainId;

  /// Connect to MetaMask wallet
  Future<String?> connectMetaMask() async {
    try {
      if (!_isMetaMaskAvailable()) {
        throw Exception(
            'MetaMask is not installed. Please install MetaMask extension.');
      }

      // Request account access
      final accounts = await _requestAccounts();
      if (accounts.isEmpty) {
        throw Exception('No accounts found. Please unlock MetaMask.');
      }

      _connectedAddress = accounts.first;
      _chainId = await _getChainId();

      debugPrint(
          'Connected to MetaMask: $_connectedAddress on chain $_chainId');

      // Listen for account changes
      _setupAccountChangeListener();

      return _connectedAddress;
    } catch (e) {
      debugPrint('MetaMask connection error: $e');
      rethrow;
    }
  }

  /// Connect via WalletConnect (simplified for demo)
  Future<String?> connectWalletConnect() async {
    try {
      // For web, we'll simulate WalletConnect by showing a QR code dialog
      // In a real app, you'd integrate with WalletConnect V2 SDK
      return await _showWalletConnectDialog();
    } catch (e) {
      debugPrint('WalletConnect error: $e');
      rethrow;
    }
  }

  /// Connect to Coinbase Wallet
  Future<String?> connectCoinbaseWallet() async {
    try {
      if (!_isCoinbaseWalletAvailable()) {
        // Redirect to Coinbase Wallet if not available
        html.window.open('https://wallet.coinbase.com/', '_blank');
        throw Exception(
            'Coinbase Wallet not found. Please install the Coinbase Wallet extension or use the mobile app.');
      }

      final accounts = await _requestCoinbaseAccounts();
      if (accounts.isEmpty) {
        throw Exception('No accounts found in Coinbase Wallet.');
      }

      _connectedAddress = accounts.first;
      _chainId = await _getCoinbaseChainId();

      debugPrint('Connected to Coinbase Wallet: $_connectedAddress');
      return _connectedAddress;
    } catch (e) {
      debugPrint('Coinbase Wallet connection error: $e');
      rethrow;
    }
  }

  /// Switch network
  Future<void> switchNetwork(int targetChainId) async {
    try {
      if (_isMetaMaskAvailable()) {
        await _switchEthereumChain(targetChainId);
        _chainId = targetChainId;
      } else {
        throw Exception('Network switching requires MetaMask');
      }
    } catch (e) {
      debugPrint('Network switch error: $e');
      rethrow;
    }
  }

  /// Disconnect wallet
  Future<void> disconnect() async {
    _connectedAddress = null;
    _chainId = null;
    debugPrint('Wallet disconnected');
  }

  /// Get the current account balance
  Future<EtherAmount> getBalance() async {
    if (_connectedAddress == null) {
      throw Exception('No wallet connected');
    }

    try {
      // For web, we'll use the browser's ethereum provider
      final result = await js_util.promiseToFuture(
          js_util.callMethod(js.context['ethereum'], 'request', [
        js_util.jsify({
          'method': 'eth_getBalance',
          'params': [_connectedAddress, 'latest']
        })
      ]));

      final balanceHex = result as String;
      final balanceWei = BigInt.parse(balanceHex.substring(2), radix: 16);
      return EtherAmount.fromBigInt(EtherUnit.wei, balanceWei);
    } catch (e) {
      debugPrint('Balance fetch error: $e');
      rethrow;
    }
  }

  // Private methods for MetaMask integration

  bool _isMetaMaskAvailable() {
    try {
      return js.context.hasProperty('ethereum') &&
          js.context['ethereum'] != null &&
          js.context['ethereum']['isMetaMask'] == true;
    } catch (e) {
      return false;
    }
  }

  bool _isCoinbaseWalletAvailable() {
    try {
      return js.context.hasProperty('ethereum') &&
          js.context['ethereum'] != null &&
          (js.context['ethereum']['isCoinbaseWallet'] == true ||
              js.context['ethereum']['selectedProvider']?['isCoinbaseWallet'] ==
                  true);
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> _requestAccounts() async {
    final completer = Completer<List<String>>();

    try {
      final result = await js_util.promiseToFuture(
          js_util.callMethod(js.context['ethereum'], 'request', [
        js_util.jsify({'method': 'eth_requestAccounts'})
      ]));

      final accounts = (result as List).cast<String>();
      completer.complete(accounts);
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<List<String>> _requestCoinbaseAccounts() async {
    // Similar to MetaMask but for Coinbase Wallet
    return _requestAccounts();
  }

  Future<int> _getChainId() async {
    try {
      final result = await js_util.promiseToFuture(
          js_util.callMethod(js.context['ethereum'], 'request', [
        js_util.jsify({'method': 'eth_chainId'})
      ]));

      final chainIdHex = result as String;
      return int.parse(chainIdHex.substring(2), radix: 16);
    } catch (e) {
      debugPrint('Chain ID fetch error: $e');
      return 1; // Default to mainnet
    }
  }

  Future<int> _getCoinbaseChainId() async {
    return _getChainId();
  }

  Future<void> _switchEthereumChain(int chainId) async {
    final chainIdHex = '0x${chainId.toRadixString(16)}';

    try {
      await js_util.promiseToFuture(
          js_util.callMethod(js.context['ethereum'], 'request', [
        js_util.jsify({
          'method': 'wallet_switchEthereumChain',
          'params': [
            {'chainId': chainIdHex}
          ]
        })
      ]));
    } catch (e) {
      // If chain doesn't exist, add it
      if (e.toString().contains('4902')) {
        await _addEthereumChain(chainId);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _addEthereumChain(int chainId) async {
    final chainConfig = _getChainConfig(chainId);

    await js_util
        .promiseToFuture(js_util.callMethod(js.context['ethereum'], 'request', [
      js_util.jsify({
        'method': 'wallet_addEthereumChain',
        'params': [chainConfig]
      })
    ]));
  }

  Map<String, dynamic> _getChainConfig(int chainId) {
    switch (chainId) {
      case 137: // Polygon
        return {
          'chainId': '0x89',
          'chainName': 'Polygon',
          'nativeCurrency': {
            'name': 'MATIC',
            'symbol': 'MATIC',
            'decimals': 18,
          },
          'rpcUrls': ['https://polygon-rpc.com/'],
          'blockExplorerUrls': ['https://polygonscan.com/'],
        };
      case 10: // Optimism
        return {
          'chainId': '0xa',
          'chainName': 'Optimism',
          'nativeCurrency': {
            'name': 'ETH',
            'symbol': 'ETH',
            'decimals': 18,
          },
          'rpcUrls': ['https://mainnet.optimism.io'],
          'blockExplorerUrls': ['https://optimistic.etherscan.io/'],
        };
      default:
        throw Exception('Unsupported chain ID: $chainId');
    }
  }

  void _setupAccountChangeListener() {
    js.context['ethereum'].callMethod('on', [
      'accountsChanged',
      (accounts) {
        if (accounts.length > 0) {
          _connectedAddress = accounts[0];
          debugPrint('Account changed to: $_connectedAddress');
        } else {
          disconnect();
        }
      }
    ]);

    js.context['ethereum'].callMethod('on', [
      'chainChanged',
      (chainId) {
        _chainId = int.parse(chainId.substring(2), radix: 16);
        debugPrint('Chain changed to: $_chainId');
      }
    ]);
  }

  Future<String?> _showWalletConnectDialog() async {
    // Simplified WalletConnect simulation
    // In a real app, integrate with WalletConnect V2
    final completer = Completer<String?>();

    // Simulate user scanning QR code and connecting
    Timer(const Duration(seconds: 3), () {
      final mockAddress = '0x' +
          DateTime.now()
              .millisecondsSinceEpoch
              .toRadixString(16)
              .padLeft(40, '0');
      _connectedAddress = mockAddress;
      _chainId = 1;
      completer.complete(mockAddress);
    });

    return completer.future;
  }

  /// Sign a message with the connected wallet
  Future<String> signMessage(String message) async {
    if (_connectedAddress == null) {
      throw Exception('No wallet connected');
    }

    try {
      final signature = await js_util.promiseToFuture(
          js_util.callMethod(js.context['ethereum'], 'request', [
        js_util.jsify({
          'method': 'personal_sign',
          'params': [message, _connectedAddress]
        })
      ]));

      return signature as String;
    } catch (e) {
      debugPrint('Message signing error: $e');
      rethrow;
    }
  }
}
