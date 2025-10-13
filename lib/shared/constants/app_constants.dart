class AppConstants {
  // ============ App Info ============
  static const String appName = 'Soccer Raffle';
  static const String appVersion = '1.0.0';

  // ============ Token Info ============
  static const String tokenSymbol = 'RTKN';
  static const String tokenName = 'Raffle Token';
  static const int tokenDecimals = 6; //  (USDT-style decimals)

  // ============ Transak Config ============
  static const String transakApiKey =
      'TRANSAK_API_KEY'; // Replace with real key from https://transak.com/
  static const String transakEnvironment = 'STAGING'; // or 'PRODUCTION'

  // ============ Betting Limits (in RTKN) ============
  static const double minBetAmount = 5.0; //   10 RTKN minimum
  static const double maxBetAmount = 1000.0; //   1000 RTKN maximum
  static const double minFundAmount =
      50.0; // ✅ Changed: 50 RTKN minimum (was 5 USDT)

  // ============ Faucet Settings ============
  static const double faucetAmount = 1000.0;
  static const int faucetCooldown =
      3600; // ✅ Added: 1 hour cooldown (in seconds)

  // ============ Gas Limits ============
  static const int approveGasLimit = 100000;
  static const int joinRaffleGasLimit = 200000;
  static const int createRaffleGasLimit = 300000;
  static const int faucetGasLimit = 80000; // ✅ Added

  // ============ Timing ============
  static const int depositCheckInterval = 10; // seconds
  static const int transactionPollInterval = 5; // seconds
  static const int maxTransactionWaitTime = 300; // seconds (5 min)
  static const int balanceRefreshInterval = 30; //   seconds

  // ============ UI Constants ============
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const int animationDuration = 300; // milliseconds
  static const int toastDuration = 3000; // ✅ Added: milliseconds

  // ============ Network Info ============
  static const String networkName = 'Lisk Sepolia';
  static const int chainId = 4202; // ✅ Added
  static const String explorerUrl = 'https://sepolia-blockscout.lisk.com';

  // ============ Notification Titles ============
  static const String depositReceivedTitle = 'RTKN Received!'; //
  static const String faucetClaimedTitle = 'Faucet Claimed!'; //
  static const String raffleWonTitle = 'Congratulations! 🎉';
  static const String raffleLostTitle = 'Better luck next time';
  static const String transactionConfirmedTitle = 'Transaction Confirmed';

  // ============ Error Messages ============
  static const String noWalletError =
      'No wallet found. Please create one first.';
  static const String insufficientBalanceError = 'Insufficient RTKN balance'; //
  static const String insufficientEthError = 'Insufficient ETH for gas fees';
  static const String transactionFailedError =
      'Transaction failed. Please try again.';
  static const String networkError = 'Network error. Check your connection.';
  static const String contractError = 'Smart contract error. Please try again.';
  static const String approvalRequiredError = 'Token approval required first';
  static const String raffleCancelledError = 'This raffle has been cancelled';
  static const String raffleEndedError = 'This raffle has ended';
  static const String betTooLowError = 'Bet amount below minimum';
  static const String betTooHighError = 'Bet amount above maximum';

  // ============ Success Messages ============
  static const String walletCreatedSuccess = 'Wallet created successfully!';
  static const String faucetClaimedSuccess =
      'Claimed $faucetAmount RTKN from faucet!';
  static const String raffleJoinedSuccess = 'Joined raffle successfully!';
  static const String transactionSubmittedSuccess = 'Transaction submitted!';
  static const String approvalSuccess = 'Token approval successful!';
  static const String addressCopiedSuccess = 'Address copied to clipboard';

  // ============ Info Messages ============
  static const String connectingWalletInfo = 'Connecting to your wallet...';
  static const String approvingTokensInfo = 'Approving RTKN tokens...';
  static const String joiningRaffleInfo = 'Joining raffle...';
  static const String waitingConfirmationInfo =
      'Waiting for blockchain confirmation...';

  // ============ Validation Messages ============
  static String getMinBetError() => 'Minimum bet is $minBetAmount RTKN';

  static String getMaxBetError() => 'Maximum bet is $maxBetAmount RTKN';

  static String getInsufficientBalanceError(double balance) =>
      'Insufficient balance. You have ${balance.toStringAsFixed(2)} RTKN';

  // ============ Raffle Status ============
  static const String raffleStatusActive = 'Active';
  static const String raffleStatusEnded = 'Ended';
  static const String raffleStatusDrawn = 'Drawn';
  static const String raffleStatusCancelled = 'Cancelled';

  // ============ Helper Methods ============

  /// Format RTKN amount for display
  static String formatRtkn(double amount) {
    return '${amount.toStringAsFixed(2)} RTKN';
  }

  /// Format ETH amount for display
  static String formatEth(double amount) {
    return '${amount.toStringAsFixed(4)} ETH';
  }

  /// Get faucet cooldown message
  static String getFaucetCooldownMessage(int secondsRemaining) {
    final minutes = (secondsRemaining / 60).ceil();
    return 'Faucet available in $minutes minute${minutes != 1 ? 's' : ''}';
  }
}
