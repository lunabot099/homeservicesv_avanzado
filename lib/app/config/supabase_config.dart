/// supabase_config.dart
/// Inicialización y acceso centralizado al cliente Supabase.
/// Debe llamarse una sola vez en main.dart antes de runApp.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  SupabaseConfig._(); // No instanciar

  /// Inicializa Supabase con las credenciales del archivo .env.
  /// Debe llamarse dentro de main() antes de runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  /// Acceso directo al cliente de Supabase ya inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
