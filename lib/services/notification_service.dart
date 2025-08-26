import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _syncNotificationId = 1;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(settings);
  }

  static Future<void> showSyncProgress({
    required int current,
    required int total,
    String? currentItem,
  }) async {
    final progress = ((current / total) * 100).round();
    
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronização',
      channelDescription: 'Progresso da sincronização de cifras',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      onlyAlertOnce: true,
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _syncNotificationId,
      'Sincronizando cifras',
      currentItem != null 
        ? '$current/$total - $currentItem'
        : '$current/$total cifras processadas ($progress%)',
      details,
    );
  }

  static Future<void> showSyncComplete(int total) async {
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronização',
      channelDescription: 'Progresso da sincronização de cifras',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _syncNotificationId,
      'Sincronização concluída',
      '$total cifras sincronizadas com sucesso!',
      details,
    );
  }

  static Future<void> cancelSyncNotification() async {
    await _notifications.cancel(_syncNotificationId);
  }
}