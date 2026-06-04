/// app_constants.dart
/// Constantes globales de la aplicación HomeServiceSV.
library;

class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────
  static const String appName = 'HomeServiceSV';
  static const String appVersion = '1.0.0';

  // ── Límites ──────────────────────────────────────────────────
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxPhoneLength = 9;
  static const int duiLength = 10; // 00000000-0

  // ── Timeouts ─────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // ── Animaciones ──────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Supabase ─────────────────────────────────────────────────
  /// Nombre de tablas (para evitar magic strings)
  static const String tablePerfiles = 'perfiles';
  static const String tableWorkerProfiles = 'worker_profiles';
  static const String tableFormularioTrabajador = 'formulario_trabajador';

  // ── Storage Buckets ──────────────────────────────────────────
  /// Los nombres reales de buckets se leen desde .env via `Env.bucket*`.
  /// NO definir bucket names aquí — usar exclusivamente Env para evitar
  /// inconsistencias entre el código y los buckets reales de Supabase Storage.
  // Ejemplo: Env.bucketPerfilFotos, Env.bucketDuiDocumentos, etc.
}
