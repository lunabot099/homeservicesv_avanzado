/// app_colors.dart
/// Paleta de colores centralizada de HomeServiceSV.
/// TODOS los colores de la app deben venir de aquí.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // No instanciar

  // ── Primarios ────────────────────────────────────────────────
  /// Terracota — color principal de la marca (#C14A2C)
  static const Color primary = Color(0xFFC14A2C);

  /// Variante clara del primario (superficies, fondos de chip, badges)
  static const Color primaryLight = Color(0xFFF9E5DF);

  /// Variante oscura del primario (hover, pressed, degradado final)
  static const Color primaryDark = Color(0xFF8F351F);

  // ── Acento / Secundario ───────────────────────────────────────
  /// Acento cálido — para elementos secundarios de llamada a la acción
  static const Color accent = Color(0xFFE07050);

  /// Acento claro (fondos de etiquetas)
  static const Color accentLight = Color(0xFFF9E5DF);

  // ── Neutrales ────────────────────────────────────────────────
  static const Color grey100 = Color(0xFFF8F9FA);
  static const Color grey200 = Color(0xFFE8EAED);
  static const Color grey300 = Color(0xFFDADCE0);
  static const Color grey400 = Color(0xFFBDC1C6);
  static const Color grey500 = Color(0xFF9AA0A6);
  static const Color grey600 = Color(0xFF80868B);
  static const Color grey700 = Color(0xFF5F6368);
  static const Color grey800 = Color(0xFF3C4043);
  static const Color grey900 = Color(0xFF202124);

  // ── Fondos ───────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // ── Texto ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Estados ──────────────────────────────────────────────────
  static const Color success = Color(0xFF34A853);
  static const Color successLight = Color(0xFFE6F4EA);
  static const Color warning = Color(0xFFFBBC04);
  static const Color warningLight = Color(0xFFFEF7E0);
  static const Color error = Color(0xFFEA4335);
  static const Color errorLight = Color(0xFFFCE8E6);

  /// Info — se mantiene como azul estándar solo para badges de urgencia/estado
  static const Color info = Color(0xFF4285F4);
  static const Color infoLight = Color(0xFFE8F0FE);

  // ── Colores semánticos de estado de servicio ─────────────────
  /// Confirmado — ámbar/dorado
  static const Color estadoConfirmado = Color(0xFFF59E0B);
  static const Color estadoConfirmadoLight = Color(0xFFFEF3C7);

  /// En camino — morado
  static const Color estadoEnCamino = Color(0xFF7C3AED);
  static const Color estadoEnCaminoLight = Color(0xFFEDE9FE);

  /// Ha llegado — azul
  static const Color estadoHaLlegado = Color(0xFF2563EB);
  static const Color estadoHaLlegadoLight = Color(0xFFDBEAFE);

  /// En proceso — naranja fuerte
  static const Color estadoEnProceso = Color(0xFFEA580C);
  static const Color estadoEnProcesoLight = Color(0xFFFFEDD5);

  /// Completado — verde (reutiliza success)
  static const Color estadoCompletado = Color(0xFF34A853);
  static const Color estadoCompletadoLight = Color(0xFFE6F4EA);

  // ── Bordes ───────────────────────────────────────────────────
  static const Color border = Color(0xFFDADCE0);

  /// Borde en foco — mismo tono primario
  static const Color borderFocused = Color(0xFFC14A2C);

  // ── Sombras ──────────────────────────────────────────────────
  static const Color shadowColor = Color(0x1A000000); // 10% negro

  // ── Roles ────────────────────────────────────────────────────
  /// Color representativo del rol Cliente — terracota unificado
  static const Color clientRole = Color(0xFFC14A2C);

  /// Color representativo del rol Trabajador — terracota #C14A2C
  static const Color workerRole = Color(0xFFC14A2C);

  /// Variante clara del color trabajador/cliente (fondos, chips, badges)
  static const Color workerRoleLight = Color(0xFFF9E5DF);

  // ── Gradiente principal ───────────────────────────────────────
  /// Degradado monocromático terracota: base → oscuro
  static const List<Color> primaryGradient = [
    Color(0xFFC14A2C), // #C14A2C
    Color(0xFF8F351F), // #8F351F
  ];
}
