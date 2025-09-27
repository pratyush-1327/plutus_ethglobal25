/// Application configuration constants
///
/// This file manages environment variables and API configurations
/// for the ETH Portfolio Tracker app.
class AppConfig {
  // Infura API Configuration
  static const String infuraProjectId = String.fromEnvironment(
    'INFURA_PROJECT_ID',
    defaultValue: 'YOUR_PROJECT_ID',
  );

  // Backend API Configuration
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Debug Configuration
  static const bool isDebugMode = String.fromEnvironment(
        'DEBUG_MODE',
        defaultValue: 'false',
      ) ==
      'true';

  // Network RPC URLs with dynamic Infura integration
  static Map<int, String> get networkRpcUrls => {
        1: 'https://mainnet.infura.io/v3/$infuraProjectId', // Ethereum Mainnet
        137: 'https://polygon-rpc.com/', // Polygon
        10: 'https://mainnet.optimism.io', // Optimism
      };

  // Contract Addresses
  static const Map<String, String> contractAddresses = {
    'UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER':
        '0xC36442b4a4522E871399CD717aBDD847Ab11FE88',
    'UNISWAP_V3_FACTORY': '0x1F98431c8aD98523631AE4a59f267346ea31F984',
    'MULTICALL': '0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696',
  };

  // Validation Methods
  static bool get hasValidInfuraKey => infuraProjectId != 'YOUR_PROJECT_ID';

  static void validateConfiguration() {
    if (!hasValidInfuraKey) {
      throw Exception(
        'INFURA_PROJECT_ID environment variable is required. '
        'Please set it in your environment or use --dart-define.',
      );
    }
  }
}
