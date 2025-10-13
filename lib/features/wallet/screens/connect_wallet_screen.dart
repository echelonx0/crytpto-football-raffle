// lib/screens/connect_wallet_screen.dart
import 'package:flutter/material.dart';

import '../../../core/services/wallet_connect_service.dart';
import '../../../core/services/wallet_manager.dart';

class ConnectWalletScreen extends StatefulWidget {
  const ConnectWalletScreen({super.key});

  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  bool _isConnecting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red[700])),
              ),
              const SizedBox(height: 16),
            ],
            _WalletOption(
              title: 'MetaMask / Trust Wallet',
              subtitle: 'Connect via WalletConnect',
              icon: Icons.account_balance_wallet,
              isLoading: _isConnecting,
              onTap: _isConnecting ? null : _connectWallet,
            ),
            const SizedBox(height: 12),
            _WalletOption(
              title: 'Use Generated Wallet',
              subtitle: 'Secure auto-generated wallet',
              icon: Icons.lock,
              onTap: _isConnecting ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final wcService = WalletConnectService();
      await wcService.initialize();
      final address = await wcService.connect();

      if (!context.mounted) return;

      // Save wallet type and address
      await WalletManager().setWalletType(WalletType.walletConnect);

      // Show success and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected: ${_truncateAddress(address)}'),
          backgroundColor: Colors.green,
        ),
      );
      if (!context.mounted) return;
      Navigator.pop(context, address);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  String _truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class _WalletOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _WalletOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
