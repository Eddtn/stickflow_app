// lib/models/seller.dart

class Seller {
  final int? id;
  final String name;
  final String pin;
  final String role; // 'owner' | 'cashier'
  final bool isActive;
  final String createdAt;

  const Seller({
    this.id,
    required this.name,
    required this.pin,
    this.role = 'cashier',
    this.isActive = true,
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'pin': pin,
    'role': role,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
  };

  factory Seller.fromMap(Map<String, dynamic> m) => Seller(
    id: m['id'] as int?,
    name: m['name'] as String,
    pin: m['pin'] as String,
    role: m['role'] as String? ?? 'cashier',
    isActive: (m['is_active'] as int?) == 1,
    createdAt: m['created_at'] as String? ?? '',
  );

  bool get isOwner => role == 'owner';
}
