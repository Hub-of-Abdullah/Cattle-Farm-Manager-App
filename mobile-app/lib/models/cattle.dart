class Cattle {
  final int? id;
  final int ownerId;
  final String cattleUniqueId;
  final DateTime purchaseDate;
  final double purchasePrice;
  final bool isSold;
  final DateTime createdAt;

  Cattle({
    this.id,
    required this.ownerId,
    required this.cattleUniqueId,
    required this.purchaseDate,
    required this.purchasePrice,
    this.isSold = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Cattle to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'cattle_unique_id': cattleUniqueId,
      'purchase_date': purchaseDate.toIso8601String(),
      'purchase_price': purchasePrice,
      'is_sold': isSold ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Cattle from Map (database query result)
  factory Cattle.fromMap(Map<String, dynamic> map) {
    return Cattle(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      cattleUniqueId: map['cattle_unique_id'] as String,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      isSold: (map['is_sold'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Create a copy of Cattle with modified fields
  Cattle copyWith({
    int? id,
    int? ownerId,
    String? cattleUniqueId,
    DateTime? purchaseDate,
    double? purchasePrice,
    bool? isSold,
    DateTime? createdAt,
  }) {
    return Cattle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cattleUniqueId: cattleUniqueId ?? this.cattleUniqueId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      isSold: isSold ?? this.isSold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Cattle{id: $id, ownerId: $ownerId, cattleUniqueId: $cattleUniqueId, purchasePrice: $purchasePrice, isSold: $isSold}';
  }
}
