/// perfiles_repository.dart
/// Repositorio de perfiles de usuario.
/// Abstracción entre ViewModels y PerfilesService.
library;

import '../models/perfil_model.dart';
import '../services/perfiles_service.dart';

class PerfilesRepository {
  final PerfilesService _service;

  PerfilesRepository({PerfilesService? service})
      : _service = service ?? PerfilesService();

  /// Obtiene el perfil de un usuario por su ID.
  /// Retorna null si no existe.
  Future<PerfilModel?> getPerfilById(String id) async {
    try {
      return await _service.getPerfilById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el perfil: ${e.toString()}');
    }
  }

  /// Crea un nuevo perfil de usuario.
  Future<PerfilModel> createPerfil(PerfilModel perfil) async {
    try {
      return await _service.createPerfil(perfil);
    } catch (e) {
      throw Exception('No se pudo crear el perfil: ${e.toString()}');
    }
  }

  /// Actualiza campos específicos de un perfil.
  Future<PerfilModel> updatePerfil({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    try {
      return await _service.updatePerfil(id: id, fields: fields);
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: ${e.toString()}');
    }
  }
}
