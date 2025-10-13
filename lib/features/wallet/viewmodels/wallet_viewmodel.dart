import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/models/user_wallet.dart';
import '../../../core/services/wallet_manager.dart';
import '../../../core/services/contract_service.dart';
import '../../../core/utils/web3_helper.dart';

final walletViewModelProvider =
    StateNotifierProvider<WalletViewModel, AsyncValue<UserWallet?>>((ref) {
      return WalletViewModel();
    });

class WalletViewModel extends StateNotifier<AsyncValue<UserWallet?>> {
  WalletViewModel() : super(const AsyncValue.loading()) {
    _init();
  }

  final _walletManager = WalletManager();
  final _contractService = ContractService();

  Future<void> _init() async {
    try {
      await _contractService.initialize();
      await refreshBalance();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Refresh wallet balance
  Future<void> refreshBalance() async {
    try {
      final wallet = await _walletManager.getWallet();
      if (wallet == null) {
        state = const AsyncValue.data(null);
        return;
      }

      log('Wallet located: ${wallet.address}');

      // Fetch ETH balance
      EtherAmount ethBalance = await _contractService.getEthBalance(
        wallet.address,
      );
      log('ETH Balance: ${ethBalance.getInWei} wei');

      // Fetch USDT balance safely
      BigInt usdtBalance = BigInt.zero;
      try {
        usdtBalance = await _contractService.getRaffleTokenAllowance(
          wallet.address,
        );
        log('RKTN Balance: $usdtBalance');
      } catch (e) {
        log('Error fetching USDT balance: $e');
      }

      final updatedWallet = UserWallet(
        address: wallet.address,
        balance: Web3Helper.formatEth(ethBalance.getInWei),
        rtknBalance: Web3Helper.formatUsdt(usdtBalance),
      );

      state = AsyncValue.data(updatedWallet);
    } catch (e, st) {
      log('Error refreshing balance: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Get wallet address
  Future<String?> getAddress() async {
    return await _walletManager.getAddress();
  }
}
