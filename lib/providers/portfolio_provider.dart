import 'package:flutter/foundation.dart';
import '../services/backend_api_service.dart';

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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from backend API first
      try {
        final portfolioData = await _apiService.getPortfolio(walletAddress);
        if (portfolioData != null) {
          _portfolioData = portfolioData;
          _lastUpdated = DateTime.now();
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (apiError) {
        debugPrint('Backend API unavailable, using mock data: $apiError');
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

  void refresh() {
    if (_portfolioData != null) {
      // Refresh with current wallet address
      // In real implementation, get address from WalletProvider
      loadPortfolio('0x1234567890abcdef1234567890abcdef12345678');
    }
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
