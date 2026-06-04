/// service_tag.dart
/// Chip/etiqueta de estado de servicio o de urgencia.
library;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/solicitud_servicio_model.dart';

class ServiceTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const ServiceTag({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    this.icon,
  });

  /// Construye un tag a partir de la urgencia de la solicitud.
  factory ServiceTag.urgencia(UrgenciaSolicitud urgencia) {
    Color color;
    switch (urgencia) {
      case UrgenciaSolicitud.urgente:
        color = AppColors.error;
      case UrgenciaSolicitud.hoy:
        color = AppColors.accent;
      case UrgenciaSolicitud.manana:
        color = AppColors.warning;
      case UrgenciaSolicitud.esta_semana:
        color = AppColors.info;
      case UrgenciaSolicitud.flexible:
        color = AppColors.workerRole;
    }
    return ServiceTag(label: urgencia.label, color: color);
  }

  /// Construye un tag para el estado de la solicitud.
  factory ServiceTag.estado(EstadoSolicitud estado) {
    Color color;
    switch (estado) {
      case EstadoSolicitud.en_busqueda:
        color = AppColors.info;
      case EstadoSolicitud.confirmada:
        color = AppColors.workerRole;
      case EstadoSolicitud.en_proceso:
        color = AppColors.primary;
      case EstadoSolicitud.completada:
        color = AppColors.success;
      case EstadoSolicitud.cancelada:
        color = AppColors.error;
      default:
        color = AppColors.grey500;
    }
    return ServiceTag(label: estado.label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
