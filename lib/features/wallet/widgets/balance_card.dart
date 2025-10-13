// lib/features/wallet/widgets/balance_card.dart
import 'package:flutter/material.dart';
import '../../../core/models/user_wallet.dart';

// Example balance card widget
class BalanceCard extends StatelessWidget {
  final UserWallet wallet;

  const BalanceCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[300]!.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RTKN Balance', // ✅ Changed
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Raffle Token', // ✅ Changed
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${wallet.rtknBalance} RTKN', // ✅ Changed (consider renaming usdtBalance to rtknBalance)
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available for betting',
            style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
