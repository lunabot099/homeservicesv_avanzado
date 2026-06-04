/// formatters.dart
/// Formateadores de texto y datos para la UI.
library;

class Formatters {
  Formatters._();

  /// Formatea un número de teléfono como xxxx-xxxx.
  static String telefono(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length >= 8) {
      return '${digits.substring(0, 4)}-${digits.substring(4, 8)}';
    }
    return raw;
  }

  /// Formatea DUI como 00000000-0.
  static String dui(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length >= 9) {
      return '${digits.substring(0, 8)}-${digits.substring(8, 9)}';
    }
    return raw;
  }

  /// Capitaliza la primera letra de cada palabra.
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Formatea una calificación de 1 a 5 con un decimal.
  static String calificacion(double? valor) {
    if (valor == null) return 'Sin calificación';
    return valor.toStringAsFixed(1);
  }

  /// Formatea una fecha a formato legible en español.
  static String fecha(DateTime? fecha) {
    if (fecha == null) return 'Desconocido';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  /// Formatea tarifa como precio en dólares.
  static String tarifa(double? valor) {
    if (valor == null) return 'A convenir';
    return '\$${valor.toStringAsFixed(2)}/hora';
  }
}
