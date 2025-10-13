import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/contract_service.dart';
import '../../../core/services/transaction_manager.dart';
import '../../../core/services/wallet_manager.dart';
import '../../../core/utils/encryption_helper.dart';
import '../../../core/utils/web3_helper.dart';

final adminViewModelProvider =
    StateNotifierProvider<AdminViewModel, AsyncValue<AdminStats>>((ref) {
      return AdminViewModel();
    });

class AdminStats {
  final int totalRaffles;
  final int activeRaffles;
  final int totalUsers;
  final String totalVolume;
  final String platformFees;

  AdminStats({
    required this.totalRaffles,
    required this.activeRaffles,
    required this.totalUsers,
    required this.totalVolume,
    required this.platformFees,
  });
}

class AdminViewModel extends StateNotifier<AsyncValue<AdminStats>> {
  AdminViewModel() : super(const AsyncValue.loading()) {
    loadStats();
  }

  final _firestore = FirebaseFirestore.instance;
  final _contractService = ContractService();
  final _transactionManager = TransactionManager();
  final _walletManager = WalletManager();

  Future<void> loadStats() async {
    try {
      await _contractService.initialize();

      // Get contract stats
      final raffleCount = await _getRaffleCount();
      final activeRaffles = await _getActiveRafflesCount();

      // Get user stats
      final usersSnapshot = await _firestore
          .collection('wallets')
          .count()
          .get();
      final totalUsers = usersSnapshot.count ?? 0;

      // Get transaction volume
      final txSnapshot = await _firestore
          .collection('transactions')
          .where('type', isEqualTo: 'join_raffle')
          .where('status', isEqualTo: 'confirmed')
          .get();

      double totalVolume = 0;
      for (var doc in txSnapshot.docs) {
        final metadata = doc.data()['metadata'] as Map<String, dynamic>?;
        if (metadata != null && metadata['amount'] != null) {
          final amount = BigInt.parse(metadata['amount'].toString());
          totalVolume += double.parse(Web3Helper.formatUsdt(amount));
        }
      }

      state = AsyncValue.data(
        AdminStats(
          totalRaffles: raffleCount,
          activeRaffles: activeRaffles,
          totalUsers: totalUsers,
          totalVolume: totalVolume.toStringAsFixed(2),
          platformFees: (totalVolume * 0.025).toStringAsFixed(2),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> _getRaffleCount() async {
    final snapshot = await _firestore.collection('raffles').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getActiveRafflesCount() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final snapshot = await _firestore
        .collection('raffles')
        .where('endTime', isGreaterThan: now)
        .where('drawn', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Create raffle
  Future<void> createRaffle({
    required double minBet,
    required double maxBet,
    required int maxParticipants,
    required int durationHours,
    required int creatorFeePercent,
  }) async {
    try {
      // Generate seed
      final seed = EncryptionHelper.generateRandomSeed();
      final seedCommit = EncryptionHelper.hashSeed(seed);

      // Prepare parameters
      final minBetWei = Web3Helper.parseUsdt(minBet);
      final maxBetWei = maxBet > 0 ? Web3Helper.parseUsdt(maxBet) : BigInt.zero;
      final duration = durationHours * 3600;

      // Send transaction
      await _transactionManager.sendTransaction(
        type: 'create_raffle',
        sendFunction: () => _contractService.createRaffle(
          minBet: minBetWei,
          maxBet: maxBetWei,
          maxParticipants: maxParticipants,
          duration: duration,
          creatorFee: creatorFeePercent * 100, // Convert to basis points
          seedCommit: seedCommit,
        ),
        metadata: {
          'minBet': minBet,
          'maxBet': maxBet,
          'maxParticipants': maxParticipants,
          'duration': duration,
          'creatorFee': creatorFeePercent,
          'seed': seed.toString(),
        },
      );

      // Store raffle info in Firestore
      await _firestore.collection('raffles').add({
        'minBet': minBet,
        'maxBet': maxBet,
        'maxParticipants': maxParticipants,
        'duration': duration,
        'creatorFee': creatorFeePercent,
        'seed': seed.toString(),
        'seedCommit': seedCommit,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadStats();
    } catch (e) {
      rethrow;
    }
  }

  // Cancel raffle
  Future<void> cancelRaffle(int raffleId) async {
    await _transactionManager.sendTransaction(
      type: 'cancel_raffle',
      sendFunction: () => _contractService.cancelRaffle(raffleId),
      metadata: {'raffleId': raffleId},
    );
    await loadStats();
  }

  // Reveal seed and draw winner
  Future<void> drawWinner(int raffleId, String seedString) async {
    final seed = BigInt.parse(seedString);

    // First reveal seed
    await _transactionManager.sendTransaction(
      type: 'reveal_seed',
      sendFunction: () => _contractService.revealSeed(raffleId, seed),
      metadata: {'raffleId': raffleId, 'seed': seedString},
    );

    // Wait for confirmation then draw
    await Future.delayed(const Duration(seconds: 5));

    await _transactionManager.sendTransaction(
      type: 'draw_winner',
      sendFunction: () => _contractService.drawWinner(raffleId),
      metadata: {'raffleId': raffleId},
    );

    await loadStats();
  }

  // Toggle permissionless mode
  Future<void> togglePermissionless() async {
    await _transactionManager.sendTransaction(
      type: 'toggle_permissionless',
      sendFunction: () async {
        // This requires direct contract call
        final credentials = await _walletManager.getCredentials();
        // Implementation needed based on contract
        throw UnimplementedError('Add contract function');
      },
      metadata: {},
    );
  }

  // Withdraw platform fees
  Future<void> withdrawPlatformFees() async {
    await _transactionManager.sendTransaction(
      type: 'withdraw_fees',
      sendFunction: () async {
        final credentials = await _walletManager.getCredentials();
        // Implementation needed
        throw UnimplementedError('Add contract function');
      },
      metadata: {},
    );
    await loadStats();
  }
}
