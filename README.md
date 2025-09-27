# # ETH Portfolio Tracker

A modern Flutter application for tracking Ethereum portfolios with Uniswap LP positions. Built with Material 3 design and integrated with a Python FastAPI backend.

## ✨ Features

### 🔗 Real Wallet Connection
- **Multi-wallet Support**: Real MetaMask, WalletConnect, Coinbase Wallet integration
- **Multi-chain Support**: Ethereum Mainnet, Polygon, Optimism
- **Your Actual Wallet**: Connect your real wallet with your actual funds
- **Secure Connection**: Read-only access with no private key storage

### 📊 Portfolio Dashboard
- **Real-time Portfolio Value**: Total USD value with 24h P&L
- **Token Holdings**: ERC-20 token balances with price tracking
- **Performance Animations**: Animated indicators based on portfolio performance

### 🦄 Uniswap LP Positions
- **LP Position Tracking**: Detailed view of Uniswap V3 positions
- **Impermanent Loss Calculator**: Visual thermometer showing IL status
- **Fee Management**: Track and claim unclaimed fees
- **Price Range Visualization**: Current price vs position range

### 🎭 Meme Performance Indicator
- **Glow-Up Animation**: >+1% daily gain (pulsing green)
- **Meh Animation**: ±1% daily change (neutral gray)
- **Frowny Animation**: >-1% daily loss (sad red)

### 🎨 Material 3 Design
- **Universal Theme**: Light/dark mode support
- **Ethereum Branding**: Custom color scheme based on Ethereum blue
- **Modern UI Components**: Cards, buttons, and animations

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point
├── theme/
│   └── app_theme.dart           # Material 3 theme configuration
├── screens/
│   ├── home_screen.dart         # Main dashboard
│   ├── wallet_connect_screen.dart
│   └── lp_position_detail_screen.dart
├── widgets/
│   ├── wallet_connection_widget.dart
│   ├── portfolio_summary_widget.dart
│   └── performance_indicator_widget.dart
├── providers/
│   ├── wallet_provider.dart     # Wallet state management
│   └── portfolio_provider.dart  # Portfolio data management
└── services/
    ├── web3_service.dart        # Blockchain interactions
    └── backend_api_service.dart # API integration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- **MetaMask or Coinbase Wallet browser extension** (for real wallet connection)
- Python backend server running (from eth_backend folder)

### Installation

1. **Clone and setup Flutter project:**
   ```bash
   cd d:\Projects\ethfront
   flutter pub get
   ```

2. **Start the Python backend:**
   ```bash
   cd d:\Projects\eth_backend
   python -m venv venv
   venv\Scripts\activate  # On Windows
   pip install -r requirements.txt
   python main.py
   ```

3. **Run the Flutter app:**
   ```bash
   flutter run -d web  # For web
   flutter run -d windows  # For desktop
   ```

### Configuration

1. **Update Backend URL** in `lib/services/backend_api_service.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:8000';
   ```

2. **Configure Infura API Key** using environment variables:
   ```bash
   # Method 1: Using --dart-define (recommended for development)
   flutter run -d web --dart-define=INFURA_PROJECT_ID=your_actual_project_id

   # Method 2: Set system environment variable
   # Windows:
   set INFURA_PROJECT_ID=your_actual_project_id
   # Linux/Mac:
   export INFURA_PROJECT_ID=your_actual_project_id
   ```

3. **Get your Infura Project ID**:
   - Sign up at [Infura.io](https://infura.io)
   - Create a new project
   - Copy your Project ID from the dashboard
   - Replace `your_actual_project_id` with your real Project ID

4. **Backend Environment Setup**:
   ```bash
   cd plutus_backend
   cp .env.example .env
   # Edit .env file and add your Infura Project ID:
   # INFURA_PROJECT_ID=your_actual_project_id
   ```

## 📱 Usage

### Connecting Your Real Wallet
1. **Install MetaMask or Coinbase Wallet browser extension**
2. Open the app in your browser
3. Click "Connect with MetaMask" or "Connect with Coinbase Wallet"
4. **Approve the connection in your wallet popup**
5. Select your preferred network (Ethereum, Polygon, Optimism)
6. **Your real portfolio will be displayed!**

> 📋 **See [WALLET_INTEGRATION.md](WALLET_INTEGRATION.md) for detailed setup instructions**### Viewing Portfolio
1. After wallet connection, portfolio loads automatically
2. View total value and 24h change
3. Browse token holdings and LP positions
4. Tap on LP positions for detailed view

### Managing LP Positions
1. Navigate to any LP position
2. View price range and current status
3. Check impermanent loss thermometer
4. Claim unclaimed fees with the "Claim Fees" button

## 🔧 Technical Implementation

### State Management
- **Provider Pattern**: Used for wallet and portfolio state
- **Change Notifiers**: Reactive UI updates
- **Separation of Concerns**: Business logic in providers, UI in widgets

### Web3 Integration
- **Mock Services**: Development-ready mock implementations
- **Future Web3 Integration**: Prepared structure for web3dart
- **Multi-chain Support**: Network-specific configurations

### Backend Integration
- **REST API**: Integration with Python FastAPI backend
- **Error Handling**: Graceful fallback to mock data
- **Dio HTTP Client**: Robust network communication

### Performance Features
- **Lazy Loading**: Data loaded on demand
- **Caching**: Portfolio data cached locally
- **Animations**: Smooth transitions and performance indicators

## 🎯 Backend API Integration

The app integrates with a Python FastAPI backend with the following endpoints:

- `GET /portfolio/{wallet_address}` - Get complete portfolio data
- `GET /tokens/{wallet_address}` - Get token balances
- `GET /uniswap/{wallet_address}` - Get LP positions
- `POST /transaction/simulate-claim` - Simulate fee claiming

## 🔮 Future Enhancements

### Planned Features
- **Real Web3 Integration**: Replace mock services with actual blockchain calls
- **Push Notifications**: Price alerts and fee earning notifications
- **Advanced Analytics**: Historical performance charts
- **DeFi Protocol Expansion**: Support for other AMMs (SushiSwap, Curve)
- **Mobile Responsiveness**: Optimized mobile layouts

### Technical Improvements
- **State Management**: Migration to Riverpod for better performance
- **Testing**: Comprehensive unit and widget tests
- **CI/CD**: Automated testing and deployment
- **Internationalization**: Multi-language support

## 📦 Dependencies

### Core Dependencies
- `flutter`: Framework
- `provider`: State management
- `material_color_utilities`: Material 3 theming
- `dio`: HTTP client for API calls

### UI Dependencies
- `fl_chart`: Charts and graphs
- `shimmer`: Loading animations
- `lottie`: Performance indicator animations
- `cached_network_image`: Image caching

### Utility Dependencies
- `intl`: Internationalization and formatting
- `shared_preferences`: Local storage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Ethereum Community**: For the amazing ecosystem
- **Uniswap**: For the innovative AMM protocol
- **Flutter Team**: For the excellent framework
- **Material Design**: For the beautiful design systemtracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
