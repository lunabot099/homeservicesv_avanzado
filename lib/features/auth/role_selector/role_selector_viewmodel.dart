/// role_selector_viewmodel.dart
/// ViewModel de la pantalla de selección de rol.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/perfil_model.dart';
import '../../../state/role_controller.dart';

class RoleSelectorViewModel extends ChangeNotifier {
  final RoleController _roleController;

  RoleSelectorViewModel({required RoleController roleController})
      : _roleController = roleController;

  /// Selecciona el rol de cliente y notifica al RoleController.
  void selectCliente() {
    _roleController.selectClientRole();
  }

  /// Selecciona el rol de trabajador y notifica al RoleController.
  void selectTrabajador() {
    _roleController.selectWorkerRole();
  }

  UserRole? get selectedRole => _roleController.selectedRole;
}
