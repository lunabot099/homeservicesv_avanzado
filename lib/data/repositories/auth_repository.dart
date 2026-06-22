/// auth_repository.dart
/// Repositorio de autenticación.
/// Actúa como capa de abstracción entre ViewModels y AuthService.
/// Los ViewModels SOLO interactúan con repositories, nunca con services directamente.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Intenta iniciar sesión con email y contraseña.
  /// Retorna el [User] en caso de éxito.
  /// Lanza [Exception] con mensaje descriptivo en caso de error.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo iniciar sesión. Verifica tus credenciales.');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Registra un nuevo usuario.
  /// Retorna el [User] creado.
  Future<User> signUp({
    required String email,
    required String password,
    String? nombreCompleto,
    String? telefono,
    String? rol,
  }) async {
    try {
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        rol: rol,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta. Intenta de nuevo.');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Retorna el usuario autenticado actualmente, o null.
  User? get currentUser => _authService.currentUser;

  /// Retorna la sesión autenticada actual, o null si falta confirmar correo.
  Session? get currentSession => _authService.currentSession;

  /// Stream de cambios de estado de autenticación.
  Stream<AuthState> get authStateChanges => _authService.onAuthStateChange;

  /// Envía email para restablecer contraseña.
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Traduce mensajes de error de Supabase a mensajes amigables en español.
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de ingresar.';
    }
    if (message.contains('User already registered')) {
      return 'Ya existe una cuenta con este correo.';
    }
    if (message.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'Ocurrió un error. Intenta nuevamente.';
  }
}
