import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  static final _currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatCurrency(double amount) => _currency.format(amount);
  static String formatDate(DateTime date) => _date.format(date);
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFD63031) : const Color(0xFF00B894),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText,
                style: TextStyle(
                    color: isDestructive
                        ? const Color(0xFFD63031)
                        : const Color(0xFF6C5CE7))),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
