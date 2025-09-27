import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';

class PortfolioSummaryWidget extends StatelessWidget {
  const PortfolioSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        if (portfolioProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading portfolio...'),
                  ],
                ),
              ),
            ),
          );
        }

        if (portfolioProvider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load portfolio',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    portfolioProvider.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final portfolio = portfolioProvider.portfolioData;
        if (portfolio == null) {
          return const SizedBox.shrink();
        }

        final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        final isPositive = portfolio.dayChange >= 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Portfolio Value
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(portfolio.totalValue),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${formatter.format(portfolio.dayChange)} (${portfolio.dayChangePercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Today',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Token Holdings
            if (portfolio.tokens.isNotEmpty) ...[
              Text(
                'Token Holdings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: portfolio.tokens.map((token) {
                    final isTokenPositive = token.dayChange >= 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          token.symbol.substring(0, 1),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(token.symbol),
                      subtitle: Text(
                          '${token.balance.toStringAsFixed(4)} ${token.symbol}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatter.format(token.usdValue),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          Text(
                            '${isTokenPositive ? '+' : ''}${token.dayChange.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color:
                                  isTokenPositive ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // LP Positions Summary
            if (portfolio.lpPositions.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'LP Positions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  Text(
                    '${portfolio.lpPositions.length} position${portfolio.lpPositions.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total LP Value',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              formatter.format(portfolio.lpPositions
                                  .fold(0.0, (sum, pos) => sum + pos.usdValue)),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
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
                              'Unclaimed Fees',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              formatter.format(portfolio.lpPositions.fold(
                                  0.0, (sum, pos) => sum + pos.unclaimedFees)),
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
                ),
              ),
            ],

            // Last updated
            if (portfolioProvider.lastUpdated != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Last updated: ${DateFormat.Hms().format(portfolioProvider.lastUpdated!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
