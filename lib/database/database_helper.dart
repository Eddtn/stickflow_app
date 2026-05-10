// lib/database/database_helper.dart
//
// Singleton SQLite database helper.
// Handles all product CRUD operations — fully offline, no internet needed.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // ── Singleton setup ──────────────────────────────────────────────────────
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // ── Init & schema ────────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_store.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode     TEXT    NOT NULL UNIQUE,
        name        TEXT    NOT NULL,
        brand       TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        price       INTEGER NOT NULL,
        stock       INTEGER NOT NULL DEFAULT 0,
        icon        TEXT    NOT NULL DEFAULT '📦',
        created_at  TEXT    NOT NULL
      )
    ''');

    // Seed with demo products so the app works out of the box
    await _seedProducts(db);
  }

  Future<void> _seedProducts(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = [
      {
        'barcode': '123456789',
        'name': 'Rice 5kg',
        'brand': 'Golden Penny',
        'category': 'Grains',
        'price': 14500,
        'stock': 48,
        'icon': '🌾',
        'created_at': now,
      },
      {
        'barcode': '987654321',
        'name': 'Indomie Carton',
        'brand': 'Dufil Prima',
        'category': 'Noodles',
        'price': 3200,
        'stock': 120,
        'icon': '🍜',
        'created_at': now,
      },
      {
        'barcode': '555555555',
        'name': 'Peak Milk 400g Tin',
        'brand': 'FrieslandCampina',
        'category': 'Dairy',
        'price': 850,
        'stock': 60,
        'icon': '🥛',
        'created_at': now,
      },
      {
        'barcode': '111222333',
        'name': 'Dangote Sugar 1kg',
        'brand': 'Dangote',
        'category': 'Sweeteners',
        'price': 450,
        'stock': 200,
        'icon': '🍬',
        'created_at': now,
      },
      {
        'barcode': '444555666',
        'name': 'Dangote Cement 50kg',
        'brand': 'Dangote',
        'category': 'Building Materials',
        'price': 3850,
        'stock': 85,
        'icon': '🏗️',
        'created_at': now,
      },
      {
        'barcode': '777888999',
        'name': 'Sunlight Soap 800g',
        'brand': 'Unilever',
        'category': 'Cleaning',
        'price': 680,
        'stock': 150,
        'icon': '🧼',
        'created_at': now,
      },
    ];

    for (final product in seeds) {
      await db.insert('products', product);
    }
  }

  // ── CRUD Operations ──────────────────────────────────────────────────────

  /// Insert a new product. Returns the new row id.
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    product['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all products ordered by name.
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  /// Fetch a single product by barcode. Returns null if not found.
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Update an existing product by id. Returns number of rows affected.
  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  /// Decrease stock by [quantity] after a sale (won't go below 0).
  Future<void> decreaseStock(String barcode, int quantity) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE products
      SET stock = MAX(0, stock - ?)
      WHERE barcode = ?
    ''',
      [quantity, barcode],
    );
  }

  /// Delete a product by id. Returns number of rows deleted.
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Search products by name, brand, or barcode.
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    final q = '%$query%';
    return await db.query(
      'products',
      where: 'name LIKE ? OR brand LIKE ? OR barcode LIKE ? OR category LIKE ?',
      whereArgs: [q, q, q, q],
      orderBy: 'name ASC',
    );
  }

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
