import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class WalletConnectScreen extends StatelessWidget {
  const WalletConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Wallet'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your preferred wallet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect securely to access your Ethereum portfolio and Uniswap LP positions.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Wallet Options
                _buildWalletOption(
                  context,
                  walletProvider,
                  icon: Icons.extension,
                  title: 'MetaMask',
                  subtitle: 'Most popular Ethereum wallet',
                  walletType: 'MetaMask',
                  isPrimary: true,
                ),

                const SizedBox(height: 16),

                _buildWalletOption(
                  context,
                  walletProvider,
                  icon: Icons.qr_code,
                  title: 'WalletConnect',
                  subtitle: 'Connect with mobile wallets',
                  walletType: 'WalletConnect',
                ),

                const SizedBox(height: 16),

                _buildWalletOption(
                  context,
                  walletProvider,
                  icon: Icons.account_balance_wallet,
                  title: 'Coinbase Wallet',
                  subtitle: 'Coinbase\'s self-custody wallet',
                  walletType: 'Coinbase',
                ),

                const SizedBox(height: 32),

                // Network Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<SupportedNetwork>(
                          value: walletProvider.selectedNetwork,
                          isExpanded: true,
                          items: SupportedNetwork.values.map((network) {
                            return DropdownMenuItem(
                              value: network,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(int.parse(
                                        '0xFF${network.colorHex.substring(2)}')),
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(network.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (network) {
                            if (network != null) {
                              walletProvider.switchNetwork(network);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Connection Status
                if (walletProvider.connectionStatus ==
                    WalletConnectionStatus.connecting) ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Connecting...'),
                      ],
                    ),
                  ),
                ] else if (walletProvider.connectionStatus ==
                    WalletConnectionStatus.error) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Failed to connect wallet. Please try again.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (walletProvider.connectionStatus ==
                    WalletConnectionStatus.connected) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wallet Connected!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                walletProvider.truncatedAddress,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'We never store your private keys. Connection is secure and read-only.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletOption(
    BuildContext context,
    WalletProvider walletProvider, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String walletType,
    bool isPrimary = false,
  }) {
    final isConnecting =
        walletProvider.connectionStatus == WalletConnectionStatus.connecting &&
            walletProvider.walletType == walletType;

    return Card(
      elevation: isPrimary ? 2 : 1,
      child: InkWell(
        onTap: isConnecting
            ? null
            : () {
                walletProvider.connectWallet(walletType: walletType);
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isPrimary
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isConnecting) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ] else ...[
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
