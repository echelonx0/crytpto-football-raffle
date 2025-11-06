// lib/features/raffle/services/prediction_service.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  // ================================
  // PREDICTION COMMIT GENERATION
  // ================================

  /// Generate a cryptographically secure random secret
  String generateSecret() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return hex.encode(values); // 64-char hex string
  }

  /// Create prediction string from scores
  /// Format: "teamA:scoreA-teamB:scoreB" (e.g., "ManU:2-Chelsea:1")
  String formatPrediction({
    required String teamA,
    required String teamB,
    required int scoreA,
    required int scoreB,
  }) {
    return '$teamA:$scoreA-$teamB:$scoreB';
  }

  /// Generate commit hash: keccak256(prediction + secret)
  /// This matches Solidity: keccak256(abi.encodePacked(prediction, secret))
  String generateCommit(String prediction, String secret) {
    final combined = utf8.encode(prediction + secret);
    final hash = keccak256(Uint8List.fromList(combined));
    return '0x${hex.encode(hash)}';
  }

  // ================================
  // SECURE STORAGE
  // ================================

  /// Store prediction + secret for a raffle
  /// Key format: "prediction_{raffleId}_{userAddress}"
  Future<void> storePrediction({
    required int raffleId,
    required String userAddress,
    required String prediction,
    required String secret,
  }) async {
    final key = _getPredictionKey(raffleId, userAddress);
    final data = json.encode({
      'prediction': prediction,
      'secret': secret,
      'timestamp': DateTime.now().toIso8601String(),
      'raffleId': raffleId,
    });
    await _storage.write(key: key, value: data);
  }

  /// Retrieve stored prediction data
  Future<Map<String, dynamic>?> getPrediction({
    required int raffleId,
    required String userAddress,
  }) async {
    final key = _getPredictionKey(raffleId, userAddress);
    final data = await _storage.read(key: key);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// Delete prediction after successful reveal (optional cleanup)
  Future<void> deletePrediction({
    required int raffleId,
    required String userAddress,
  }) async {
    final key = _getPredictionKey(raffleId, userAddress);
    await _storage.delete(key: key);
  }

  /// Check if user has a stored prediction for this raffle
  Future<bool> hasPrediction({
    required int raffleId,
    required String userAddress,
  }) async {
    final key = _getPredictionKey(raffleId, userAddress);
    return await _storage.containsKey(key: key);
  }

  /// Get all stored predictions for a user (across all raffles)
  Future<List<Map<String, dynamic>>> getAllUserPredictions(
    String userAddress,
  ) async {
    final allKeys = await _storage.readAll();
    final predictions = <Map<String, dynamic>>[];

    for (final entry in allKeys.entries) {
      if (entry.key.contains(userAddress.toLowerCase())) {
        try {
          final data = json.decode(entry.value) as Map<String, dynamic>;
          predictions.add(data);
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }

    return predictions;
  }

  String _getPredictionKey(int raffleId, String userAddress) {
    return 'prediction_${raffleId}_${userAddress.toLowerCase()}';
  }

  // ================================
  // PREDICTION VALIDATION
  // ================================

  /// Validate prediction format before submission
  bool isValidPrediction(String prediction) {
    // Expected format: "TeamA:0-TeamB:0" (at minimum)
    final regex = RegExp(r'^.+:\d+-.+:\d+$');
    return regex.hasMatch(prediction);
  }

  /// Parse prediction string back to components
  Map<String, dynamic>? parsePrediction(String prediction) {
    try {
      // Format: "ManU:2-Chelsea:1"
      final parts = prediction.split('-');
      if (parts.length != 2) return null;

      final teamAPart = parts[0].split(':');
      final teamBPart = parts[1].split(':');

      if (teamAPart.length != 2 || teamBPart.length != 2) return null;

      return {
        'teamA': teamAPart[0],
        'scoreA': int.parse(teamAPart[1]),
        'teamB': teamBPart[0],
        'scoreB': int.parse(teamBPart[1]),
      };
    } catch (e) {
      return null;
    }
  }

  // ================================
  // RESULT COMPARISON
  // ================================

  /// Compare user prediction with match result
  /// Returns true if prediction matches result exactly
  bool doesPredictionMatch(String prediction, String result) {
    return prediction.toLowerCase() == result.toLowerCase();
  }

  /// Determine outcome from scores (helper for result verification)
  String getOutcome({required int scoreA, required int scoreB}) {
    if (scoreA > scoreB) return 'home_win';
    if (scoreB > scoreA) return 'away_win';
    return 'draw';
  }

  // ================================
  // DEBUGGING / TESTING
  // ================================

  /// Verify commit matches prediction + secret (for testing)
  bool verifyCommit(String prediction, String secret, String commit) {
    final generatedCommit = generateCommit(prediction, secret);
    return generatedCommit.toLowerCase() == commit.toLowerCase();
  }

  /// Clear all stored predictions (for testing/logout)
  Future<void> clearAllPredictions() async {
    await _storage.deleteAll();
  }
}
