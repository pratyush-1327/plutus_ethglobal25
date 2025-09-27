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
  String? _currentWalletAddress;
  final BackendApiService _apiService = BackendApiService();

  PortfolioData? get portfolioData => _portfolioData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  String? get currentWalletAddress => _currentWalletAddress;

  PerformanceStatus get performanceStatus {
    if (_portfolioData == null) return PerformanceStatus.meh;

    final changePercent = _portfolioData!.dayChangePercent;
    if (changePercent > 1.0) return PerformanceStatus.glowUp;
    if (changePercent < -1.0) return PerformanceStatus.frowny;
    return PerformanceStatus.meh;
  }

  Future<void> loadPortfolio(String walletAddress, {int chainId = 1}) async {
    debugPrint(
        '🔍 Loading portfolio for address: $walletAddress on chain $chainId');
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
            '🌐 Attempting to fetch from backend API for: $walletAddress on chain $chainId');
        final portfolioData =
            await _apiService.getPortfolio(walletAddress, chainId: chainId);
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

      // Fallback to chain-specific mock data if backend is not available
      await Future.delayed(const Duration(seconds: 2));
      _portfolioData = _generateChainSpecificMockData(chainId);

      _lastUpdated = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading portfolio: $e');
      _error = 'Failed to load portfolio: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  PortfolioData _generateChainSpecificMockData(int chainId) {
    final chainNames = {1: 'Ethereum', 137: 'Polygon', 10: 'Optimism'};
    final chainName = chainNames[chainId] ?? 'Unknown';

    debugPrint('🔗 Generating mock data for $chainName (Chain ID: $chainId)');

    // Adjust values based on chain
    final multiplier = chainId == 1 ? 1.0 : (chainId == 137 ? 0.3 : 0.6);
    final baseValue = 15432.50 * multiplier;

    final tokens = <TokenBalance>[];
    final positions = <LPPosition>[];

    // Chain-specific tokens
    if (chainId == 1) {
      // Ethereum tokens
      tokens.addAll([
        TokenBalance(
          symbol: 'ETH',
          name: 'Ethereum',
          address: '0x0000000000000000000000000000000000000000',
          balance: 5.25 * multiplier,
          usdValue: 12500.00 * multiplier,
          price: 2380.95,
          dayChange: 2.1,
        ),
        TokenBalance(
          symbol: 'USDC',
          name: 'USD Coin',
          address: '0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2',
          balance: 2932.50 * multiplier,
          usdValue: 2932.50 * multiplier,
          price: 1.00,
          dayChange: 0.01,
        ),
      ]);

      positions.addAll([
        LPPosition(
          poolAddress: '0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8',
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidity: 15000.00 * multiplier,
          usdValue: 8532.50 * multiplier,
          feesEarned: 125.30 * multiplier,
          unclaimedFees: 12.45 * multiplier,
          impermanentLoss: -23.12 * multiplier,
          minPrice: 2200.00,
          maxPrice: 2800.00,
          currentPrice: 2380.95,
          inRange: true,
        ),
      ]);
    } else if (chainId == 137) {
      // Polygon tokens
      tokens.addAll([
        TokenBalance(
          symbol: 'MATIC',
          name: 'Polygon',
          address: '0x0000000000000000000000000000000000001010',
          balance: 5000.0 * multiplier,
          usdValue: 4250.00 * multiplier,
          price: 0.85,
          dayChange: 1.5,
        ),
        TokenBalance(
          symbol: 'USDC',
          name: 'USD Coin',
          address: '0x2791bca1f2de4661ed88a30c99a7a9449aa84174',
          balance: 1200.0 * multiplier,
          usdValue: 1200.00 * multiplier,
          price: 1.00,
          dayChange: 0.01,
        ),
      ]);

      positions.addAll([
        LPPosition(
          poolAddress: '0x3F5228d0e7D75467366be7De2c31D0d098bA2C23',
          token0Symbol: 'MATIC',
          token1Symbol: 'USDC',
          liquidity: 8000.00 * multiplier,
          usdValue: 3200.50 * multiplier,
          feesEarned: 45.20 * multiplier,
          unclaimedFees: 8.15 * multiplier,
          impermanentLoss: -5.30 * multiplier,
          minPrice: 0.70,
          maxPrice: 1.20,
          currentPrice: 0.85,
          inRange: true,
        ),
      ]);
    } else if (chainId == 10) {
      // Optimism tokens
      tokens.addAll([
        TokenBalance(
          symbol: 'ETH',
          name: 'Ethereum',
          address: '0x0000000000000000000000000000000000000000',
          balance: 3.8 * multiplier,
          usdValue: 9047.60 * multiplier,
          price: 2380.95,
          dayChange: 2.1,
        ),
        TokenBalance(
          symbol: 'OP',
          name: 'Optimism',
          address: '0x4200000000000000000000000000000000000042',
          balance: 800.0 * multiplier,
          usdValue: 2000.00 * multiplier,
          price: 2.50,
          dayChange: 3.2,
        ),
      ]);

      positions.addAll([
        LPPosition(
          poolAddress: '0x68F5C0A2DE713a54991E01858Fd27a3832401849',
          token0Symbol: 'ETH',
          token1Symbol: 'OP',
          liquidity: 12000.00 * multiplier,
          usdValue: 5500.00 * multiplier,
          feesEarned: 85.40 * multiplier,
          unclaimedFees: 15.25 * multiplier,
          impermanentLoss: -12.80 * multiplier,
          minPrice: 900.00,
          maxPrice: 1100.00,
          currentPrice: 952.38, // ETH/OP ratio
          inRange: true,
        ),
      ]);
    }

    return PortfolioData(
      totalValue: baseValue,
      dayChange: 234.15 * multiplier,
      dayChangePercent: 1.54,
      tokens: tokens,
      lpPositions: positions,
    );
  }

  void _loadTestData(String walletAddress) {
    debugPrint('📊 Loading test data for: $walletAddress');

    final testWalletData = TestDataService.testWallets[walletAddress];
    if (testWalletData == null) {
      debugPrint('❌ No test data found for: $walletAddress');
      _portfolioData = PortfolioData(
        totalValue: 0.0,
        dayChange: 0.0,
        dayChangePercent: 0.0,
        tokens: [],
        lpPositions: [],
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Generate detailed test data from the wallet summary
    final tokenHoldings = TestDataService.generateTokenHoldings(walletAddress);
    final lpPositions = TestDataService.generateLPPositions(walletAddress);

    // Convert to portfolio data models
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

    final positions = lpPositions
        .map((pos) => LPPosition(
              poolAddress:
                  '${pos.token0Address}-${pos.token1Address}-${pos.fee}',
              token0Symbol: pos.token0Symbol,
              token1Symbol: pos.token1Symbol,
              liquidity: double.tryParse(pos.liquidity) ?? 0.0,
              usdValue: pos.currentValue,
              feesEarned: pos.feesValueUsd,
              unclaimedFees: (double.tryParse(pos.unclaimedFees0) ?? 0.0) +
                  (double.tryParse(pos.unclaimedFees1) ?? 0.0),
              impermanentLoss: pos.impermanentLoss,
              minPrice: 0.0, // TODO: Calculate from ticks
              maxPrice: 0.0, // TODO: Calculate from ticks
              currentPrice: pos.currentValue /
                  (pos.initialValue > 0 ? pos.initialValue : 1.0),
              inRange: pos.inRange,
            ))
        .toList();

    // Calculate total value
    final totalValue = testWalletData.estimatedValue.toDouble();
    final dayChangeUsd = totalValue * (testWalletData.dayChange / 100);

    _portfolioData = PortfolioData(
      totalValue: totalValue,
      dayChange: dayChangeUsd,
      dayChangePercent: testWalletData.dayChange,
      tokens: tokens,
      lpPositions: positions,
    );

    debugPrint(
        '✅ Loaded test data - Value: \$${_portfolioData!.totalValue}, Change: ${_portfolioData!.dayChangePercent}%');

    _lastUpdated = DateTime.now();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentWalletAddress != null) {
      await loadPortfolio(_currentWalletAddress!);
    }
  }

  void clearData() {
    _portfolioData = null;
    _currentWalletAddress = null;
    _error = null;
    _lastUpdated = null;
    _isLoading = false;
    notifyListeners();
  }

  // New methods for swap functionality
  Future<Map<String, dynamic>> simulateSwap({
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required double slippage,
    int chainId = 1,
  }) async {
    try {
      return await _apiService.simulateSwap(
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        amountIn: amountIn,
        slippage: slippage,
        chainId: chainId,
      );
    } catch (e) {
      debugPrint('❌ Error simulating swap: $e');
      rethrow;
    }
  }

  // New methods for analytics
  Future<Map<String, dynamic>> getAnalytics(
    String walletAddress, {
    String timeframe = '7d',
    int chainId = 1,
  }) async {
    try {
      return await _apiService.getAnalytics(
        walletAddress,
        timeframe: timeframe,
        chainId: chainId,
      );
    } catch (e) {
      debugPrint('❌ Error fetching analytics: $e');
      rethrow;
    }
  }

  // New methods for liquidity management
  Future<Map<String, dynamic>> simulateAddLiquidity({
    required String token0,
    required String token1,
    required String amount0,
    required String amount1,
    required int tickLower,
    required int tickUpper,
    int chainId = 1,
  }) async {
    try {
      return await _apiService.simulateAddLiquidity(
        token0: token0,
        token1: token1,
        amount0: amount0,
        amount1: amount1,
        tickLower: tickLower,
        tickUpper: tickUpper,
        chainId: chainId,
      );
    } catch (e) {
      debugPrint('❌ Error simulating add liquidity: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> claimFees(String positionId) async {
    if (_currentWalletAddress == null) {
      throw Exception('No wallet connected');
    }

    try {
      return await _apiService.claimPositionFees(
          positionId, _currentWalletAddress!);
    } catch (e) {
      debugPrint('❌ Error claiming fees: $e');
      rethrow;
    }
  }
}
