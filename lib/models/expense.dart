class Expense {
  final int? id;
  final int? cattleId; // Nullable for general farm expenses
  final DateTime date;
  final ExpenseCategory category;
  final double amount;
  final String? note;
  final DateTime createdAt;

  Expense({
    this.id,
    this.cattleId,
    required this.date,
    required this.category,
    required this.amount,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Expense to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cattle_id': cattleId,
      'date': date.toIso8601String(),
      'category': category.name,
      'amount': amount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Expense from Map (database query result)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      cattleId: map['cattle_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      category: ExpenseCategoryExtension.fromString(map['category'] as String),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Create a copy of Expense with modified fields
  Expense copyWith({
    int? id,
    int? cattleId,
    DateTime? date,
    ExpenseCategory? category,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      cattleId: cattleId ?? this.cattleId,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, cattleId: $cattleId, date: $date, category: $category, amount: $amount}';
  }
}

// Expense categories enum
enum ExpenseCategory {
  food,
  medicine,
  doctor,
  other,
}

// Extension for ExpenseCategory
extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food:
        return 'food';
      case ExpenseCategory.medicine:
        return 'medicine';
      case ExpenseCategory.doctor:
        return 'doctor';
      case ExpenseCategory.other:
        return 'other';
    }
  }

  static ExpenseCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'food':
        return ExpenseCategory.food;
      case 'medicine':
        return ExpenseCategory.medicine;
      case 'doctor':
        return ExpenseCategory.doctor;
      case 'other':
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }
}
