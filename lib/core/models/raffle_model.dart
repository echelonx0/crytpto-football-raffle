// raffle_model.dart (reuse from previous artifact)
class RaffleModel {
  final String raffleId;
  final String creator;
  final String prizePool;
  final String participantCount;
  final int startTime;
  final int endTime;
  final bool drawn;
  final bool cancelled;

  RaffleModel({
    required this.raffleId,
    required this.creator,
    required this.prizePool,
    required this.participantCount,
    required this.startTime,
    required this.endTime,
    required this.drawn,
    required this.cancelled,
  });

  factory RaffleModel.fromJson(Map<String, dynamic> json) {
    return RaffleModel(
      raffleId: json['raffleId'].toString(),
      creator: json['creator'],
      prizePool: json['prizePool'],
      participantCount: json['participantCount'].toString(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      drawn: json['drawn'],
      cancelled: json['cancelled'],
    );
  }

  Map<String, dynamic> toJson() => {
    'raffleId': raffleId,
    'creator': creator,
    'prizePool': prizePool,
    'participantCount': participantCount,
    'startTime': startTime,
    'endTime': endTime,
    'drawn': drawn,
    'cancelled': cancelled,
  };
}

class RaffleDetailModel extends RaffleModel {
  final String? winner;
  final bool seedRevealed;
  final int revealDeadline;
  final List<String> participants;

  RaffleDetailModel({
    required super.raffleId,
    required super.creator,
    required super.prizePool,
    required super.participantCount,
    required super.startTime,
    required super.endTime,
    required super.drawn,
    required super.cancelled,
    this.winner,
    required this.seedRevealed,
    required this.revealDeadline,
    required this.participants,
  });

  factory RaffleDetailModel.fromJson(Map<String, dynamic> json) {
    return RaffleDetailModel(
      raffleId: json['raffleId'].toString(),
      creator: json['creator'],
      prizePool: json['prizePool'],
      participantCount: json['participantCount'].toString(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      drawn: json['drawn'],
      cancelled: json['cancelled'],
      winner: json['winner'],
      seedRevealed: json['seedRevealed'],
      revealDeadline: json['revealDeadline'],
      participants: List<String>.from(json['participants']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'winner': winner,
      'seedRevealed': seedRevealed,
      'revealDeadline': revealDeadline,
      'participants': participants,
    });
    return json;
  }
}
