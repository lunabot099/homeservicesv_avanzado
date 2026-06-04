/// perfiles_service.dart
/// Servicio de acceso a datos de la tabla `perfiles` en Supabase.
/// CRUD básico — NO contiene lógica de negocio.
/// NO debe ser llamado directamente desde widgets — usar PerfilesRepository.
library;

import '../models/perfil_model.dart';
import 'supabase_client_service.dart';

class PerfilesService {
  static const String _table = 'perfiles';

  final _client = SupabaseClientService.client;

  /// Obtiene el perfil de un usuario por su ID.
  Future<PerfilModel?> getPerfilById(String id) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return PerfilModel.fromMap(data);
  }

  /// Crea un nuevo perfil en la base de datos.
  Future<PerfilModel> createPerfil(PerfilModel perfil) async {
    final data = await _client
        .from(_table)
        .insert(perfil.toMap())
        .select()
        .single();

    return PerfilModel.fromMap(data);
  }

  /// Actualiza un perfil existente.
  Future<PerfilModel> updatePerfil({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _client
        .from(_table)
        .update(fields)
        .eq('id', id)
        .select()
        .single();

    return PerfilModel.fromMap(data);
  }

  /// Elimina un perfil por ID (soft delete recomendado en producción).
  Future<void> deletePerfil(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
