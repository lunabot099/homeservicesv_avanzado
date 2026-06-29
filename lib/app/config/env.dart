/// env.dart
/// Wrapper para variables de entorno cargadas desde .env con flutter_dotenv.
/// Centraliza el acceso a credenciales y nombres de buckets.
/// NUNCA hardcodear URLs o bucket names fuera de este archivo.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._(); // No instanciar

  // ── Supabase ─────────────────────────────────────────────────

  /// URL del proyecto Supabase (ejemplo: https://xxx.supabase.co)
  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    assert(
      value != null && value.isNotEmpty,
      'SUPABASE_URL no está definida en .env',
    );
    return value!
        .trim()
        .replaceFirst(RegExp(r'/rest/v1/?$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
  }

  /// Clave anónima pública de Supabase
  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    assert(
      value != null && value.isNotEmpty,
      'SUPABASE_ANON_KEY no está definida en .env',
    );
    return value!;
  }

  // ── Storage Buckets ──────────────────────────────────────────
  // Los nombres deben coincidir exactamente con los buckets creados en Supabase.

  /// Bucket para fotos de perfil de usuarios y trabajadores.
  static String get bucketPerfilFotos =>
      dotenv.env['BUCKET_PERFIL_FOTOS'] ?? 'perfil-fotos';

  /// Bucket para documentos DUI de trabajadores.
  static String get bucketDuiDocumentos =>
      dotenv.env['BUCKET_DUI_DOCUMENTOS'] ?? 'dui-documentos';

  /// Bucket para documentos de antecedentes penales.
  static String get bucketAntecedentesDocumentos =>
      dotenv.env['BUCKET_ANTECEDENTES_DOCUMENTOS'] ?? 'antecedentes-documentos';

  /// Bucket para imágenes adjuntas a solicitudes de servicio.
  static String get bucketSolicitudesImagenes =>
      dotenv.env['BUCKET_SOLICITUDES_IMAGENES'] ?? 'solicitudes-imagenes';

  /// Bucket para imágenes enviadas en chats.
  static String get bucketChatImagenes =>
      dotenv.env['BUCKET_CHAT_IMAGENES'] ?? 'chat-imagenes';
}
