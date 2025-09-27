import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class WalletConnectionWidget extends StatelessWidget {
  const WalletConnectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 32),
                Text(
                  'Connect Your Wallet',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Connect your real wallet to view your actual Ethereum portfolio and Uniswap LP positions',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real Wallet Connection',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Install MetaMask or Coinbase Wallet extension\n• Your actual wallet will be connected securely\n• We never store your private keys',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (walletProvider.connectionStatus ==
                    WalletConnectionStatus.connecting) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to ${walletProvider.walletType}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else if (walletProvider.connectionStatus ==
                    WalletConnectionStatus.error) ...[
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to connect wallet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _showWalletOptions(context),
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showInstallInstructions(context),
                    child: const Text('Install Wallet Extensions'),
                  ),
                ] else ...[
                  // Wallet connection options
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          walletProvider.connectWallet(walletType: 'MetaMask'),
                      icon: const Icon(Icons.extension),
                      label: const Text('Connect with MetaMask'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => walletProvider.connectWallet(
                          walletType: 'WalletConnect'),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('WalletConnect'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          walletProvider.connectWallet(walletType: 'Coinbase'),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Coinbase Wallet'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Manual address input section
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Theme.of(context).colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Theme.of(context).colorScheme.outline)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showManualAddressInput(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Connect with Wallet Address'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Supported networks info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Supported Networks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...SupportedNetwork.values
                            .map((network) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(int.parse(
                                            '0xFF${network.colorHex.substring(2)}')),
                                        radius: 8,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(network.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWalletOptions(BuildContext context) {
    // For now, just trigger MetaMask connection
    Provider.of<WalletProvider>(context, listen: false)
        .connectWallet(walletType: 'MetaMask');
  }

  void _showInstallInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Wallet Extensions'),
        content: const Text(
          'To connect your real wallet:\n\n'
          '1. Install MetaMask extension from metamask.io\n'
          '2. Or install Coinbase Wallet from wallet.coinbase.com\n'
          '3. Refresh this page and try connecting again\n\n'
          'Make sure to set up your wallet and have some ETH for gas fees.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showManualAddressInput(BuildContext context) {
    final TextEditingController addressController = TextEditingController();
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    String selectedWalletType = 'MetaMask';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Connect with Wallet Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your wallet address to view your portfolio:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Wallet type selector
                Text(
                  'Wallet Type:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedWalletType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                        value: 'MetaMask',
                        child: Row(
                          children: const [
                            Icon(Icons.extension, size: 20),
                            SizedBox(width: 8),
                            Text('MetaMask'),
                          ],
                        )),
                    DropdownMenuItem(
                        value: 'Coinbase',
                        child: Row(
                          children: const [
                            Icon(Icons.account_balance_wallet, size: 20),
                            SizedBox(width: 8),
                            Text('Coinbase Wallet'),
                          ],
                        )),
                    DropdownMenuItem(
                        value: 'WalletConnect',
                        child: Row(
                          children: const [
                            Icon(Icons.qr_code, size: 20),
                            SizedBox(width: 8),
                            Text('WalletConnect'),
                          ],
                        )),
                    DropdownMenuItem(
                        value: 'Manual',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Manual Address'),
                          ],
                        )),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedWalletType = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Address input field
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Wallet Address',
                    hintText: '0x1234567890abcdef1234567890abcdef12345678',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: const OutlineInputBorder(),
                    helperText:
                        'Enter a valid Ethereum address (42 characters)',
                  ),
                  maxLines: 1,
                  onChanged: (value) {
                    setState(() {
                      // Force rebuild to update validation
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Address validation info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Address Requirements:',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Must start with "0x"\n'
                        '• Must be exactly 42 characters long\n'
                        '• Contains hexadecimal characters (0-9, a-f)\n'
                        '• This will show a read-only view of the portfolio',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isValidAddress(addressController.text)
                  ? () {
                      Navigator.pop(context);
                      walletProvider.connectWalletByAddress(
                        address: addressController.text.trim(),
                        walletType: selectedWalletType,
                      );
                    }
                  : null,
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidAddress(String address) {
    // Basic Ethereum address validation
    final cleanAddress = address.trim();
    if (cleanAddress.length != 42) return false;
    if (!cleanAddress.startsWith('0x')) return false;

    // Check if all characters after 0x are valid hex
    final hexPart = cleanAddress.substring(2);
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart);
  }
}
