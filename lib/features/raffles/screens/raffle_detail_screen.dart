import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/contract_service.dart';
import '../../../core/services/wallet_manager.dart';
import '../../wallet/viewmodels/wallet_viewmodel.dart';
import '../viewmodels/raffles_viewmodel.dart';
import '../widgets/animated_section.dart';
import '../widgets/prize_pool_card.dart';

import '../widgets/participants_list_card.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/winner_card.dart';
import '../../../core/services/transaction_manager.dart';
import '../../../core/utils/web3_helper.dart';
import '../../../shared/constants/app_constants.dart';

class RaffleDetailScreen extends ConsumerStatefulWidget {
  final String raffleId;

  const RaffleDetailScreen({super.key, required this.raffleId});

  @override
  ConsumerState<RaffleDetailScreen> createState() => _RaffleDetailScreenState();
}

class _RaffleDetailScreenState extends ConsumerState<RaffleDetailScreen> {
  final _amountController = TextEditingController();
  final _transactionManager = TransactionManager();
  bool _isJoining = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _joinRaffle() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    setState(() => _isJoining = true);

    try {
      final userAddress = await WalletManager().getAddress();
      final contractService = ContractService();
      await contractService.initialize();

      final isActive = await contractService.isRaffleActive(
        int.parse(widget.raffleId),
      );
      log('Raffle active: $isActive');

      if (!isActive) {
        throw Exception('Raffle #${widget.raffleId} is not active!');
      }

      final balanceWei = await contractService.getRaffleTokenBalance(
        userAddress!,
      );
      final userBalance = balanceWei / BigInt.from(1000000);
      log('Your balance: ${userBalance.toDouble()} RTKN');

      final error = Web3Helper.getBetAmountError(
        amount,
        AppConstants.minBetAmount,
        AppConstants.maxBetAmount,
        userBalance.toDouble(),
      );

      if (error != null) {
        _showSnackBar(error, isError: true);
        setState(() => _isJoining = false);
        return;
      }

      final amountWei = Web3Helper.parseRtkn(amount);
      log('Betting $amount RTKN ($amountWei wei)');

      final allowance = await contractService.getRaffleTokenAllowance(
        userAddress,
      );
      log('Current allowance: ${allowance / BigInt.from(1000000)} RTKN');

      if (allowance < amountWei) {
        log('Need approval...');
        _showSnackBar('Approving tokens...', isError: false);

        final approveTx = await contractService.approveRaffleToken(amountWei);
        log('✅ Approval TX: $approveTx');

        await Future.delayed(const Duration(seconds: 8));

        final newAllowance = await contractService.getRaffleTokenAllowance(
          userAddress,
        );
        log('New allowance: ${newAllowance / BigInt.from(1000000)} RTKN');

        if (newAllowance < amountWei) {
          throw Exception('Approval failed');
        }
      }

      log('Joining raffle...');
      _showSnackBar('Joining raffle...', isError: false);

      final joinTx = await contractService.joinRaffle(
        int.parse(widget.raffleId),
        amountWei,
      );

      log('✅ Join TX: $joinTx');

      if (mounted) {
        _showSnackBar('Success! Waiting for confirmation...', isError: false);

        // ✅ Wait for transaction to confirm
        await Future.delayed(const Duration(seconds: 8));

        // ✅ Refresh wallet balance
        ref.read(walletViewModelProvider.notifier).refreshBalance();

        // ✅ Refresh raffle details
        ref.invalidate(raffleDetailProvider(widget.raffleId));

        _showSnackBar('✅ Raffle joined! Balance updated.');

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      log('❌ Error: $e');
      if (mounted) {
        _showSnackBar('Failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final raffleDetailAsync = ref.watch(raffleDetailProvider(widget.raffleId));

    return Scaffold(
      appBar: AppBar(title: Text('Raffle #${widget.raffleId}'), elevation: 0),
      body: raffleDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (raffle) {
          final endDate = DateTime.fromMillisecondsSinceEpoch(
            raffle.endTime * 1000,
          );
          final timeLeft = endDate.difference(DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSection(
                  delay: 0,
                  child: PrizePoolCard(prizePool: raffle.prizePool),
                ),
                const SizedBox(height: 16),
                AnimatedSection(
                  delay: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.people_outline,
                          label: 'Participants',
                          value: raffle.participantCount,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.timer_outlined,
                          label: 'Time Left',
                          value: Web3Helper.formatDuration(timeLeft),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSection(
                  delay: 200,
                  child: ParticipantsListCard(
                    participants: raffle.participants,
                  ),
                ),
                const SizedBox(height: 24),
                if (!raffle.drawn && !raffle.cancelled)
                  AnimatedSection(delay: 300, child: _buildJoinSection()),
                if (raffle.drawn && raffle.winner != null)
                  AnimatedSection(
                    delay: 300,
                    child: WinnerCard(winnerAddress: raffle.winner!),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJoinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Bet Amount (RTKN)', // ✅ Changed
            prefixText: 'RTKN ', // ✅ Changed from '$'
            hintText: 'Min: ${AppConstants.minBetAmount}',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[400]!.withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isJoining ? null : _joinRaffle,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: _isJoining
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Join Raffle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
