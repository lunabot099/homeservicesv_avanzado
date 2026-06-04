/// supabase_client_service.dart
/// Singleton de acceso al cliente Supabase ya inicializado.
/// Todos los services deben obtener el cliente desde aquí.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  SupabaseClientService._();

  /// Retorna el cliente de Supabase ya inicializado.
  static SupabaseClient get client => Supabase.instance.client;

  /// Retorna la sesión actual del usuario autenticado, o null.
  static Session? get currentSession => client.auth.currentSession;

  /// Retorna el usuario autenticado actual, o null.
  static User? get currentUser => client.auth.currentUser;

  /// Stream de cambios de estado de autenticación.
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
