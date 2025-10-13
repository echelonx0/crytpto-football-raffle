// transaction_model.dart
enum TransactionStatus { pending, submitted, confirmed, failed }

class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final String? hash;
  final TransactionStatus status;
  final Map<String, dynamic> metadata;
  final String? error;
  final int? blockNumber;
  final int? gasUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    this.hash,
    required this.status,
    required this.metadata,
    this.error,
    this.blockNumber,
    this.gasUsed,
    required this.createdAt,
    this.updatedAt,
  });

  TransactionModel copyWith({
    String? id,
    String? hash,
    TransactionStatus? status,
    String? error,
    int? blockNumber,
    int? gasUsed,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId,
      type: type,
      hash: hash ?? this.hash,
      status: status ?? this.status,
      metadata: metadata,
      error: error ?? this.error,
      blockNumber: blockNumber ?? this.blockNumber,
      gasUsed: gasUsed ?? this.gasUsed,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'hash': hash,
    'status': status.name,
    'metadata': metadata,
    'error': error,
    'blockNumber': blockNumber,
    'gasUsed': gasUsed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] ?? '',
        userId: json['userId'],
        type: json['type'],
        hash: json['hash'],
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.pending,
        ),
        metadata: json['metadata'] ?? {},
        error: json['error'],
        blockNumber: json['blockNumber'],
        gasUsed: json['gasUsed'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}
