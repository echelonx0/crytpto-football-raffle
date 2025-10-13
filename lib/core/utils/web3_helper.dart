import 'package:web3dart/web3dart.dart';

class Web3Helper {
  // ============ RTKN (Raffle Token) Helpers ============

  /// Format wei to RTKN (6 decimals)
  /// Example: 100000000 wei → "100.00 RTKN"
  static String formatRtkn(BigInt wei) {
    final amount = wei / BigInt.from(1000000);
    return amount.toStringAsFixed(2);
  }

  /// Parse RTKN to wei (6 decimals)
  /// Example: 100.5 RTKN → 100500000 wei
  static BigInt parseRtkn(double amount) {
    return BigInt.from((amount * 1000000).round());
  }

  /// Format wei to USDT (6 decimals) - DEPRECATED
  /// @deprecated Use formatRtkn instead
  static String formatUsdt(BigInt wei) {
    return formatRtkn(wei); // Backward compatibility
  }

  /// Parse USDT to wei (6 decimals) - DEPRECATED
  /// @deprecated Use parseRtkn instead
  static BigInt parseUsdt(double amount) {
    return parseRtkn(amount); // Backward compatibility
  }

  // ============ ETH Helpers ============

  /// Format wei to ETH (18 decimals)
  /// Example: 1000000000000000000 wei → "1.0000 ETH"
  static String formatEth(BigInt wei) {
    final eth = wei / BigInt.from(10).pow(18);
    return eth.toStringAsFixed(4);
  }

  /// Parse ETH to wei (18 decimals)
  /// Example: 0.5 ETH → 500000000000000000 wei
  static BigInt parseEth(double amount) {
    return BigInt.from((amount * 1e18).round());
  }

  // ============ Address Helpers ============

  /// Shorten address for display
  /// Example: 0x1234...abcd
  static String shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Validate Ethereum address format
  static bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ Transaction Helpers ============

  /// Format transaction hash for display
  /// Example: 0x1234...abcdef
  static String formatTxHash(String hash) {
    if (hash.length < 10) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }

  /// Get block explorer URL for transaction or address
  static String getExplorerUrl(String hash, {bool isAddress = false}) {
    const baseUrl = 'https://sepolia-blockscout.lisk.com';
    return isAddress ? '$baseUrl/address/$hash' : '$baseUrl/tx/$hash';
  }

  /// Estimate gas cost in USD (approximate)
  /// Note: Update ETH price for production
  static double estimateGasCostUsd(BigInt gasUsed, EtherAmount gasPrice) {
    final gasCostWei = gasUsed * gasPrice.getInWei;
    final gasCostEth = gasCostWei / BigInt.from(10).pow(18);
    // Assuming 1 ETH = $2000 (update with real price feed)
    return gasCostEth * 2000;
  }

  // ============ Time Helpers ============

  /// Format duration to human-readable string
  /// Example: "2d 5h" or "45m" or "Ended"
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return 'Ended';

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  /// Format Unix timestamp to readable date
  /// Example: "10/1/2025 14:30"
  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Check if raffle is ending soon (< 1 hour remaining)
  static bool isEndingSoon(int endTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTime - now;
    return remaining > 0 && remaining < 3600;
  }

  /// Calculate time remaining as percentage
  /// Returns 0-100, where 100 = just started, 0 = ended
  static double getTimeRemainingPercentage(int startTime, int endTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final total = endTime - startTime;
    final elapsed = now - startTime;

    if (now >= endTime) return 0;
    if (now <= startTime) return 100;

    return ((total - elapsed) / total * 100).clamp(0, 100);
  }

  // ============ Number Formatting ============

  /// Format large numbers with K/M suffix
  /// Example: 1000 → "1.0K", 1500000 → "1.5M"
  static String formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  // ============ Token Display Helpers ============

  /// Format RTKN amount with token symbol
  /// Example: "100.00 RTKN"
  static String formatRtknWithSymbol(BigInt wei) {
    return '${formatRtkn(wei)} RTKN';
  }

  /// Format ETH amount with symbol
  /// Example: "0.0050 ETH"
  static String formatEthWithSymbol(BigInt wei) {
    return '${formatEth(wei)} ETH';
  }

  // ============ Validation Helpers ============

  /// Validate bet amount is within raffle limits
  static bool isValidBetAmount(
    double amount,
    double minBet,
    double maxBet, {
    double? userBalance,
  }) {
    if (amount < minBet) return false;
    if (maxBet > 0 && amount > maxBet) return false;
    if (userBalance != null && amount > userBalance) return false;
    return true;
  }

  /// Get bet amount error message
  static String? getBetAmountError(
    double amount,
    double minBet,
    double maxBet,
    double userBalance,
  ) {
    if (amount < minBet) {
      return 'Minimum bet is $minBet RTKN';
    }
    if (maxBet > 0 && amount > maxBet) {
      return 'Maximum bet is $maxBet RTKN';
    }
    if (amount > userBalance) {
      return 'Insufficient balance. You have $userBalance RTKN';
    }
    return null;
  }

  // ============ Raffle Status Helpers ============

  /// Get raffle status display text
  static String getRaffleStatus(bool drawn, bool cancelled, int endTime) {
    if (cancelled) return 'Cancelled';
    if (drawn) return 'Drawn';

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now >= endTime) return 'Ended';

    return 'Active';
  }

  /// Get raffle status color
  static String getRaffleStatusColor(bool drawn, bool cancelled, int endTime) {
    if (cancelled) return 'red';
    if (drawn) return 'green';

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now >= endTime) return 'orange';

    return 'blue';
  }
}
