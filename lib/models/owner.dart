class Owner {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  Owner({
    this.id,
    required this.name,
    this.phone,
    this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Owner to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Owner from Map (database query result)
  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Create a copy of Owner with modified fields
  Owner copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return Owner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Owner{id: $id, name: $name, phone: $phone, address: $address}';
  }
}
