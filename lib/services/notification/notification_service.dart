// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockflow/database/database_helper.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _prefKey = 'last_low_stock_notif_day';

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // v17+ requires 'settings' as a named parameter
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // ── Throttled daily check ─────────────────────────────────────────────────
  Future<void> checkAndNotifyLowStock() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDay = prefs.getString(_prefKey) ?? '';

    final rows = await DatabaseHelper.instance.getLowStockProducts();
    if (rows.isEmpty) return;

    if (lastDay != today) {
      await _sendLowStockNotification(rows);
      await prefs.setString(_prefKey, today);
    }
  }

  // ── Force send (from Alerts screen) ──────────────────────────────────────
  Future<void> sendLowStockNow() async {
    final rows = await DatabaseHelper.instance.getLowStockProducts();
    if (rows.isEmpty) return;
    await _sendLowStockNotification(rows);
  }

  Future<void> _sendLowStockNotification(
    List<Map<String, dynamic>> products,
  ) async {
    final count = products.length;
    final names = products
        .take(3)
        .map((p) => '${p['icon']} ${p['name']} (${p['stock']} left)')
        .join(', ');
    final body = count > 3 ? '$names … +${count - 3} more' : names;
    final title = '⚠️  $count product${count == 1 ? '' : 's'} running low';

    final androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifies when product stock is running low',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id: 1001,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: 'low_stock',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
