import 'package:flutter/material.dart';
import '../../../core/utils/web3_helper.dart';

class RaffleCard extends StatelessWidget {
  final dynamic raffle;
  final int index;

  const RaffleCard({super.key, required this.raffle, required this.index});

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.fromMillisecondsSinceEpoch(raffle.endTime * 1000);
    final timeLeft = endDate.difference(DateTime.now());
    final isEndingSoon = Web3Helper.isEndingSoon(raffle.endTime);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                Navigator.pushNamed(context, '/raffle/${raffle.raffleId}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isEndingSoon),
                  const SizedBox(height: 16),
                  _buildPrizeSection(),
                  const SizedBox(height: 16),
                  _buildStatsRow(timeLeft, isEndingSoon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEndingSoon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.blue[400]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.casino, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Raffle #${raffle.raffleId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (isEndingSoon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'ENDING SOON',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 20,
            color: Colors.green[700],
          ),
          const SizedBox(width: 8),
          Text(
            'Prize Pool',
            style: TextStyle(
              fontSize: 13,
              color: Colors.green[900],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '\$${raffle.prizePool}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green[700],
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Duration timeLeft, bool isEndingSoon) {
    return Row(
      children: [
        _buildStatChip(
          Icons.people_outline,
          '${raffle.participantCount} joined',
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          Icons.timer_outlined,
          Web3Helper.formatDuration(timeLeft),
          isEndingSoon ? Colors.red : Colors.grey,
        ),
        const Spacer(),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }
}
