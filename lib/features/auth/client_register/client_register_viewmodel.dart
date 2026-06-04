/// client_register_viewmodel.dart
/// ViewModel del registro de cliente.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/models/perfil_model.dart';
import '../../../state/session_controller.dart';

class ClientRegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;
  bool _registroExitoso = false;

  ClientRegisterViewModel({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
    required SessionController sessionController,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _sessionController = sessionController;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get registroExitoso => _registroExitoso;

  /// Registra un nuevo cliente.
  /// 1. Crea usuario en Supabase Auth
  /// 2. Crea perfil en tabla `perfiles` con rol=cliente
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
      // 1. Crear usuario en Auth
      final user = await _authRepository.signUp(
        email: correo,
        password: password,
        nombreCompleto: nombreCompleto,
      );

      // 2. Crear perfil en la tabla `perfiles`
      await _perfilesRepository.createPerfil(
        PerfilModel(
          id: user.id,
          nombreCompleto: nombreCompleto,
          correo: correo,
          telefono: telefono,
          rol: UserRole.cliente,
        ),
      );

      await _sessionController.refreshPerfil();
      _registroExitoso = true;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
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
