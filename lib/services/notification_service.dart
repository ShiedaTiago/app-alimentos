import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notificações locais agendadas (RF22). Não usa Firebase: tudo fica no aparelho.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'expiry_alerts',
    'Alertas de validade',
    channelDescription: 'Aviso diário de alimentos perto de vencer',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    // Fuso fixo: o app é usado no Brasil.
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Pede permissão no Android 13+. Nas versões antigas já vem liberada.
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Troca todos os avisos agendados pelos de [alerts] (data/hora → texto).
  Future<void> replaceSchedule(Map<DateTime, String> alerts) async {
    await _plugin.cancelAll();
    var id = 0;
    for (final MapEntry(key: date, value: body) in alerts.entries) {
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: tz.TZDateTime.from(date, tz.local),
        title: 'Alimentos vencendo',
        body: body,
        notificationDetails: const NotificationDetails(android: _channel),
        // Inexato: não precisa da permissão de alarme exato; pode atrasar minutos.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
