/// client_login_viewmodel.dart
/// ViewModel del login de cliente.
library;

import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/models/perfil_model.dart';
import '../../../state/session_controller.dart';

class ClientLoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;

  ClientLoginViewModel({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
    required SessionController sessionController,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _sessionController = sessionController;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Inicia sesión verificando que el usuario tenga rol de cliente.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      // Verificar que el usuario sea cliente
      final perfil = await _perfilesRepository.getPerfilById(user.id);
      if (perfil != null && perfil.rol != UserRole.cliente) {
        await _authRepository.signOut();
        _error = 'Esta cuenta no es de cliente. Usa el acceso correcto.';
        notifyListeners();
        return false;
      }

      await _sessionController.refreshPerfil();
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
