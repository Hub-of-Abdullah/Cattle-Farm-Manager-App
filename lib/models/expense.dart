class Expense {
  final int? id;
  final int? ownerId;
  final DateTime date;
  final ExpenseCategory category;
  final String? customCategory; // used when category == other
  final double amount;
  final String? note;
  final DateTime createdAt;

  Expense({
    this.id,
    this.ownerId,
    required this.date,
    required this.category,
    this.customCategory,
    required this.amount,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Display label: shows customCategory when category is other.
  String displayCategory(String fallback) =>
      category == ExpenseCategory.other && customCategory != null && customCategory!.isNotEmpty
          ? customCategory!
          : fallback;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'date': date.toIso8601String(),
      'category': category.name,
      'custom_category': customCategory,
      'amount': amount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      category: ExpenseCategoryExtension.fromString(map['category'] as String),
      customCategory: map['custom_category'] as String?,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Expense copyWith({
    int? id,
    int? ownerId,
    DateTime? date,
    ExpenseCategory? category,
    String? customCategory,
    double? amount,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      date: date ?? this.date,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Expense{id: $id, ownerId: $ownerId, date: $date, category: $category, amount: $amount}';
}

enum ExpenseCategory { food, medicine, doctor, takeProfit, other }

extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food:
        return 'food';
      case ExpenseCategory.medicine:
        return 'medicine';
      case ExpenseCategory.doctor:
        return 'doctor';
      case ExpenseCategory.takeProfit:
        return 'takeProfit';
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
      case 'takeprofit':
      case 'getprofit':
        return ExpenseCategory.takeProfit;
      default:
        return ExpenseCategory.other;
    }
  }
}
