/// validators.dart
/// Validadores de formularios reutilizables.
/// Retornan null si el valor es válido, o un mensaje de error en español.
library;

import '../constants/app_constants.dart';

class Validators {
  Validators._();

  /// Valida que el campo no esté vacío.
  static String? required(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return '${label ?? 'Este campo'} es requerido.';
    }
    return null;
  }

  /// Valida formato de correo electrónico.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es requerido.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  /// Valida que la contraseña tenga al menos 6 caracteres.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida.';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres.';
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan.
  static String? confirmPassword(String? value, String? original) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    if (value != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Valida formato de número de teléfono salvadoreño (7xxx-xxxx o 2xxx-xxxx).
  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es requerido.';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length != 8) {
      return 'El teléfono debe tener 8 dígitos.';
    }
    if (!RegExp(r'^\d{8}$').hasMatch(cleaned)) {
      return 'Ingresa un teléfono válido.';
    }
    return null;
  }

  /// Valida formato de DUI salvadoreño (00000000-0).
  static String? dui(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El DUI es requerido.';
    }
    final duiRegex = RegExp(r'^\d{8}-\d$');
    if (!duiRegex.hasMatch(value.trim())) {
      return 'Formato inválido. Usa: 00000000-0';
    }
    return null;
  }

  /// Valida nombre completo.
  static String? nombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido.';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres.';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return 'El nombre es demasiado largo.';
    }
    return null;
  }
}
