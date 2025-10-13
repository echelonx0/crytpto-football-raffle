import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../../../core/services/raffle_service.dart';

class ManageRafflesScreen extends ConsumerStatefulWidget {
  const ManageRafflesScreen({super.key});

  @override
  ConsumerState<ManageRafflesScreen> createState() =>
      _ManageRafflesScreenState();
}

class _ManageRafflesScreenState extends ConsumerState<ManageRafflesScreen> {
  final _raffleService = RaffleService();
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Raffles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('raffles')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.casino_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No raffles created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _RaffleManagementCard(
                raffleData: data,
                raffleDocId: doc.id,
                onAction: () =>
                    ref.read(adminViewModelProvider.notifier).loadStats(),
              );
            },
          );
        },
      ),
    );
  }
}

class _RaffleManagementCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> raffleData;
  final String raffleDocId;
  final VoidCallback onAction;

  const _RaffleManagementCard({
    required this.raffleData,
    required this.raffleDocId,
    required this.onAction,
  });

  @override
  ConsumerState<_RaffleManagementCard> createState() =>
      _RaffleManagementCardState();
}

class _RaffleManagementCardState extends ConsumerState<_RaffleManagementCard> {
  bool _isLoading = false;

  Future<void> _cancelRaffle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Raffle?'),
        content: const Text('This will allow participants to claim refunds.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Get raffle ID from contract (you'll need to fetch this)
      final raffleId = widget.raffleData['raffleId'] as int? ?? 1;

      await ref.read(adminViewModelProvider.notifier).cancelRaffle(raffleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Raffle cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _drawWinner() async {
    final seed = widget.raffleData['seed'] as String?;
    if (seed == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seed not found')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Draw Winner?'),
        content: const Text('This will reveal the seed and select a winner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Draw Winner'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final raffleId = widget.raffleData['raffleId'] as int? ?? 1;
      await ref
          .read(adminViewModelProvider.notifier)
          .drawWinner(raffleId, seed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Winner drawn successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //  final minBet = widget.raffleData['minBet'] ?? 0;
    final maxBet = widget.raffleData['maxBet'] ?? 0;
    final duration = widget.raffleData['duration'] ?? 0;
    final creatorFee = widget.raffleData['creatorFee'] ?? 0;
    final createdAt = widget.raffleData['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Raffle #${widget.raffleDocId.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Min Bet', value: '\$minBet'),
            _InfoRow(
              label: 'Max Bet',
              value: maxBet > 0 ? '\$maxBet' : 'Unlimited',
            ),
            _InfoRow(label: 'Duration', value: '${duration ~/ 3600}h'),
            _InfoRow(label: 'Creator Fee', value: '$creatorFee%'),
            if (createdAt != null)
              _InfoRow(
                label: 'Created',
                value: _formatDate(createdAt.toDate()),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _cancelRaffle,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _drawWinner,
                    icon: const Icon(Icons.emoji_events, size: 18),
                    label: const Text('Draw'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
