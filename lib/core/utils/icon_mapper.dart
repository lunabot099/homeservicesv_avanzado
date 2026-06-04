/// icon_mapper.dart
/// Convierte strings de nombres de ícono Material a IconData.
/// Usado para mapear íconos guardados en la BD al widget Flutter.
library;

import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  static IconData fromString(String? codigo) {
    switch (codigo) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'foundation':
        return Icons.foundation_rounded;
      case 'carpenter':
        return Icons.carpenter_rounded;
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      case 'grid_view':
        return Icons.grid_view_rounded;
      case 'roofing':
        return Icons.roofing_rounded;
      case 'format_paint':
        return Icons.format_paint_rounded;
      case 'hardware':
        return Icons.hardware_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'handyman':
        return Icons.handyman_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}
