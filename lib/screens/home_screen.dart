import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/wallet_connection_widget.dart';
import '../widgets/portfolio_summary_widget.dart';
import '../widgets/performance_indicator_widget.dart';
import 'wallet_connect_screen.dart';
import 'lp_position_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for wallet connection changes and load portfolio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadPortfolio();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also check when dependencies change (like when wallet connects)
    _checkAndLoadPortfolio();
  }

  void _checkAndLoadPortfolio() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final portfolioProvider =
        Provider.of<PortfolioProvider>(context, listen: false);

    if (walletProvider.isConnected && walletProvider.connectedAddress != null) {
      debugPrint('Loading portfolio for: ${walletProvider.connectedAddress}');
      portfolioProvider.loadPortfolio(walletProvider.connectedAddress!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ETH Portfolio Tracker'),
        centerTitle: true,
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  walletProvider.isConnected
                      ? Icons.account_balance_wallet
                      : Icons.wallet,
                  color: walletProvider.isConnected ? Colors.green : null,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'networks':
                      _showNetworkSelector(context);
                      break;
                    case 'disconnect':
                      walletProvider.disconnect();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (walletProvider.isConnected) ...[
                    PopupMenuItem(
                      value: 'networks',
                      child: Row(
                        children: const [
                          Icon(Icons.network_cell),
                          SizedBox(width: 8),
                          Text('Switch Network'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'disconnect',
                      child: Row(
                        children: const [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Disconnect'),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (!walletProvider.isConnected) {
            return const WalletConnectionWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              Provider.of<PortfolioProvider>(context, listen: false).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallet Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connected Wallet',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  walletProvider.truncatedAddress,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${walletProvider.selectedNetwork.name} • ${walletProvider.walletType ?? 'Unknown'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Performance Indicator
                  const PerformanceIndicatorWidget(),

                  const SizedBox(height: 16),

                  // Portfolio Summary
                  const PortfolioSummaryWidget(),

                  const SizedBox(height: 16),

                  // LP Positions Section
                  Consumer<PortfolioProvider>(
                    builder: (context, portfolioProvider, child) {
                      final lpPositions =
                          portfolioProvider.portfolioData?.lpPositions ?? [];

                      if (lpPositions.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LP Positions',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          ...lpPositions
                              .map((position) => Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: position.inRange
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        child: Icon(
                                          position.inRange
                                              ? Icons.trending_up
                                              : Icons.trending_flat,
                                          color: position.inRange
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      title: Text(
                                          '${position.token0Symbol}-${position.token1Symbol}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '\$${position.usdValue.toStringAsFixed(2)}'),
                                          Text(
                                            position.inRange
                                                ? 'In Range'
                                                : 'Out of Range',
                                            style: TextStyle(
                                              color: position.inRange
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Unclaimed',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          Text(
                                            '\$${position.unclaimedFees.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LPPositionDetailScreen(
                                                    position: position),
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                              .toList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (!walletProvider.isConnected) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletConnectScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Connect Wallet'),
            );
          }

          return FloatingActionButton(
            onPressed: () {
              Provider.of<PortfolioProvider>(context, listen: false).refresh();
            },
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }

  void _showNetworkSelector(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Network',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...SupportedNetwork.values
                .map((network) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                            int.parse('0xFF${network.colorHex.substring(2)}')),
                        radius: 16,
                      ),
                      title: Text(network.name),
                      trailing: walletProvider.selectedNetwork == network
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        walletProvider.switchNetwork(network);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
