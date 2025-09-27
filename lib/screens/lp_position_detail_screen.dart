import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';

class LPPositionDetailScreen extends StatefulWidget {
  final LPPosition position;

  const LPPositionDetailScreen({super.key, required this.position});

  @override
  State<LPPositionDetailScreen> createState() => _LPPositionDetailScreenState();
}

class _LPPositionDetailScreenState extends State<LPPositionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _claimAnimationController;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _claimAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _claimAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final position = widget.position;

    return Scaffold(
      appBar: AppBar(
        title: Text('${position.token0Symbol}-${position.token1Symbol} LP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Position Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: position.inRange
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          child: Icon(
                            position.inRange
                                ? Icons.trending_up
                                : Icons.trending_flat,
                            color:
                                position.inRange ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${position.token0Symbol}-${position.token1Symbol}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                position.inRange ? 'In Range' : 'Out of Range',
                                style: TextStyle(
                                  color: position.inRange
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Value and Stats
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liquidity Value',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                formatter.format(position.usdValue),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Fees Earned',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                formatter.format(position.feesEarned),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Price Range Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: _buildPriceRangeIndicator(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min Price',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '\$${position.minPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Current Price',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '\$${position.currentPrice.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Max Price',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '\$${position.maxPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Impermanent Loss Indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Impermanent Loss',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // IL Thermometer
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildImpermanentLossThermometer(),
                              const SizedBox(height: 8),
                              Text(
                                '${position.impermanentLoss.toStringAsFixed(2)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _getILColor(position.impermanentLoss),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getILDescription(position.impermanentLoss),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Unclaimed Fees Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unclaimed Fees',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatter.format(position.unclaimedFees),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              Text(
                                'Ready to claim',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (_isClaiming) ...[
                          const CircularProgressIndicator(),
                        ] else ...[
                          FilledButton.icon(
                            onPressed:
                                position.unclaimedFees > 0 ? _claimFees : null,
                            icon: const Icon(Icons.download),
                            label: const Text('Claim Fees'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeIndicator() {
    final position = widget.position;
    final minPrice = position.minPrice;
    final maxPrice = position.maxPrice;
    final currentPrice = position.currentPrice;

    final totalRange = maxPrice - minPrice;
    final currentPosition = (currentPrice - minPrice) / totalRange;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.3),
            Colors.green.withOpacity(0.3),
            Colors.red.withOpacity(0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Current price indicator
          Positioned(
            left: currentPosition * MediaQuery.of(context).size.width * 0.8,
            top: 10,
            child: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Range indicator
          Positioned(
            left: 20,
            right: 20,
            top: 25,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: position.inRange ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpermanentLossThermometer() {
    final position = widget.position;
    final ilPercent = position.impermanentLoss.abs();
    final height = (ilPercent / 10).clamp(0.0, 1.0); // Normalize to 0-1 range

    return Container(
      width: 40,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 36,
            height: 116 * height,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getILColor(position.impermanentLoss),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          // Thermometer bulb
          Positioned(
            bottom: -5,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _getILColor(position.impermanentLoss),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getILColor(double impermanentLoss) {
    if (impermanentLoss >= -1) return Colors.green;
    if (impermanentLoss >= -5) return Colors.orange;
    return Colors.red;
  }

  String _getILDescription(double impermanentLoss) {
    if (impermanentLoss >= -1) {
      return 'Minimal impermanent loss. Your position is performing well!';
    } else if (impermanentLoss >= -5) {
      return 'Moderate impermanent loss. Still within acceptable range for most LPs.';
    } else {
      return 'Significant impermanent loss. Consider the current market conditions.';
    }
  }

  void _claimFees() async {
    setState(() {
      _isClaiming = true;
    });

    _claimAnimationController.forward();

    // Simulate transaction
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isClaiming = false;
    });

    _claimAnimationController.reset();

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fees Claimed!'),
          content: Text(
              'Successfully claimed ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(widget.position.unclaimedFees)} in fees.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LP Position Info'),
        content: const Text(
          'This screen shows your Uniswap V3 liquidity position details including:\n\n'
          '• Current liquidity value\n'
          '• Fee earnings and unclaimed fees\n'
          '• Price range and current position\n'
          '• Impermanent loss calculation\n\n'
          'Use the claim button to collect your earned fees.',
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
}
