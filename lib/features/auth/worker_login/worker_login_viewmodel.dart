/// worker_login_viewmodel.dart
/// ViewModel del login de trabajador.
///
/// Después de autenticar, consulta el formulario del trabajador y retorna
/// un [WorkerLoginResult] que la view usa para decidir a qué pantalla navegar:
///   - [WorkerLoginResult.goHome]        → /worker/home (aprobado)
///   - [WorkerLoginResult.goApplication] → /worker/apply (sin formulario)
///   - [WorkerLoginResult.goPending]     → /worker/pending (formulario en revisión)
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/formulario_repository.dart';
import '../../../data/models/perfil_model.dart';
import '../../../data/models/formulario_trabajador_model.dart';
import '../../../state/session_controller.dart';

/// Resultado de la acción de login del trabajador.
enum WorkerLoginResult {
  /// El trabajador está aprobado → ir a Home.
  goHome,

  /// El trabajador no tiene formulario enviado → ir al formulario.
  goApplication,

  /// El trabajador tiene formulario en revisión / pendiente → pantalla de espera.
  goPending,
}

class WorkerLoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;
  final FormularioRepository _formularioRepository;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;

  WorkerLoginViewModel({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
    FormularioRepository? formularioRepository,
    required SessionController sessionController,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _formularioRepository = formularioRepository ?? FormularioRepository(),
        _sessionController = sessionController;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Inicia sesión verificando rol=trabajador y evaluando su estado de onboarding.
  ///
  /// Retorna un [WorkerLoginResult] o null si el login falló.
  Future<WorkerLoginResult?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Autenticar en Supabase Auth
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      // 2. Obtener perfil y verificar rol. Si el registro quedó pendiente
      // por confirmación de correo, el perfil se crea en el primer login real.
      final perfil = await _ensurePerfilTrabajador(user, email);
      if (perfil.rol != UserRole.trabajador) {
        await _authRepository.signOut();
        _error = 'Esta cuenta no es de trabajador. Usa el acceso correcto.';
        notifyListeners();
        return null;
      }

      // 3. Refrescar sesión global
      await _sessionController.refreshPerfil();

      // 4. Consultar formulario para evaluar estado
      final formulario = await _formularioRepository
          .getFormularioByCorreo(email)
          .catchError((_) => null);

      if (formulario == null) {
        // Sin formulario → ir a completarlo
        return WorkerLoginResult.goApplication;
      }

      if (formulario.estado == EstadoFormulario.aprobado) {
        return WorkerLoginResult.goHome;
      }

      // pendiente / en_revision / rechazado → pantalla de espera
      return WorkerLoginResult.goPending;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PerfilModel> _ensurePerfilTrabajador(User user, String email) async {
    final existing = await _perfilesRepository.getPerfilById(user.id);
    if (existing != null) return existing;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final metadataRole = metadata['rol']?.toString();
    if (metadataRole != null &&
        UserRole.fromString(metadataRole) != UserRole.trabajador) {
      throw Exception(
          'Esta cuenta no es de trabajador. Usa el acceso correcto.');
    }

    return _perfilesRepository.createPerfil(
      PerfilModel(
        id: user.id,
        nombreCompleto:
            (metadata['nombre_completo'] ?? metadata['nombre'])?.toString() ??
                '',
        correo: user.email ?? email,
        telefono: metadata['telefono']?.toString(),
        rol: UserRole.trabajador,
      ),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
