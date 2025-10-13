import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../../shared/constants/contract_config.dart';
import 'wallet_manager.dart';

class ContractService {
  static final ContractService _instance = ContractService._internal();
  factory ContractService() => _instance;
  ContractService._internal();

  late Web3Client _client;
  late DeployedContract _raffleContract;
  late DeployedContract _raffleTokenContract; // ✅ Changed from _usdtContract

  final _walletManager = WalletManager();

  // Initialize Web3 client and contracts
  Future<void> initialize() async {
    _client = Web3Client(ContractConfig.rpcUrl, http.Client());

    // ✅ SoccerRaffle contract (updated name)
    _raffleContract = DeployedContract(
      ContractAbi.fromJson(
        ContractConfig.raffleAbi,
        'SoccerRaffle', // ✅ Changed from 'FootballRaffle'
      ),
      EthereumAddress.fromHex(ContractConfig.raffleContractAddress),
    );

    // RaffleToken ERC20 contract
    _raffleTokenContract = DeployedContract(
      ContractAbi.fromJson(ContractConfig.erc20Abi, 'RaffleToken'),
      EthereumAddress.fromHex(ContractConfig.raffleTokenAddress),
    );
  }

  /// ================================
  /// FAUCET - GET FREE TOKENS
  /// ================================

  Future<String> claimFaucet() async {
    try {
      final credentials = await _walletManager.getCredentials();

      // Get the faucet function from the token contract
      final function = _raffleTokenContract.function('faucet');

      return await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _raffleTokenContract,
          function: function,
          parameters: [], // No parameters needed for faucet
        ),
        chainId: ContractConfig.chainId,
      );
    } catch (e) {
      throw Exception('Failed to claim faucet: $e');
    }
  }

  /// ================================
  /// ETH / RAFFLE TOKEN BALANCES
  /// ================================

  Future<EtherAmount> getEthBalance(String address) async {
    return await _client.getBalance(EthereumAddress.fromHex(address));
  }

  Future<BigInt> getRaffleTokenBalance(String address) async {
    // ✅ Renamed
    try {
      final function = _raffleTokenContract.function('balanceOf');
      final result = await _client.call(
        contract: _raffleTokenContract,
        function: function,
        params: [EthereumAddress.fromHex(address)],
      );
      return result.first as BigInt;
    } catch (e) {
      throw Exception('Error fetching RaffleToken balance: $e');
    }
  }

  /// ================================
  /// RAFFLE TOKEN ERC20 INTERACTIONS
  /// ================================

  Future<String> approveRaffleToken(BigInt amount) async {
    // ✅ Renamed
    final credentials = await _walletManager.getCredentials();
    final function = _raffleTokenContract.function('approve');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleTokenContract,
        function: function,
        parameters: [
          EthereumAddress.fromHex(ContractConfig.raffleContractAddress),
          amount,
        ],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<BigInt> getRaffleTokenAllowance(String ownerAddress) async {
    // ✅ Renamed
    final function = _raffleTokenContract.function('allowance');
    final result = await _client.call(
      contract: _raffleTokenContract,
      function: function,
      params: [
        EthereumAddress.fromHex(ownerAddress),
        EthereumAddress.fromHex(ContractConfig.raffleContractAddress),
      ],
    );
    return result.first as BigInt;
  }

  /// ================================
  /// RAFFLE CONTRACT INTERACTIONS
  /// ================================

  Future<String> joinRaffle(int raffleId, BigInt amount) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('joinRaffle');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [BigInt.from(raffleId), amount],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<String> createRaffle({
    required BigInt minBet,
    required BigInt maxBet,
    required int maxParticipants,
    required int duration,
    required int creatorFee,
    required String seedCommit,
  }) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('createRaffle');

    final bytes = hexToBytes(seedCommit);

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [
          minBet,
          maxBet,
          BigInt.from(maxParticipants),
          BigInt.from(duration),
          BigInt.from(creatorFee),
          bytes,
        ],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<String> revealSeed(int raffleId, BigInt seed) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('revealSeed');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [BigInt.from(raffleId), seed],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<String> drawWinner(int raffleId) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('drawWinner');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [BigInt.from(raffleId)],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<String> cancelRaffle(int raffleId) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('cancelRaffle');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [BigInt.from(raffleId)],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  Future<String> claimRefund(int raffleId) async {
    final credentials = await _walletManager.getCredentials();
    final function = _raffleContract.function('claimRefund');

    return await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _raffleContract,
        function: function,
        parameters: [BigInt.from(raffleId)],
      ),
      chainId: ContractConfig.chainId,
    );
  }

  /// ================================
  /// UTILS
  /// ================================

  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _client.getTransactionReceipt(txHash);
  }

  Future<BigInt> estimateGas(Transaction transaction) async {
    return await _client.estimateGas(
      sender: transaction.from,
      to: transaction.to,
      data: transaction.data,
      value: transaction.value,
    );
  }

  Future<EtherAmount> getGasPrice() async {
    return await _client.getGasPrice();
  }

  void dispose() {
    _client.dispose();
  }

  /// ================================
  /// DEBUG / VERIFICATION METHODS
  /// ================================

  /// Get the token address that the raffle contract expects
  Future<String> getRaffleExpectedToken() async {
    try {
      final function = _raffleContract.function('raffleToken');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [],
      );
      return (result.first as EthereumAddress).hex;
    } catch (e) {
      throw Exception('Failed to get raffle token: $e');
    }
  }

  /// Get all active raffle IDs
  Future<List<int>> getActiveRaffleIds() async {
    try {
      final function = _raffleContract.function('getActiveRaffles');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [],
      );
      return (result.first as List)
          .cast<BigInt>()
          .map((e) => e.toInt())
          .toList();
    } catch (e) {
      throw Exception('Failed to get active raffles: $e');
    }
  }

  /// Check if a raffle is active
  Future<bool> isRaffleActive(int raffleId) async {
    try {
      final function = _raffleContract.function('isRaffleActive');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [BigInt.from(raffleId)],
      );
      return result.first as bool;
    } catch (e) {
      throw Exception('Failed to check raffle status: $e');
    }
  }

  /// Get detailed raffle information
  Future<Map<String, dynamic>> getRaffleDetails(int raffleId) async {
    try {
      final function = _raffleContract.function('getRaffleDetails');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [BigInt.from(raffleId)],
      );

      return {
        'creator': (result[0] as EthereumAddress).hex,
        'prizePool': result[1] as BigInt,
        'participantCount': (result[2] as BigInt).toInt(),
        'startTime': (result[3] as BigInt).toInt(),
        'endTime': (result[4] as BigInt).toInt(),
        'drawn': result[5] as bool,
        'cancelled': result[6] as bool,
      };
    } catch (e) {
      throw Exception('Failed to get raffle details: $e');
    }
  }

  /// Get raffle participants
  Future<List<String>> getRaffleParticipants(int raffleId) async {
    try {
      final function = _raffleContract.function('getRaffleParticipants');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [BigInt.from(raffleId)],
      );
      return (result.first as List)
          .cast<EthereumAddress>()
          .map((e) => e.hex)
          .toList();
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }

  /// Get participant's bet amount
  Future<BigInt> getParticipantBet(int raffleId, String address) async {
    try {
      final function = _raffleContract.function('getParticipantBet');
      final result = await _client.call(
        contract: _raffleContract,
        function: function,
        params: [BigInt.from(raffleId), EthereumAddress.fromHex(address)],
      );
      return result.first as BigInt;
    } catch (e) {
      throw Exception('Failed to get participant bet: $e');
    }
  }
}
