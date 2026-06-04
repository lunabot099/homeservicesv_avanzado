/// worker_register_viewmodel.dart
/// ViewModel del registro de trabajador.
///
/// Flujo:
///   1. signUp en Supabase Auth → obtiene auth.users.id
///   2. createPerfil con id=auth.users.id y rol=trabajador
///   3. refreshPerfil en SessionController
///
/// No se duplica usuario: auth.users tiene 1 entrada, perfiles tiene 1 entrada.
library;

import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/models/perfil_model.dart';
import '../../../state/session_controller.dart';

class WorkerRegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;
  bool _registroExitoso = false;

  WorkerRegisterViewModel({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
    required SessionController sessionController,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _sessionController = sessionController;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get registroExitoso => _registroExitoso;

  /// Registra un nuevo trabajador.
  ///
  /// 1. Crea usuario en Supabase Auth (auth.users).
  /// 2. Crea perfil en tabla `perfiles` con rol=trabajador y id=auth.users.id.
  /// 3. Refresca la sesión para que el SessionController tenga el perfil actualizado.
  ///
  /// Retorna `true` si el registro fue exitoso.
  Future<bool> register({
    required String nombreCompleto,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    _isLoading = true;
    _error = null;
    _registroExitoso = false;
    notifyListeners();

    try {
      // 1. Crear cuenta en Auth — genera auth.users.id único
      final user = await _authRepository.signUp(
        email: correo,
        password: password,
        nombreCompleto: nombreCompleto,
      );

      // 2. Crear perfil con el mismo UUID — rol=trabajador
      await _perfilesRepository.createPerfil(
        PerfilModel(
          id: user.id,
          nombreCompleto: nombreCompleto,
          correo: correo,
          telefono: telefono,
          rol: UserRole.trabajador,
        ),
      );

      // 3. Refrescar sesión global
      await _sessionController.refreshPerfil();

      _registroExitoso = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
