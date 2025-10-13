import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import 'contract_service.dart';
import 'wallet_manager.dart';

class TransactionManager {
  static final TransactionManager _instance = TransactionManager._internal();
  factory TransactionManager() => _instance;
  TransactionManager._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _contractService = ContractService();

  final _transactionController = StreamController<TransactionModel>.broadcast();
  Stream<TransactionModel> get transactionStream =>
      _transactionController.stream;

  // Send transaction and track status
  Future<TransactionModel> sendTransaction({
    required String type,
    required Future<String> Function() sendFunction,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Create pending transaction
    final txModel = TransactionModel(
      id: '',
      userId: userId,
      type: type,
      status: TransactionStatus.pending,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    final docRef = await _firestore
        .collection('transactions')
        .add(txModel.toJson());
    final savedTx = txModel.copyWith(id: docRef.id);

    try {
      // Send transaction
      final txHash = await sendFunction();

      // Update with hash
      final updatedTx = savedTx.copyWith(
        hash: txHash,
        status: TransactionStatus.submitted,
      );

      await docRef.update(updatedTx.toJson());
      _transactionController.add(updatedTx);

      // Monitor transaction
      _monitorTransaction(docRef.id, txHash);

      return updatedTx;
    } catch (e) {
      // Mark as failed
      final failedTx = savedTx.copyWith(
        status: TransactionStatus.failed,
        error: e.toString(),
      );

      await docRef.update(failedTx.toJson());
      _transactionController.add(failedTx);

      rethrow;
    }
  }

  // Monitor transaction status
  void _monitorTransaction(String docId, String txHash) async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final receipt = await _contractService.getTransactionReceipt(txHash);

        if (receipt != null) {
          timer.cancel();

          final status = receipt.status ?? false
              ? TransactionStatus.confirmed
              : TransactionStatus.failed;

          final updatedData = {
            'status': status.name,
            'blockNumber': receipt.blockNumber.blockNum.toInt(),
            'gasUsed': receipt.gasUsed?.toInt(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('transactions')
              .doc(docId)
              .update(updatedData);

          // Fetch and emit updated transaction
          final doc = await _firestore
              .collection('transactions')
              .doc(docId)
              .get();
          if (doc.exists) {
            final tx = TransactionModel.fromJson(doc.data()!);
            _transactionController.add(tx);
          }
        }
      } catch (e) {
        // Continue monitoring
      }
    });
  }

  // Join raffle with auto-approval
  Future<TransactionModel> joinRaffleWithApproval({
    required int raffleId,
    required BigInt amount,
  }) async {
    final userAddress = await WalletManager().getAddress();
    if (userAddress == null) throw Exception('No wallet found');

    // Check allowance
    final allowance = await _contractService.getRaffleTokenAllowance(
      userAddress,
    ); // ✅ Updated

    // Approve if needed
    if (allowance < amount) {
      await sendTransaction(
        type: 'approve_raffle_token', // ✅ Updated
        sendFunction: () =>
            _contractService.approveRaffleToken(amount), // ✅ Updated
        metadata: {'amount': amount.toString()},
      );

      // Wait for approval to confirm
      await Future.delayed(const Duration(seconds: 3));
    }

    // Join raffle
    return await sendTransaction(
      type: 'join_raffle',
      sendFunction: () => _contractService.joinRaffle(raffleId, amount),
      metadata: {'raffleId': raffleId, 'amount': amount.toString()},
    );
  }

  // Get user transactions
  Stream<List<TransactionModel>> getUserTransactions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get pending transactions
  Stream<List<TransactionModel>> getPendingTransactions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            TransactionStatus.pending.name,
            TransactionStatus.submitted.name,
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Cancel monitoring (cleanup)
  void dispose() {
    _transactionController.close();
  }
}
