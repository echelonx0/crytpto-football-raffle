import 'package:flutter/material.dart';
import '../../../core/utils/web3_helper.dart';

class WinnerCard extends StatelessWidget {
  final String winnerAddress;

  const WinnerCard({super.key, required this.winnerAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.orange[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[200]!.withAlpha(102),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[400]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber[400]!.withAlpha(128),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🎉 Winner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Text(
              Web3Helper.shortenAddress(winnerAddress),
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber[900],
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
