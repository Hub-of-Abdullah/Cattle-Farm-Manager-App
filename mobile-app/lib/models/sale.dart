class Sale {
  final int? id;
  final int cattleId;
  final DateTime saleDate;
  final double salePrice;
  final String? buyerName;
  final DateTime createdAt;

  Sale({
    this.id,
    required this.cattleId,
    required this.saleDate,
    required this.salePrice,
    this.buyerName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Sale to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cattle_id': cattleId,
      'sale_date': saleDate.toIso8601String(),
      'sale_price': salePrice,
      'buyer_name': buyerName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Sale from Map (database query result)
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      cattleId: map['cattle_id'] as int,
      saleDate: DateTime.parse(map['sale_date'] as String),
      salePrice: (map['sale_price'] as num).toDouble(),
      buyerName: map['buyer_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Create a copy of Sale with modified fields
  Sale copyWith({
    int? id,
    int? cattleId,
    DateTime? saleDate,
    double? salePrice,
    String? buyerName,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      cattleId: cattleId ?? this.cattleId,
      saleDate: saleDate ?? this.saleDate,
      salePrice: salePrice ?? this.salePrice,
      buyerName: buyerName ?? this.buyerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Sale{id: $id, cattleId: $cattleId, saleDate: $saleDate, salePrice: $salePrice, buyerName: $buyerName}';
  }
}
