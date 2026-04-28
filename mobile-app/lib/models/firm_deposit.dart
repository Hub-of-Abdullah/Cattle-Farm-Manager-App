class FirmDeposit {
  final int? id;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  FirmDeposit({
    this.id,
    required this.amount,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FirmDeposit.fromMap(Map<String, dynamic> map) {
    return FirmDeposit(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  FirmDeposit copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return FirmDeposit(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
