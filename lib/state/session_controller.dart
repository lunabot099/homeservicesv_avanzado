/// session_controller.dart
/// Controlador global de sesión de usuario.
/// Es un ChangeNotifier que escucha cambios de autenticación en Supabase
/// y expone el estado de sesión a toda la app mediante Provider.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/perfil_model.dart';
import '../data/models/formulario_trabajador_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/formulario_repository.dart';
import '../data/repositories/perfiles_repository.dart';

class SessionController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;
  final FormularioRepository _formularioRepository;

  User? _currentUser;
  PerfilModel? _currentPerfil;
  FormularioTrabajadorModel? _currentWorkerApplication;
  bool _isLoading = false;
  String? _error;

  SessionController({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
    FormularioRepository? formularioRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _formularioRepository = formularioRepository ?? FormularioRepository() {
    // Escuchar cambios de autenticación automáticamente
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
    // Cargar sesión inicial si ya hay usuario
    _initSession();
  }

  // ── Getters ─────────────────────────────────────────────────
  User? get currentUser => _currentUser;
  PerfilModel? get currentPerfil => _currentPerfil;
  FormularioTrabajadorModel? get currentWorkerApplication =>
      _currentWorkerApplication;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentPerfil?.rol;
  bool get isWorker => currentRole == UserRole.trabajador;
  bool get hasApprovedWorkerAccess =>
      isWorker &&
      _currentWorkerApplication?.estado == EstadoFormulario.aprobado &&
      (_currentWorkerApplication?.hasRequiredDocuments ?? false);

  // ── Inicialización ───────────────────────────────────────────
  Future<void> _initSession() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      _currentUser = user;
      await _loadPerfil(user.id);
    }
  }

  // ── Listener de auth ─────────────────────────────────────────
  Future<void> _onAuthStateChanged(AuthState state) async {
    final event = state.event;
    final user = state.session?.user;

    if (event == AuthChangeEvent.signedIn && user != null) {
      _currentUser = user;
      await _loadPerfil(user.id);
    } else if (event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      _currentPerfil = null;
      _currentWorkerApplication = null;
    }
    notifyListeners();
  }

  // ── Carga de perfil ──────────────────────────────────────────
  Future<void> _loadPerfil(String userId) async {
    try {
      _currentPerfil = await _perfilesRepository.getPerfilById(userId);
      await _loadWorkerApplicationIfNeeded();
    } catch (_) {
      // El perfil puede no existir todavía (usuario recién registrado)
      _currentPerfil = null;
      _currentWorkerApplication = null;
    }
    notifyListeners();
  }

  Future<void> _loadWorkerApplicationIfNeeded() async {
    final perfil = _currentPerfil;
    if (perfil == null || perfil.rol != UserRole.trabajador) {
      _currentWorkerApplication = null;
      return;
    }

    try {
      _currentWorkerApplication = await _formularioRepository
          .getFormularioByCorreo(perfil.correo)
          .catchError((_) => null);
    } catch (_) {
      _currentWorkerApplication = null;
    }
  }

  // ── Acciones públicas ────────────────────────────────────────

  /// Fuerza la recarga del perfil del usuario actual.
  Future<void> refreshPerfil() async {
    if (_currentUser == null) return;
    await _loadPerfil(_currentUser!.id);
  }

  /// Cierra la sesión del usuario.
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _currentPerfil = null;
      _currentWorkerApplication = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el error actual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
