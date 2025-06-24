import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
      debugPrint('NotificationService inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar NotificationService: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notificação tocada: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) await init();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) await init();

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'backup_restore_channel',
            'Notificações de Backup e Restauração',
            channelDescription:
                'Canal para notificações de tarefas concluídas.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/ic_launcher',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('Notificação enviada: $title');
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
    }
  }

  Future<void> showSuccessNotification({
    required String operation,
    String? details,
  }) async {
    await showNotification(
      title: '$operation concluído!',
      body: details ?? 'A operação foi finalizada com sucesso.',
      payload: 'success_$operation',
    );
  }

  Future<void> showErrorNotification({
    required String operation,
    required String error,
  }) async {
    await showNotification(
      title: 'Erro no $operation',
      body: 'Não foi possível completar: $error',
      payload: 'error_$operation',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await init();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? enabled =
          await androidImplementation.areNotificationsEnabled();
      return enabled ?? false;
    }

    return false;
  }

  hasNotificationPermission() {
    return _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled() ??
        Future.value(false);
  }

  requestNotificationPermission() {
    return _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission() ??
        Future.value(false);
  }
}
