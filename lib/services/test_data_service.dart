/// Test data service providing realistic portfolio and LP position data
/// for development and demonstration purposes
class TestDataService {
  static const Map<String, TestWalletData> testWallets = {
    '0xd8da6bf26964af9d7eed9e03e53415d37aa96045': TestWalletData(
      name: 'Vitalik Buterin',
      description: 'Ethereum co-founder with diverse token holdings',
      estimatedValue: 2500000,
      dayChange: 5.2,
      tokenCount: 15,
      lpPositions: 2,
    ),
    '0xe592427a0aece92de3edee1f18e0157c05861564': TestWalletData(
      name: 'Uniswap V3 Router',
      description: 'Official Uniswap router with massive volume',
      estimatedValue: 50000000,
      dayChange: 1.8,
      tokenCount: 50,
      lpPositions: 25,
    ),
    '0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503': TestWalletData(
      name: 'Large DeFi User',
      description: 'Active liquidity provider across multiple pools',
      estimatedValue: 750000,
      dayChange: -2.1,
      tokenCount: 8,
      lpPositions: 12,
    ),
    '0x8eb8a3b98659cce290402893d0123abb75e3ab28': TestWalletData(
      name: 'Whale Wallet',
      description: 'High-value holder with long-term positions',
      estimatedValue: 12000000,
      dayChange: 3.7,
      tokenCount: 20,
      lpPositions: 8,
    ),
    '0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf': TestWalletData(
      name: 'Popular LP Provider',
      description: 'Focused on yield farming and liquidity provision',
      estimatedValue: 180000,
      dayChange: 4.1,
      tokenCount: 12,
      lpPositions: 18,
    ),
  };

  /// Generate realistic token holdings for a test wallet
  static List<TokenHolding> generateTokenHoldings(String address) {
    final walletData = testWallets[address];
    if (walletData == null) return [];

    final tokens = [
      TokenHolding(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: '125.45',
        value: 298080.0,
        price: 2380.95,
        change24h: 2.1,
        address: '0x0000000000000000000000000000000000000000',
      ),
      TokenHolding(
        symbol: 'USDC',
        name: 'USD Coin',
        balance: '50000.0',
        value: 50000.0,
        price: 1.0,
        change24h: 0.01,
        address: '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf',
      ),
      TokenHolding(
        symbol: 'WBTC',
        name: 'Wrapped Bitcoin',
        balance: '2.15',
        value: 129000.0,
        price: 60000.0,
        change24h: 1.8,
        address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
      ),
      TokenHolding(
        symbol: 'UNI',
        name: 'Uniswap',
        balance: '1250.0',
        value: 8750.0,
        price: 7.0,
        change24h: -3.2,
        address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
      ),
      TokenHolding(
        symbol: 'LINK',
        name: 'Chainlink',
        balance: '500.0',
        value: 7500.0,
        price: 15.0,
        change24h: 4.5,
        address: '0x514910771AF9Ca656af840dff83E8264EcF986CA',
      ),
    ];

    // Return a subset based on the wallet's token count
    return tokens.take(walletData.tokenCount).toList();
  }

  /// Generate realistic LP positions for a test wallet
  static List<LPPosition> generateLPPositions(String address) {
    final walletData = testWallets[address];
    if (walletData == null) return [];

    final positions = [
      LPPosition(
        tokenId: 123456,
        token0Symbol: 'USDC',
        token1Symbol: 'ETH',
        token0Address: '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf',
        token1Address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
        fee: 3000,
        liquidity: '15000000000000000000',
        tickLower: -276320,
        tickUpper: -276300,
        currentValue: 25000.0,
        initialValue: 24200.0,
        impermanentLoss: -1.2,
        unclaimedFees0: '12.45',
        unclaimedFees1: '0.0052',
        feesValueUsd: 32.50,
        inRange: true,
      ),
      LPPosition(
        tokenId: 789012,
        token0Symbol: 'WBTC',
        token1Symbol: 'ETH',
        token0Address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
        token1Address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
        fee: 3000,
        liquidity: '8500000000000000000',
        tickLower: -887220,
        tickUpper: 887220,
        currentValue: 18500.0,
        initialValue: 19100.0,
        impermanentLoss: 0.8,
        unclaimedFees0: '0.0008',
        unclaimedFees1: '0.0125',
        feesValueUsd: 78.25,
        inRange: true,
      ),
      LPPosition(
        tokenId: 345678,
        token0Symbol: 'UNI',
        token1Symbol: 'USDC',
        token0Address: '0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984',
        token1Address: '0xA0b86a33E6B85aC8c5686b501F2aD39D91473bbf',
        fee: 3000,
        liquidity: '5200000000000000000',
        tickLower: -276400,
        tickUpper: -276250,
        currentValue: 3200.0,
        initialValue: 3400.0,
        impermanentLoss: -4.2,
        unclaimedFees0: '8.75',
        unclaimedFees1: '42.30',
        feesValueUsd: 103.45,
        inRange: false,
      ),
    ];

    // Return positions based on the wallet's LP count
    return positions.take(walletData.lpPositions).toList();
  }

  /// Get portfolio summary for a test wallet
  static PortfolioSummary getPortfolioSummary(String address) {
    final walletData = testWallets[address];
    if (walletData == null) {
      return PortfolioSummary(
        totalValue: 0,
        dayChange: 0,
        dayChangePercent: 0,
        tokenCount: 0,
        lpPositionCount: 0,
      );
    }

    final dayChangeValue =
        walletData.estimatedValue * walletData.dayChange / 100;

    return PortfolioSummary(
      totalValue: walletData.estimatedValue,
      dayChange: dayChangeValue,
      dayChangePercent: walletData.dayChange,
      tokenCount: walletData.tokenCount,
      lpPositionCount: walletData.lpPositions,
    );
  }
}

class TestWalletData {
  final String name;
  final String description;
  final double estimatedValue;
  final double dayChange; // percentage
  final int tokenCount;
  final int lpPositions;

  const TestWalletData({
    required this.name,
    required this.description,
    required this.estimatedValue,
    required this.dayChange,
    required this.tokenCount,
    required this.lpPositions,
  });
}

class TokenHolding {
  final String symbol;
  final String name;
  final String balance;
  final double value;
  final double price;
  final double change24h;
  final String address;

  const TokenHolding({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.value,
    required this.price,
    required this.change24h,
    required this.address,
  });
}

class LPPosition {
  final int tokenId;
  final String token0Symbol;
  final String token1Symbol;
  final String token0Address;
  final String token1Address;
  final int fee;
  final String liquidity;
  final int tickLower;
  final int tickUpper;
  final double currentValue;
  final double initialValue;
  final double impermanentLoss; // percentage
  final String unclaimedFees0;
  final String unclaimedFees1;
  final double feesValueUsd;
  final bool inRange;

  const LPPosition({
    required this.tokenId,
    required this.token0Symbol,
    required this.token1Symbol,
    required this.token0Address,
    required this.token1Address,
    required this.fee,
    required this.liquidity,
    required this.tickLower,
    required this.tickUpper,
    required this.currentValue,
    required this.initialValue,
    required this.impermanentLoss,
    required this.unclaimedFees0,
    required this.unclaimedFees1,
    required this.feesValueUsd,
    required this.inRange,
  });
}

class PortfolioSummary {
  final double totalValue;
  final double dayChange;
  final double dayChangePercent;
  final int tokenCount;
  final int lpPositionCount;

  const PortfolioSummary({
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.tokenCount,
    required this.lpPositionCount,
  });
}
