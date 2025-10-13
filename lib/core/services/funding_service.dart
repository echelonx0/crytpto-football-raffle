import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contract_service.dart';
import 'wallet_manager.dart';

class FundingService {
  static final FundingService _instance = FundingService._internal();
  factory FundingService() => _instance;
  FundingService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _contractService = ContractService();
  final _walletManager = WalletManager();

  Timer? _depositMonitorTimer;

  // Open Transak widget for fiat purchase
  Future<void> buyWithFiat({
    required double amount,
    String currency = 'USD',
  }) async {
    final userAddress = await _walletManager.getAddress();
    if (userAddress == null) throw Exception('No wallet found');

    final transakUrl = Uri.https('global.transak.com', '/', {
      'apiKey': 'YOUR_TRANSAK_API_KEY', // Replace with your key
      'defaultCryptoCurrency': 'USDT',
      'cryptoCurrencyList': 'USDT',
      'defaultFiatAmount': amount.toString(),
      'fiatCurrency': currency,
      'walletAddress': userAddress,
      'network': 'lisk',
      'themeColor': '000000',
      'email': _auth.currentUser?.email ?? '',
    });

    if (await canLaunchUrl(transakUrl)) {
      await launchUrl(transakUrl, mode: LaunchMode.externalApplication);

      // Log purchase attempt
      await _logFundingAttempt('fiat', amount, currency);

      // Start monitoring for deposit
      _startDepositMonitoring(userAddress);
    } else {
      throw Exception('Could not launch Transak');
    }
  }

  // Get deposit address for crypto transfer
  Future<String> getDepositAddress() async {
    final address = await _walletManager.getAddress();
    if (address == null) throw Exception('No wallet found');

    // Log that user viewed deposit address
    await _logFundingAttempt('crypto', 0, 'USDT');

    // Start monitoring for deposit
    _startDepositMonitoring(address);

    return address;
  }

  // Monitor for USDT deposits
  void _startDepositMonitoring(String address) {
    _depositMonitorTimer?.cancel();

    BigInt lastBalance = BigInt.zero;

    _depositMonitorTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      try {
        final currentBalance = await _contractService.getRaffleTokenBalance(
          address,
        );

        if (currentBalance > lastBalance && lastBalance != BigInt.zero) {
          final depositAmount = currentBalance - lastBalance;
          await _logDeposit(address, depositAmount);

          // Notify user (via push notification service)
          // NotificationService().showDepositReceived(depositAmount);
        }

        lastBalance = currentBalance;
      } catch (e) {
        // Continue monitoring
      }
    });

    // Stop monitoring after 30 minutes
    Future.delayed(const Duration(minutes: 30), () {
      _depositMonitorTimer?.cancel();
    });
  }

  // Stop deposit monitoring
  void stopDepositMonitoring() {
    _depositMonitorTimer?.cancel();
  }

  // Log funding attempt
  Future<void> _logFundingAttempt(
    String method,
    double amount,
    String currency,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('funding_attempts').add({
      'userId': userId,
      'method': method,
      'amount': amount,
      'currency': currency,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Log successful deposit
  Future<void> _logDeposit(String address, BigInt amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('deposits').add({
      'userId': userId,
      'address': address,
      'amount': amount.toString(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get funding history
  Stream<List<Map<String, dynamic>>> getFundingHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('deposits')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Check if user has funded before
  Future<bool> hasFundedBefore() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final snapshot = await _firestore
        .collection('deposits')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  void dispose() {
    _depositMonitorTimer?.cancel();
  }
}
