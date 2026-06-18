import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_store.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  // ── onCreate — fresh install ───────────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await _createProductsTable(db);
    await _createSalesTables(db);
    await _createSellersTable(db);
    await _seedProducts(db);
    await _seedOwner(db);
  }

  // ── onUpgrade — existing users updating the app ───────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createSalesTables(db);
    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE products ADD COLUMN alert_threshold INTEGER NOT NULL DEFAULT 10',
        );
      } catch (_) {}
    }
    if (oldVersion < 4) await _createSellersTable(db);
  }

  // ── onOpen — safety net, runs every launch ────────────────────────────────
  // Ensures all columns and tables exist regardless of version history.
  Future<void> _onOpen(Database db) async {
    // Safely add alert_threshold if missing
    try {
      await db.execute(
        'ALTER TABLE products ADD COLUMN alert_threshold INTEGER NOT NULL DEFAULT 10',
      );
    } catch (_) {}

    // Safely create sales tables if missing
    await _createSalesTables(db);

    // Safely create sellers table if missing
    await _createSellersTable(db);

    // Safely add seller columns to sales if missing
    try {
      await db.execute(
        'ALTER TABLE sales ADD COLUMN seller_id INTEGER REFERENCES sellers(id)',
      );
    } catch (_) {}
    try {
      await db.execute(
        'ALTER TABLE sales ADD COLUMN seller_name TEXT NOT NULL DEFAULT "Owner"',
      );
    } catch (_) {}

    // Always ensure at least one owner account exists
    await _seedOwner(db);
  }

  // ── Table creators ─────────────────────────────────────────────────────────
  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode           TEXT    NOT NULL UNIQUE,
        name              TEXT    NOT NULL,
        brand             TEXT    NOT NULL,
        category          TEXT    NOT NULL,
        price             INTEGER NOT NULL,
        stock             INTEGER NOT NULL DEFAULT 0,
        icon              TEXT    NOT NULL DEFAULT '📦',
        alert_threshold   INTEGER NOT NULL DEFAULT 10,
        created_at        TEXT    NOT NULL
      )
    ''');
  }

  Future<void> _createSalesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_no   TEXT    NOT NULL UNIQUE,
        subtotal     REAL    NOT NULL,
        vat          REAL    NOT NULL,
        total        REAL    NOT NULL,
        item_count   INTEGER NOT NULL,
        seller_id    INTEGER REFERENCES sellers(id),
        seller_name  TEXT    NOT NULL DEFAULT 'Owner',
        sold_at      TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id     INTEGER NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
        barcode     TEXT    NOT NULL,
        name        TEXT    NOT NULL,
        brand       TEXT    NOT NULL,
        icon        TEXT    NOT NULL DEFAULT '📦',
        unit_price  INTEGER NOT NULL,
        quantity    INTEGER NOT NULL,
        subtotal    REAL    NOT NULL
      )
    ''');
  }

  Future<void> _createSellersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sellers (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        pin        TEXT    NOT NULL,
        role       TEXT    NOT NULL DEFAULT 'cashier',
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT    NOT NULL
      )
    ''');
  }

  // ── Seeds ──────────────────────────────────────────────────────────────────
  Future<void> _seedOwner(Database db) async {
    // Only insert if no owner exists
    final owners = await db.query(
      'sellers',
      where: 'role = ?',
      whereArgs: ['owner'],
      limit: 1,
    );
    if (owners.isEmpty) {
      await db.insert('sellers', {
        'name': 'Owner',
        'pin': '0000',
        'role': 'owner',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _seedProducts(Database db) async {
    final now = DateTime.now().toIso8601String();
    final rows = [
      {
        'barcode': '123456789',
        'name': 'Rice 5kg',
        'brand': 'Golden Penny',
        'category': 'Grains',
        'price': 14500,
        'stock': 48,
        'icon': '🌾',
        'alert_threshold': 10,
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
        'alert_threshold': 10,
        'created_at': now,
      },
      {
        'barcode': '555555555',
        'name': 'Peak Milk 400g',
        'brand': 'FrieslandCampina',
        'category': 'Dairy',
        'price': 850,
        'stock': 60,
        'icon': '🥛',
        'alert_threshold': 10,
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
        'alert_threshold': 10,
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
        'alert_threshold': 10,
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
        'alert_threshold': 10,
        'created_at': now,
      },
    ];
    for (final row in rows) {
      await db.insert(
        'products',
        row,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // ── Close ──────────────────────────────────────────────────────────────────
  Future<void> close() async {
    final db = await database;
    _db = null;
    await db.close();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    product['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

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

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

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

  Future<void> decreaseStock(String barcode, int quantity) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE products SET stock = MAX(0, stock - ?) WHERE barcode = ?
    ''',
      [quantity, barcode],
    );
  }

  Future<void> increaseStock(int productId, int quantity) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE products SET stock = stock + ? WHERE id = ?
    ''',
      [quantity, productId],
    );
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    final db = await database;
    try {
      return await db.rawQuery('''
        SELECT * FROM products WHERE stock <= alert_threshold ORDER BY stock ASC
      ''');
    } catch (_) {
      return await db.rawQuery('''
        SELECT * FROM products WHERE stock <= 10 ORDER BY stock ASC
      ''');
    }
  }

  Future<void> setAlertThreshold(int productId, int threshold) async {
    final db = await database;
    await db.update(
      'products',
      {'alert_threshold': threshold},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> getLowStockCount() async {
    final db = await database;
    try {
      final r = await db.rawQuery('''
        SELECT COUNT(*) as cnt FROM products WHERE stock <= alert_threshold
      ''');
      return (r.first['cnt'] as int?) ?? 0;
    } catch (_) {
      final r = await db.rawQuery('''
        SELECT COUNT(*) as cnt FROM products WHERE stock <= 10
      ''');
      return (r.first['cnt'] as int?) ?? 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SALES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> insertSale({
    required String receiptNo,
    required double subtotal,
    required double vat,
    required double total,
    required List<Map<String, dynamic>> items,
    int? sellerId,
    String sellerName = 'Owner',
  }) async {
    final db = await database;
    int saleId = 0;
    await db.transaction((txn) async {
      saleId = await txn.insert('sales', {
        'receipt_no': receiptNo,
        'subtotal': subtotal,
        'vat': vat,
        'total': total,
        'item_count': items.fold<int>(0, (s, i) => s + (i['quantity'] as int)),
        'seller_id': sellerId,
        'seller_name': sellerName,
        'sold_at': DateTime.now().toIso8601String(),
      });
      for (final item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'barcode': item['barcode'],
          'name': item['name'],
          'brand': item['brand'] ?? '',
          'icon': item['icon'] ?? '📦',
          'unit_price': item['price'],
          'quantity': item['quantity'],
          'subtotal': (item['price'] as int) * (item['quantity'] as int),
        });
      }
    });
    return saleId;
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await database;
    return await db.query('sales', orderBy: 'sold_at DESC');
  }

  Future<List<Map<String, dynamic>>> getSalesByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final db = await database;
    return await db.query(
      'sales',
      where: 'sold_at >= ? AND sold_at <= ?',
      whereArgs: [
        from.toIso8601String(),
        to.add(const Duration(days: 1)).toIso8601String(),
      ],
      orderBy: 'sold_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await database;
    return await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
  }

  Future<void> deleteSale(int saleId) async {
    final db = await database;
    await db.delete('sales', where: 'id = ?', whereArgs: [saleId]);
  }

  Future<Map<String, dynamic>> getSalesSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String where = '';
    List<dynamic> args = [];
    if (from != null && to != null) {
      where = 'WHERE sold_at >= ? AND sold_at <= ?';
      args = [
        from.toIso8601String(),
        to.add(const Duration(days: 1)).toIso8601String(),
      ];
    }
    final r = await db.rawQuery('''
      SELECT
        COUNT(*)                                AS transaction_count,
        CAST(COALESCE(SUM(total),0) AS REAL)    AS total_revenue,
        CAST(COALESCE(AVG(total),0) AS REAL)    AS avg_order_value,
        COALESCE(SUM(item_count),0)             AS total_items_sold
      FROM sales $where
    ''', args);
    final row = r.first;
    return {
      'transaction_count': (row['transaction_count'] as int?) ?? 0,
      'total_revenue': ((row['total_revenue'] as num?) ?? 0).toDouble(),
      'avg_order_value': ((row['avg_order_value'] as num?) ?? 0).toDouble(),
      'total_items_sold': (row['total_items_sold'] as int?) ?? 0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SELLERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> insertSeller(Map<String, dynamic> seller) async {
    final db = await database;
    seller['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'sellers',
      seller,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllSellers() async {
    final db = await database;
    return await db.query(
      'sellers',
      where: 'is_active = 1',
      orderBy: 'role DESC, name ASC',
    );
  }

  Future<Map<String, dynamic>?> getSellerByPin(String pin) async {
    final db = await database;
    final rows = await db.query(
      'sellers',
      where: 'pin = ? AND is_active = 1',
      whereArgs: [pin],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<int> updateSeller(Map<String, dynamic> seller) async {
    final db = await database;
    return await db.update(
      'sellers',
      seller,
      where: 'id = ?',
      whereArgs: [seller['id']],
    );
  }

  Future<void> deactivateSeller(int id) async {
    final db = await database;
    await db.update(
      'sellers',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSalesBySeller(
    int sellerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String where = 'seller_id = ?';
    List<dynamic> args = [sellerId];
    if (from != null && to != null) {
      where += ' AND sold_at >= ? AND sold_at <= ?';
      args.addAll([
        from.toIso8601String(),
        to.add(const Duration(days: 1)).toIso8601String(),
      ]);
    }
    return await db.query(
      'sales',
      where: where,
      whereArgs: args,
      orderBy: 'sold_at DESC',
    );
  }

  Future<Map<String, dynamic>> getSellerSummary(
    int sellerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String where = 'WHERE seller_id = ?';
    List<dynamic> args = [sellerId];
    if (from != null && to != null) {
      where += ' AND sold_at >= ? AND sold_at <= ?';
      args.addAll([
        from.toIso8601String(),
        to.add(const Duration(days: 1)).toIso8601String(),
      ]);
    }
    final r = await db.rawQuery('''
      SELECT
        COUNT(*)                                AS transaction_count,
        CAST(COALESCE(SUM(total),0) AS REAL)    AS total_revenue,
        CAST(COALESCE(AVG(total),0) AS REAL)    AS avg_order_value,
        COALESCE(SUM(item_count),0)             AS total_items_sold
      FROM sales $where
    ''', args);
    final row = r.first;
    return {
      'transaction_count': (row['transaction_count'] as int?) ?? 0,
      'total_revenue': ((row['total_revenue'] as num?) ?? 0).toDouble(),
      'avg_order_value': ((row['avg_order_value'] as num?) ?? 0).toDouble(),
      'total_items_sold': (row['total_items_sold'] as int?) ?? 0,
    };
  }
}
