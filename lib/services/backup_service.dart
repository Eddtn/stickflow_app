// lib/services/backup_service.dart
//
// Handles all backup and restore operations.
// Export  → copies the SQLite .db file into a timestamped .stockflow_backup file
//            then shares it via the native share sheet.
// Import  → user picks a .stockflow_backup file, it replaces the current DB,
//            and the app reloads cleanly.
// CSV     → exports all products and all sales as two separate CSV strings
//            wrapped in a single shareable text file.

import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  // ── DB file path ──────────────────────────────────────────────────────────
  Future<String> get _dbPath async {
    final dbDir = await getDatabasesPath();
    return p.join(dbDir, 'pos_store.db');
  }

  // ── Export: share the raw SQLite file ────────────────────────────────────
  /// Copies the DB to a temp file named with a timestamp, then shares it.
  /// Returns true on success.
  Future<bool> exportDatabase() async {
    try {
      final src = File(await _dbPath);
      if (!src.existsSync()) return false;

      // Close DB so all WAL data is flushed
      await DatabaseHelper.instance.close();

      final dir = await getTemporaryDirectory();
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-')
          .substring(0, 19);
      final dest = File('${dir.path}/stockflow_backup_$ts.stockflow_backup');
      await src.copy(dest.path);

      // Re-open DB
      await DatabaseHelper.instance.database;

      await Share.shareXFiles(
        [XFile(dest.path)],
        subject: 'StockFlow Backup — $ts',
        text:
            'StockFlow database backup. Import this file inside the app to restore.',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Restore: pick a backup file and replace the DB ────────────────────────
  /// Opens a file picker, user selects a .stockflow_backup file.
  /// Returns a [RestoreResult] describing success or failure.
  Future<RestoreResult> restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult.cancelled();
      }

      final pickedPath = result.files.single.path;
      if (pickedPath == null)
        return RestoreResult.error('Could not read file path');

      // Basic validation — check it's a valid SQLite file
      final pickedFile = File(pickedPath);
      final header = await _readFileHeader(pickedFile);
      if (!header.startsWith('SQLite format')) {
        return RestoreResult.error(
          'Invalid backup file. Please select a valid .stockflow_backup file.',
        );
      }

      // Close the current DB before replacing
      await DatabaseHelper.instance.close();

      // Replace the DB file
      final dbPath = await _dbPath;
      await pickedFile.copy(dbPath);

      // Re-open (this triggers migrations if needed)
      await DatabaseHelper.instance.database;

      // Count restored records for the success message
      final products = await DatabaseHelper.instance.getAllProducts();
      final sales = await DatabaseHelper.instance.getAllSales();

      return RestoreResult.success(
        productCount: products.length,
        saleCount: sales.length,
      );
    } catch (e) {
      return RestoreResult.error('Restore failed: $e');
    }
  }

  // ── Export CSV ────────────────────────────────────────────────────────────
  /// Exports products + sales history as CSV and shares as a .txt file.
  Future<bool> exportCsv() async {
    try {
      final products = await DatabaseHelper.instance.getAllProducts();
      final sales = await DatabaseHelper.instance.getAllSales();

      final buffer = StringBuffer();

      // ── Products CSV ───────────────────────────────────────────────────
      buffer.writeln('=== PRODUCTS ===');
      buffer.writeln(
        'Barcode,Name,Brand,Category,Price (NGN),Stock,Alert Threshold',
      );
      for (final p in products) {
        buffer.writeln(
          '${p['barcode']},'
          '"${p['name']}",'
          '"${p['brand']}",'
          '"${p['category']}",'
          '${p['price']},'
          '${p['stock']},'
          '${p['alert_threshold'] ?? 10}',
        );
      }

      buffer.writeln();

      // ── Sales CSV ──────────────────────────────────────────────────────
      buffer.writeln('=== SALES HISTORY ===');
      buffer.writeln('Receipt No,Date,Items,Subtotal,VAT,Total (NGN)');
      for (final s in sales) {
        buffer.writeln(
          '"${s['receipt_no']}",'
          '"${s['sold_at']}",'
          '${s['item_count']},'
          '${(s['subtotal'] as double).toStringAsFixed(2)},'
          '${(s['vat'] as double).toStringAsFixed(2)},'
          '${(s['total'] as double).toStringAsFixed(2)}',
        );
      }

      // ── Sale items CSV ─────────────────────────────────────────────────
      buffer.writeln();
      buffer.writeln('=== SALE ITEMS ===');
      buffer.writeln(
        'Receipt No,Barcode,Product,Brand,Qty,Unit Price,Subtotal',
      );
      for (final s in sales) {
        final items = await DatabaseHelper.instance.getSaleItems(
          s['id'] as int,
        );
        for (final item in items) {
          buffer.writeln(
            '"${s['receipt_no']}",'
            '"${item['barcode']}",'
            '"${item['name']}",'
            '"${item['brand']}",'
            '${item['quantity']},'
            '${item['unit_price']},'
            '${(item['subtotal'] as double).toStringAsFixed(2)}',
          );
        }
      }

      // Write to temp file and share
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/stockflow_export_$ts.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'StockFlow Export — $ts',
        text: 'StockFlow products and sales data export.',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get backup info ───────────────────────────────────────────────────────
  /// Returns the last modified date of the DB file (proxy for last backup).
  Future<BackupInfo> getBackupInfo() async {
    final dbFile = File(await _dbPath);
    if (!dbFile.existsSync()) {
      return BackupInfo(exists: false, sizeKb: 0, lastModified: null);
    }
    final stat = await dbFile.stat();
    return BackupInfo(
      exists: true,
      sizeKb: (stat.size / 1024).round(),
      lastModified: stat.modified,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<String> _readFileHeader(File file) async {
    try {
      final bytes = await file.openRead(0, 16).toList();
      final flat = bytes.expand((b) => b).toList();
      return String.fromCharCodes(flat.take(16));
    } catch (_) {
      return '';
    }
  }
}

// ── Result types ─────────────────────────────────────────────────────────────
class RestoreResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;
  final int productCount;
  final int saleCount;

  RestoreResult._({
    required this.success,
    required this.cancelled,
    this.errorMessage,
    this.productCount = 0,
    this.saleCount = 0,
  });

  factory RestoreResult.success({
    required int productCount,
    required int saleCount,
  }) => RestoreResult._(
    success: true,
    cancelled: false,
    productCount: productCount,
    saleCount: saleCount,
  );

  factory RestoreResult.cancelled() =>
      RestoreResult._(success: false, cancelled: true);

  factory RestoreResult.error(String message) =>
      RestoreResult._(success: false, cancelled: false, errorMessage: message);
}

class BackupInfo {
  final bool exists;
  final int sizeKb;
  final DateTime? lastModified;

  BackupInfo({
    required this.exists,
    required this.sizeKb,
    required this.lastModified,
  });
}
