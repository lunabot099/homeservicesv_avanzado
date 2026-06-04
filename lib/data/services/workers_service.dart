/// workers_service.dart
/// Servicio de acceso a datos de la tabla `worker_profiles` en Supabase.
/// CRUD básico — NO contiene lógica de negocio.
/// NO debe ser llamado directamente desde widgets — usar WorkersRepository.
library;

import '../models/worker_profile_model.dart';
import 'supabase_client_service.dart';

class WorkersService {
  static const String _table = 'worker_profiles';

  final _client = SupabaseClientService.client;

  /// Obtiene el perfil de trabajador por su ID.
  Future<WorkerProfileModel?> getWorkerById(String id) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return WorkerProfileModel.fromMap(data);
  }

  /// Crea un perfil de trabajador.
  Future<WorkerProfileModel> createWorkerProfile(WorkerProfileModel profile) async {
    final data = await _client
        .from(_table)
        .insert(profile.toMap())
        .select()
        .single();

    return WorkerProfileModel.fromMap(data);
  }

  /// Actualiza el perfil de un trabajador.
  Future<WorkerProfileModel> updateWorkerProfile({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _client
        .from(_table)
        .update(fields)
        .eq('id', id)
        .select()
        .single();

    return WorkerProfileModel.fromMap(data);
  }

  /// Obtiene la lista de trabajadores disponibles y verificados.
  Future<List<WorkerProfileModel>> getWorkersDisponibles() async {
    final data = await _client
        .from(_table)
        .select()
        .eq('disponibilidad', true)
        .eq('verificado', true);

    return (data as List)
        .map((e) => WorkerProfileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
