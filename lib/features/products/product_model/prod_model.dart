// lib/models/product.dart
//
// Product model — converts between Dart objects and SQLite rows.

class Product {
  final int? id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final int price;
  final int stock;
  final String icon;
  final String createdAt;

  const Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.stock,
    this.icon = '📦',
    this.createdAt = '',
  });

  // ── Serialization ──────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'category': category,
    'price': price,
    'stock': stock,
    'icon': icon,
    'created_at': createdAt,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] as int?,
    barcode: map['barcode'] as String,
    name: map['name'] as String,
    brand: map['brand'] as String,
    category: map['category'] as String,
    price: map['price'] as int,
    stock: map['stock'] as int,
    icon: map['icon'] as String? ?? '📦',
    createdAt: map['created_at'] as String? ?? '',
  );

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    int? price,
    int? stock,
    String? icon,
  }) => Product(
    id: id ?? this.id,
    barcode: barcode ?? this.barcode,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    category: category ?? this.category,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    icon: icon ?? this.icon,
    createdAt: createdAt,
  );
}
