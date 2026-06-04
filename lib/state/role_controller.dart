/// role_controller.dart
/// Controlador global de rol del usuario.
/// Expone el rol actual y permite cambios de rol (ej. en el selector de rol).
/// Se usa junto con SessionController para determinar rutas de navegación.
library;

import 'package:flutter/foundation.dart';
import '../data/models/perfil_model.dart';

class RoleController extends ChangeNotifier {
  UserRole? _selectedRole;

  /// Rol seleccionado actualmente por el usuario.
  UserRole? get selectedRole => _selectedRole;

  /// Indica si el usuario seleccionó el rol de cliente.
  bool get isClient => _selectedRole == UserRole.cliente;

  /// Indica si el usuario seleccionó el rol de trabajador.
  bool get isWorker => _selectedRole == UserRole.trabajador;

  /// Selecciona el rol de cliente.
  void selectClientRole() {
    _selectedRole = UserRole.cliente;
    notifyListeners();
  }

  /// Selecciona el rol de trabajador.
  void selectWorkerRole() {
    _selectedRole = UserRole.trabajador;
    notifyListeners();
  }

  /// Actualiza el rol según el perfil cargado desde la base de datos.
  void setRoleFromPerfil(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Limpia la selección de rol (ej. al cerrar sesión).
  void clearRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
