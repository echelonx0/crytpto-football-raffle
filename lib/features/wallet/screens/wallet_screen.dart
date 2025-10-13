// lib/features/wallet/screens/wallet_screen.dart (updated)
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/contract_service.dart';
import '../../../shared/widgets/error_widget.dart';
import '../viewmodels/wallet_viewmodel.dart';
import '../widgets/balance_card.dart';
import '../../../core/utils/web3_helper.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // ✅ Refresh balance every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.read(walletViewModelProvider.notifier).refreshBalance();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletViewModelProvider);

    return Scaffold(
      body: walletState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => GlobalErrorWidget(
          message: 'Something went wrong: $error',
          onRetry: () =>
              ref.read(walletViewModelProvider.notifier).refreshBalance(),
        ),
        data: (wallet) {
          if (wallet == null) {
            return const Center(child: Text('No wallet found'));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(walletViewModelProvider.notifier).refreshBalance(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BalanceCard(wallet: wallet),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.water_drop,
                          label: 'Get Tokens',
                          onTap: () => _claimFaucet(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.qr_code,
                          label: 'Receive',
                          onTap: () =>
                              _showReceiveBottomSheet(context, wallet.address),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _AddressCard(address: wallet.address),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _claimFaucet(BuildContext context, WidgetRef ref) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final contractService = ContractService();
      await contractService.initialize();

      final txHash = await contractService.claimFaucet();

      if (context.mounted) Navigator.pop(context); // Close loading

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Claimed 100 RTKN!\nTX: ${txHash.substring(0, 10)}...',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // ✅ Wait for transaction to confirm, then refresh
      await Future.delayed(const Duration(seconds: 8)); // Increased from 5

      if (context.mounted) {
        // ✅ Refresh wallet balance
        ref.read(walletViewModelProvider.notifier).refreshBalance();

        // ✅ Show balance updated message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💰 Balance updated!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error claiming tokens: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      log('Faucet error: $e');
    }
  }

  void _showReceiveBottomSheet(BuildContext context, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReceiveSheet(address: address),
    );
  }
}

class _ReceiveSheet extends StatelessWidget {
  final String address;

  const _ReceiveSheet({required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Receive RTKN',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Raffle Token', // ✅ Added subtitle
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: address,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan QR or copy address',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Web3Helper.shortenAddress(address),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address copied')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// ... rest of your classes stay the same
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue[700]),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Address',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  Web3Helper.shortenAddress(address),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Address copied')));
            },
          ),
        ],
      ),
    );
  }
}
