import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/raffle_model.dart';

class RaffleService {
  // 🔗 Base URL of your deployed Firebase Functions
  static const String _baseUrl =
      'https://us-central1-khedoodating.cloudfunctions.net';

  // =======================
  // Get all active raffles
  // =======================
  Future<List<RaffleModel>> getActiveRaffles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getActiveRaffles'));
      final data = json.decode(response.body);

      if (data['success']) {
        final List raffles = data['data'];
        return raffles.map((r) => RaffleModel.fromJson(r)).toList();
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to fetch raffles: $e');
    }
  }

  // =======================
  // Get raffle details
  // =======================
  Future<RaffleDetailModel> getRaffleDetails(String raffleId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getRaffleDetails'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'raffleId': raffleId}),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return RaffleDetailModel.fromJson(data['data']);
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to fetch raffle details: $e');
    }
  }

  // =======================
  // Get participant bet
  // =======================
  Future<String> getParticipantBet(String raffleId, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getParticipantBet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'raffleId': raffleId,
          'participantAddress': address,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return data['data']['betAmount'];
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to fetch bet: $e');
    }
  }

  // =======================
  // Check if raffle is active
  // =======================
  Future<bool> isRaffleActive(String raffleId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/isRaffleActive'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'raffleId': raffleId}),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return data['data']['isActive'];
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to check raffle status: $e');
    }
  }

  // =======================
  // Get raffle count
  // =======================
  Future<int> getRaffleCount() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getRaffleCount'));
      final data = json.decode(response.body);

      if (data['success']) {
        return int.parse(data['data']['count']);
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to fetch raffle count: $e');
    }
  }

  // =======================
  // Generate seed commit
  // =======================
  Future<String> generateSeedCommit(String seed) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generateSeedCommit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'seed': seed}),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return data['data']['seedCommit'];
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to generate seed: $e');
    }
  }

  // =======================
  // Prepare raffle creation data
  // =======================
  Future<Map<String, dynamic>> prepareCreateRaffleData({
    required double minBet,
    double? maxBet,
    int? maxParticipants,
    required int durationHours,
    required int creatorFee,
    required String seed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/prepareCreateRaffleData'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'minBet': minBet,
          'maxBet': maxBet,
          'maxParticipants': maxParticipants,
          'durationHours': durationHours,
          'creatorFee': creatorFee,
          'seed': seed,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return Map<String, dynamic>.from(data['data']);
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to prepare raffle data: $e');
    }
  }

  // =======================
  // Listen to raffle events
  // =======================
  Future<List<dynamic>> getRaffleEvents({
    String? raffleId,
    int? fromBlock,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/listenToRaffleEvents'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'raffleId': raffleId, 'fromBlock': fromBlock}),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        return List<dynamic>.from(data['data']);
      }
      throw Exception(data['error']);
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }
}
