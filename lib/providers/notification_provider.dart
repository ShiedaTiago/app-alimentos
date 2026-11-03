import 'package:flutter/foundation.dart';

import '../core/utils/expiry_alert.dart';
import '../services/notification_service.dart';
import 'item_provider.dart';

/// Reagenda o alerta diário sempre que a lista de alimentos muda.
/// Agenda um aviso por dia (9h) para os próximos dias, cada um com o
/// texto daquele dia — assim funciona mesmo sem abrir o app.
class NotificationProvider {
  NotificationProvider(this._items, this._service) {
    _items.addListener(_reschedule);
  }

  final ItemProvider _items;
  final NotificationService _service;

  static const _daysAhead = 7;
  static const _alertHour = 9;

  String _lastSchedule = '';

  Future<void> _reschedule() async {
    if (_items.isLoading) return;
    final alerts = <DateTime, String>{};
    final now = DateTime.now();
    for (var offset = 0; offset < _daysAhead; offset++) {
      final when = DateTime(now.year, now.month, now.day + offset, _alertHour);
      if (when.isBefore(now)) continue;
      final text = expiryAlertText(_items.items, when);
      if (text != null) alerts[when] = text;
    }
    // O ItemProvider notifica por vários motivos; só reagenda se mudou algo.
    final signature = alerts.toString();
    if (signature == _lastSchedule) return;
    _lastSchedule = signature;
    try {
      await _service.replaceSchedule(alerts);
    } catch (e) {
      // Falha ao agendar não pode quebrar o app; só registra no console.
      debugPrint('Falha ao agendar notificações: $e');
    }
  }

  void dispose() => _items.removeListener(_reschedule);
}
