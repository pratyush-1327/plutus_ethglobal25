import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';

class PerformanceIndicatorWidget extends StatefulWidget {
  const PerformanceIndicatorWidget({super.key});

  @override
  State<PerformanceIndicatorWidget> createState() =>
      _PerformanceIndicatorWidgetState();
}

class _PerformanceIndicatorWidgetState extends State<PerformanceIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        final performanceStatus = portfolioProvider.performanceStatus;
        final portfolio = portfolioProvider.portfolioData;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Performance Indicator Character
                SizedBox(
                  height: 120,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: performanceStatus == PerformanceStatus.glowUp
                              ? _pulseAnimation.value
                              : 1.0,
                          child: _buildPerformanceCharacter(performanceStatus),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status Text
                Text(
                  _getStatusText(performanceStatus),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(performanceStatus),
                      ),
                ),

                if (portfolio != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${portfolio.dayChangePercent >= 0 ? '+' : ''}${portfolio.dayChangePercent.toStringAsFixed(2)}% today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getStatusColor(performanceStatus),
                        ),
                  ),
                ],

                const SizedBox(height: 16),

                // Performance Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(performanceStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPerformanceDescription(performanceStatus),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCharacter(PerformanceStatus status) {
    switch (status) {
      case PerformanceStatus.glowUp:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.green.withOpacity(0.3),
                Colors.green.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.sentiment_very_satisfied,
            size: 80,
            color: Colors.green,
          ),
        );

      case PerformanceStatus.meh:
        return const Icon(
          Icons.sentiment_neutral,
          size: 80,
          color: Colors.grey,
        );

      case PerformanceStatus.frowny:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(0.2),
                Colors.red.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.sentiment_very_dissatisfied,
            size: 80,
            color: Colors.red,
          ),
        );
    }
  }

  String _getStatusText(PerformanceStatus status) {
    switch (status) {
      case PerformanceStatus.glowUp:
        return 'Glow Up! 🚀';
      case PerformanceStatus.meh:
        return 'Steady Vibes 😐';
      case PerformanceStatus.frowny:
        return 'Down Bad 😞';
    }
  }

  Color _getStatusColor(PerformanceStatus status) {
    switch (status) {
      case PerformanceStatus.glowUp:
        return Colors.green;
      case PerformanceStatus.meh:
        return Colors.grey;
      case PerformanceStatus.frowny:
        return Colors.red;
    }
  }

  String _getPerformanceDescription(PerformanceStatus status) {
    switch (status) {
      case PerformanceStatus.glowUp:
        return 'Your portfolio is pumping! Great gains today with over 1% increase. Keep hodling! 💎🙌';
      case PerformanceStatus.meh:
        return 'Portfolio is stable today. Not much movement, but that\'s not always bad in crypto! 📈';
      case PerformanceStatus.frowny:
        return 'Portfolio is down today. Remember, crypto is volatile - this too shall pass! 💪';
    }
  }
}
