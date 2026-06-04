/// workers_repository.dart
/// Repositorio de perfiles de trabajadores.
/// Abstracción entre ViewModels y WorkersService.
library;

import '../models/worker_profile_model.dart';
import '../services/workers_service.dart';

class WorkersRepository {
  final WorkersService _service;

  WorkersRepository({WorkersService? service})
      : _service = service ?? WorkersService();

  /// Obtiene el perfil de trabajador por ID.
  Future<WorkerProfileModel?> getWorkerById(String id) async {
    try {
      return await _service.getWorkerById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el perfil del trabajador: ${e.toString()}');
    }
  }

  /// Crea un perfil de trabajador.
  Future<WorkerProfileModel> createWorkerProfile(WorkerProfileModel profile) async {
    try {
      return await _service.createWorkerProfile(profile);
    } catch (e) {
      throw Exception('No se pudo crear el perfil del trabajador: ${e.toString()}');
    }
  }

  /// Obtiene todos los trabajadores verificados y disponibles.
  Future<List<WorkerProfileModel>> getWorkersDisponibles() async {
    try {
      return await _service.getWorkersDisponibles();
    } catch (e) {
      throw Exception('No se pudieron obtener los trabajadores: ${e.toString()}');
    }
  }

  /// Actualiza el perfil de un trabajador.
  Future<WorkerProfileModel> updateWorkerProfile({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    try {
      return await _service.updateWorkerProfile(id: id, fields: fields);
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: ${e.toString()}');
    }
  }
}
