import 'package:flutter/material.dart';

import '../core/utils/date_utils.dart';
import '../core/utils/expiry.dart';
import '../models/food_item.dart';

/// Etiqueta colorida com o status de validade (RN01) e quantos dias faltam.
class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({super.key, required this.expiresAt});

  final DateTime expiresAt;

  static Color colorOf(ExpiryStatus status) => switch (status) {
    ExpiryStatus.expired => Colors.red.shade700,
    ExpiryStatus.critical => Colors.deepOrange,
    ExpiryStatus.warning => Colors.amber.shade800,
    ExpiryStatus.ok => Colors.green.shade700,
  };

  static String labelOf(ExpiryStatus status) => switch (status) {
    ExpiryStatus.expired => 'Vencidos',
    ExpiryStatus.critical => 'Críticos',
    ExpiryStatus.warning => 'Atenção',
    ExpiryStatus.ok => 'Em dia',
  };

  String _text(int days) {
    if (days < -1) return 'Venceu há ${-days} dias';
    if (days == -1) return 'Venceu ontem';
    if (days == 0) return 'Vence hoje';
    if (days == 1) return 'Vence amanhã';
    return 'Vence em $days dias';
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOf(expiryStatusFor(expiresAt));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        _text(daysUntil(expiresAt)),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
