import 'package:dio/dio.dart';
import '../providers/portfolio_provider.dart';

class BackendApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Your Python backend URL (updated port)
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

  Future<PortfolioData?> getPortfolio(String walletAddress) async {
    try {
      final response = await _dio.get('/portfolio/$walletAddress');

      if (response.statusCode == 200) {
        return _parsePortfolioData(response.data);
      }
    } on DioException catch (e) {
      throw ApiException('Failed to fetch portfolio: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
    return null;
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
    final tokensData = data['tokens'] as List<dynamic>? ?? [];
    final lpPositionsData = data['lp_positions'] as List<dynamic>? ?? [];

    return PortfolioData(
      totalValue: (data['total_value'] as num?)?.toDouble() ?? 0.0,
      dayChange: (data['day_change'] as num?)?.toDouble() ?? 0.0,
      dayChangePercent: (data['day_change_percent'] as num?)?.toDouble() ?? 0.0,
      tokens: tokensData.map((token) => _parseTokenBalance(token)).toList(),
      lpPositions: lpPositionsData
          .map((position) => _parseLPPosition(position))
          .toList(),
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
