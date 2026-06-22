/// auth_service.dart
/// Servicio de autenticación con Supabase Auth.
/// Encapsula signIn, signUp, signOut y observación de estado de sesión.
/// NO debe ser llamado directamente desde widgets — usar AuthRepository.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_service.dart';

class AuthService {
  final _auth = SupabaseClientService.client.auth;

  /// Inicia sesión con email y contraseña.
  /// Lanza [AuthException] si las credenciales son incorrectas.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registra un nuevo usuario con email y contraseña.
  /// Incluye metadatos opcionales (nombre completo).
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? nombreCompleto,
    String? telefono,
    String? rol,
  }) async {
    return await _auth.signUp(
      email: email,
      password: password,
      data: {
        if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
        if (telefono != null) 'telefono': telefono,
        if (rol != null) 'rol': rol,
      },
    );
  }

  /// Cierra la sesión actual del usuario.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Retorna el usuario actualmente autenticado, o null si no hay sesión.
  User? get currentUser => _auth.currentUser;

  /// Retorna la sesión activa actual, o null.
  Session? get currentSession => _auth.currentSession;

  /// Stream que emite eventos de cambio de estado de autenticación.
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Envía un email de reset de contraseña al correo dado.
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }
}
