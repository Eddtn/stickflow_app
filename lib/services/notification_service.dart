// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final _plugin = FlutterLocalNotificationsPlugin();
//   static bool _initialized = false;

//   static Future<void> init() async {
//     if (_initialized) return;
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const ios = DarwinInitializationSettings();
//     await _plugin
//         .initialize(const InitializationSettings(android: android, iOS: ios));
//     _initialized = true;
//   }

//   static Future<void> showLowStockAlert(
//       String productName, int quantity) async {
//     await _plugin.show(
//       productName.hashCode,
//       'Low Stock Alert',
//       '$productName is running low — only $quantity left',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'low_stock',
//           'Low Stock Alerts',
//           channelDescription: 'Alerts when stock falls below threshold',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//     );
//   }

//   static Future<void> showOutOfStockAlert(String productName) async {
//     await _plugin.show(
//       productName.hashCode + 1,
//       'Out of Stock!',
//       '$productName is completely out of stock',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'low_stock',
//           'Low Stock Alerts',
//           channelDescription: 'Alerts when stock falls below threshold',
//           importance: Importance.max,
//           priority: Priority.max,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//     );
//   }
// }
