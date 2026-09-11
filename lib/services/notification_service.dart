import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_timezone;
class NotificationService {
  static final NotificationService instance =
      NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'smart_agenda_channel';
  static const String _channelName = 'SmartAgenda';
  static const String _channelDescription =
      'Notifications des rendez-vous SmartAgenda';

 Future<void> initialize() async {
  tz.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await _notifications.initialize(
    settings: initializationSettings,
  );

  await _requestPermissions();
}

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  /// Affiche une notification immédiatement.
  /// Utilisée uniquement pour les tests.
  Future<void> showTestNotification() async {
    await _notifications.show(
      id: 1,
      title: 'SmartAgenda 🔔',
      body: 'Ceci est une notification de test.',
      notificationDetails: _notificationDetails(),
    );
  }
  Future<void> scheduleTestNotification() async {
  final dateTime = DateTime.now().add(
    const Duration(minutes: 1),
  );

  await scheduleNotification(
    id: 999,
    dateTime: dateTime,
    title: 'SmartAgenda ⏰',
    body: 'Notification programmée avec succès !',
  );
}

  /// Programme une notification à une date et heure précises.
  Future<void> scheduleNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      id: id,
      scheduledDate: tz_timezone.TZDateTime.from(
  dateTime,
  tz_timezone.local,
),
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Annule une notification programmée.
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  /// Annule toutes les notifications programmées.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    return const NotificationDetails(
      android: androidDetails,
    );
  }
}