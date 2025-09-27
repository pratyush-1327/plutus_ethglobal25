import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../providers/portfolio_provider.dart';

class BackendApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Your Python backend URL
  late final Dio _dio;

  BackendApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<PortfolioData?> getPortfolio(String walletAddress,
      {int chainId = 1}) async {
    try {
      debugPrint(
          '🌐 API: Fetching portfolio for $walletAddress on chain $chainId from $baseUrl');
      final response = await _dio.get(
        '/portfolio/$walletAddress',
        queryParameters: {'chain_id': chainId},
      );

      debugPrint('🌐 API: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint(
            '🌐 API: Response data keys: ${response.data.keys.toList()}');
        final portfolioData = _parsePortfolioData(response.data);
        debugPrint(
            '🌐 API: Parsed portfolio - Value: \$${portfolioData.totalValue}, Change: ${portfolioData.dayChangePercent}%');
        return portfolioData;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: DioException - ${e.message}');
      debugPrint('❌ API: Response: ${e.response?.data}');
      throw ApiException('Failed to fetch portfolio: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getAnalytics(
    String walletAddress, {
    String timeframe = '7d',
    int chainId = 1,
  }) async {
    try {
      debugPrint('🌐 API: Fetching analytics for $walletAddress');
      final response = await _dio.get(
        '/analytics/$walletAddress',
        queryParameters: {
          'timeframe': timeframe,
          'chain_id': chainId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch analytics - ${e.message}');
      throw ApiException('Failed to fetch analytics: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> getPerformance(String walletAddress,
      {int chainId = 1}) async {
    try {
      debugPrint('🌐 API: Fetching performance for $walletAddress');
      final response = await _dio.get(
        '/performance/$walletAddress',
        queryParameters: {'chain_id': chainId},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch performance - ${e.message}');
      throw ApiException('Failed to fetch performance: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> simulateSwap({
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required double slippage,
    int chainId = 1,
    String? walletAddress,
  }) async {
    try {
      debugPrint('🌐 API: Simulating swap $amountIn $tokenIn -> $tokenOut');
      final response = await _dio.post('/swap/simulate', data: {
        'wallet_address':
            walletAddress ?? '0x0000000000000000000000000000000000000000',
        'token_in': tokenIn,
        'token_out': tokenOut,
        'amount_in': amountIn,
        'slippage': slippage,
        'chain_id': chainId,
      });

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to simulate swap - ${e.message}');
      throw ApiException('Failed to simulate swap: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> simulateAddLiquidity({
    required String token0,
    required String token1,
    required String amount0,
    required String amount1,
    required int tickLower,
    required int tickUpper,
    int chainId = 1,
    String? walletAddress,
  }) async {
    try {
      debugPrint('🌐 API: Simulating add liquidity $token0/$token1');
      final response = await _dio.post('/liquidity/add/simulate', data: {
        'wallet_address':
            walletAddress ?? '0x0000000000000000000000000000000000000000',
        'token0': token0,
        'token1': token1,
        'amount0': amount0,
        'amount1': amount1,
        'tick_lower': tickLower,
        'tick_upper': tickUpper,
        'chain_id': chainId,
      });

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to simulate add liquidity - ${e.message}');
      throw ApiException('Failed to simulate add liquidity: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> getPopularTokens({int chainId = 1}) async {
    try {
      debugPrint('🌐 API: Fetching popular tokens for chain $chainId');
      final response = await _dio.get('/tokens/popular/$chainId');

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch popular tokens - ${e.message}');
      throw ApiException('Failed to fetch popular tokens: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> getSupportedNetworks() async {
    try {
      debugPrint('🌐 API: Fetching supported networks');
      final response = await _dio.get('/networks');

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch networks - ${e.message}');
      throw ApiException('Failed to fetch networks: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> claimPositionFees(
      String positionId, String walletAddress) async {
    try {
      debugPrint('🌐 API: Claiming fees for position $positionId');
      final response = await _dio.post('/positions/$positionId/claim',
          queryParameters: {'wallet_address': walletAddress});

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to claim fees - ${e.message}');
      throw ApiException('Failed to claim fees: ${e.message}');
    } catch (e) {
      debugPrint('❌ API: Unexpected error - $e');
      throw ApiException('Unexpected error: $e');
    }
    return {};
  }

  Future<List<TokenBalance>> getTokenBalances(String walletAddress) async {
    try {
      final response = await _dio.get('/tokens/$walletAddress');

      if (response.statusCode == 200) {
        final List<dynamic> tokensData = response.data['tokens'] ?? [];
        return tokensData.map((token) => _parseTokenBalance(token)).toList();
      }
    } on DioException catch (e) {
      throw ApiException('Failed to fetch token balances: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
    return [];
  }

  Future<List<LPPosition>> getLPPositions(String walletAddress) async {
    try {
      final response = await _dio.get('/uniswap/$walletAddress');

      if (response.statusCode == 200) {
        final List<dynamic> positionsData = response.data['positions'] ?? [];
        return positionsData
            .map((position) => _parseLPPosition(position))
            .toList();
      }
    } on DioException catch (e) {
      throw ApiException('Failed to fetch LP positions: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> simulateClaimFees(
      String poolAddress, String walletAddress) async {
    try {
      final response = await _dio.post('/transaction/simulate-claim', data: {
        'pool_address': poolAddress,
        'wallet_address': walletAddress,
      });

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioException catch (e) {
      throw ApiException('Failed to simulate claim fees: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
    throw ApiException('Failed to simulate transaction');
  }

  PortfolioData _parsePortfolioData(Map<String, dynamic> data) {
    // Parse positions from backend response
    final positionsData = data['positions'] as List<dynamic>? ?? [];

    // Convert backend positions to LP positions
    final lpPositions = positionsData
        .map((position) => LPPosition(
              poolAddress: position['pool_address'] ?? '',
              token0Symbol: position['token0']['symbol'] ?? '',
              token1Symbol: position['token1']['symbol'] ?? '',
              liquidity: double.tryParse(position['liquidity'] ?? '0') ?? 0.0,
              usdValue: (position['value_usd'] as num?)?.toDouble() ?? 0.0,
              feesEarned: 0.0, // TODO: Get from backend
              unclaimedFees: 0.0, // TODO: Get from backend
              impermanentLoss: 0.0, // TODO: Calculate
              minPrice: 0.0, // TODO: Calculate from ticks
              maxPrice: 0.0, // TODO: Calculate from ticks
              currentPrice:
                  (position['token1']['price_usd'] as num?)?.toDouble() ?? 0.0,
              inRange:
                  true, // TODO: Calculate based on current tick vs position ticks
            ))
        .toList();

    // Generate token balances from positions (simplified)
    final tokenBalances = <TokenBalance>[];
    for (final position in positionsData) {
      final token0 = position['token0'];
      final token1 = position['token1'];

      // Add token0 if not already added
      if (!tokenBalances.any((t) => t.address == token0['address'])) {
        tokenBalances.add(TokenBalance(
          symbol: token0['symbol'] ?? '',
          name: token0['name'] ?? '',
          address: token0['address'] ?? '',
          balance: (position['token0_amount'] as num?)?.toDouble() ?? 0.0,
          usdValue: ((position['token0_amount'] as num?)?.toDouble() ?? 0.0) *
              ((token0['price_usd'] as num?)?.toDouble() ?? 0.0),
          price: (token0['price_usd'] as num?)?.toDouble() ?? 0.0,
          dayChange: 0.0, // TODO: Calculate from historical prices
        ));
      }

      // Add token1 if not already added
      if (!tokenBalances.any((t) => t.address == token1['address'])) {
        tokenBalances.add(TokenBalance(
          symbol: token1['symbol'] ?? '',
          name: token1['name'] ?? '',
          address: token1['address'] ?? '',
          balance: (position['token1_amount'] as num?)?.toDouble() ?? 0.0,
          usdValue: ((position['token1_amount'] as num?)?.toDouble() ?? 0.0) *
              ((token1['price_usd'] as num?)?.toDouble() ?? 0.0),
          price: (token1['price_usd'] as num?)?.toDouble() ?? 0.0,
          dayChange: 0.0, // TODO: Calculate from historical prices
        ));
      }
    }

    return PortfolioData(
      totalValue: (data['total_value_usd'] as num?)?.toDouble() ?? 0.0,
      dayChange: (data['pnl_24h_usd'] as num?)?.toDouble() ?? 0.0,
      dayChangePercent: (data['pnl_24h_percent'] as num?)?.toDouble() ?? 0.0,
      tokens: tokenBalances,
      lpPositions: lpPositions,
    );
  }

  TokenBalance _parseTokenBalance(Map<String, dynamic> data) {
    return TokenBalance(
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      usdValue: (data['usd_value'] as num?)?.toDouble() ?? 0.0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      dayChange: (data['day_change'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LPPosition _parseLPPosition(Map<String, dynamic> data) {
    return LPPosition(
      poolAddress: data['pool_address'] ?? '',
      token0Symbol: data['token0_symbol'] ?? '',
      token1Symbol: data['token1_symbol'] ?? '',
      liquidity: (data['liquidity'] as num?)?.toDouble() ?? 0.0,
      usdValue: (data['usd_value'] as num?)?.toDouble() ?? 0.0,
      feesEarned: (data['fees_earned'] as num?)?.toDouble() ?? 0.0,
      unclaimedFees: (data['unclaimed_fees'] as num?)?.toDouble() ?? 0.0,
      impermanentLoss: (data['impermanent_loss'] as num?)?.toDouble() ?? 0.0,
      minPrice: (data['min_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['max_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (data['current_price'] as num?)?.toDouble() ?? 0.0,
      inRange: data['in_range'] ?? false,
    );
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
