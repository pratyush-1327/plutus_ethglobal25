import 'package:flutter/foundation.dart';
import '../services/backend_api_service.dart';
import '../services/test_data_service.dart';

class PortfolioData {
  final double totalValue;
  final double dayChange;
  final double dayChangePercent;
  final List<TokenBalance> tokens;
  final List<LPPosition> lpPositions;

  PortfolioData({
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.tokens,
    required this.lpPositions,
  });
}

class TokenBalance {
  final String symbol;
  final String name;
  final String address;
  final double balance;
  final double usdValue;
  final double price;
  final double dayChange;

  TokenBalance({
    required this.symbol,
    required this.name,
    required this.address,
    required this.balance,
    required this.usdValue,
    required this.price,
    required this.dayChange,
  });
}

class LPPosition {
  final String poolAddress;
  final String token0Symbol;
  final String token1Symbol;
  final double liquidity;
  final double usdValue;
  final double feesEarned;
  final double unclaimedFees;
  final double impermanentLoss;
  final double minPrice;
  final double maxPrice;
  final double currentPrice;
  final bool inRange;

  LPPosition({
    required this.poolAddress,
    required this.token0Symbol,
    required this.token1Symbol,
    required this.liquidity,
    required this.usdValue,
    required this.feesEarned,
    required this.unclaimedFees,
    required this.impermanentLoss,
    required this.minPrice,
    required this.maxPrice,
    required this.currentPrice,
    required this.inRange,
  });
}

enum PerformanceStatus {
  glowUp, // >+1% gain
  meh, // ±1% change
  frowny, // >-1% loss
}

class PortfolioProvider extends ChangeNotifier {
  PortfolioData? _portfolioData;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;
  final BackendApiService _apiService = BackendApiService();

  PortfolioData? get portfolioData => _portfolioData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  PerformanceStatus get performanceStatus {
    if (_portfolioData == null) return PerformanceStatus.meh;

    final changePercent = _portfolioData!.dayChangePercent;
    if (changePercent > 1.0) return PerformanceStatus.glowUp;
    if (changePercent < -1.0) return PerformanceStatus.frowny;
    return PerformanceStatus.meh;
  }

  Future<void> loadPortfolio(String walletAddress) async {
    debugPrint('🔍 Loading portfolio for address: $walletAddress');
    _currentWalletAddress = walletAddress;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if this is a test wallet first
      debugPrint('📋 Test wallets available: ${TestDataService.testWallets.keys.toList()}');
      if (TestDataService.testWallets.containsKey(walletAddress)) {
        debugPrint('✅ Test wallet found! Loading test data for: $walletAddress');
        _loadTestData(walletAddress);
        return;
      } else {
        debugPrint('❌ Not a test wallet: $walletAddress');
      }

      // Try to fetch from backend API first
      try {
        debugPrint(
            '🌐 Attempting to fetch from backend API for: $walletAddress');
        final portfolioData = await _apiService.getPortfolio(walletAddress);
        if (portfolioData != null) {
          debugPrint(
              '✅ Backend API returned data - Value: \$${portfolioData.totalValue}, Change: ${portfolioData.dayChangePercent}%');
          _portfolioData = portfolioData;
          _lastUpdated = DateTime.now();
          _isLoading = false;
          notifyListeners();
          return;
        } else {
          debugPrint('❌ Backend API returned null data');
        }
      } catch (apiError) {
        debugPrint('❌ Backend API error: $apiError');
      }

      // Fallback to mock data if backend is not available
      await Future.delayed(const Duration(seconds: 2));

      // Mock data for demo
      _portfolioData = PortfolioData(
        totalValue: 15432.50,
        dayChange: 234.15,
        dayChangePercent: 1.54,
        tokens: [
          TokenBalance(
            symbol: 'ETH',
            name: 'Ethereum',
            address: '0x0000000000000000000000000000000000000000',
            balance: 5.25,
            usdValue: 12500.00,
            price: 2380.95,
            dayChange: 2.1,
          ),
          TokenBalance(
            symbol: 'USDC',
            name: 'USD Coin',
            address: '0xa0b86a33e6b85ac8c5686b501f2ad39d91473bbf',
            balance: 1500.00,
            usdValue: 1500.00,
            price: 1.00,
            dayChange: -0.01,
          ),
        ],
        lpPositions: [
          LPPosition(
            poolAddress: '0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640',
            token0Symbol: 'USDC',
            token1Symbol: 'ETH',
            liquidity: 1432.50,
            usdValue: 1432.50,
            feesEarned: 45.20,
            unclaimedFees: 12.80,
            impermanentLoss: -2.5,
            minPrice: 2200.0,
            maxPrice: 2600.0,
            currentPrice: 2380.95,
            inRange: true,
          ),
        ],
      );

      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = 'Failed to load portfolio: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _currentWalletAddress;

  void refresh() {
    if (_currentWalletAddress != null) {
      loadPortfolio(_currentWalletAddress!);
    }
  }

  void _loadTestData(String walletAddress) async {
    _currentWalletAddress = walletAddress;
    debugPrint('🧪 Loading test data for: $walletAddress');
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading

    final summary = TestDataService.getPortfolioSummary(walletAddress);
    final tokenHoldings = TestDataService.generateTokenHoldings(walletAddress);
    final lpPositions = TestDataService.generateLPPositions(walletAddress);

    debugPrint('📊 Test portfolio summary: totalValue=${summary.totalValue}, dayChange=${summary.dayChangePercent}%');
    debugPrint('🪙 Test tokens: ${tokenHoldings.length} tokens');
    debugPrint('🦄 Test LP positions: ${lpPositions.length} positions');

    // Convert test data to our portfolio format
    final tokens = tokenHoldings
        .map((token) => TokenBalance(
              symbol: token.symbol,
              name: token.name,
              address: token.address,
              balance: double.tryParse(token.balance) ?? 0.0,
              usdValue: token.value,
              price: token.price,
              dayChange: token.change24h,
            ))
        .toList();

    final lpPositionList = lpPositions
        .map((pos) => LPPosition(
              poolAddress: '${pos.token0Address}-${pos.token1Address}',
              token0Symbol: pos.token0Symbol,
              token1Symbol: pos.token1Symbol,
              liquidity: double.tryParse(pos.liquidity) ?? 0.0,
              usdValue: pos.currentValue,
              feesEarned: pos.feesValueUsd,
              unclaimedFees: pos.feesValueUsd,
              impermanentLoss: pos.impermanentLoss,
              minPrice: 0.0, // Calculate based on ticks in real implementation
              maxPrice: 0.0, // Calculate based on ticks in real implementation
              currentPrice: 0.0, // Get from price feed
              inRange: pos.inRange,
            ))
        .toList();

    _portfolioData = PortfolioData(
      totalValue: summary.totalValue,
      dayChange: summary.dayChange,
      dayChangePercent: summary.dayChangePercent,
      tokens: tokens,
      lpPositions: lpPositionList,
    );

    _lastUpdated = DateTime.now();
    _isLoading = false;
    debugPrint('✅ Test data loaded successfully! Portfolio value: ${_portfolioData?.totalValue}');
    notifyListeners();
  }

  Future<void> claimFees(String poolAddress) async {
    try {
      // Try to simulate the transaction via backend
      final result = await _apiService.simulateClaimFees(
          poolAddress, 'current_wallet_address');
      debugPrint('Fee claiming simulation result: $result');
    } catch (e) {
      debugPrint('Fee claiming simulation failed: $e');
    }
  }
}
