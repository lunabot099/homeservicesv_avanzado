/// postulaciones_service.dart
/// Servicio para operaciones CRUD de postulaciones a solicitudes.
///
/// Tabla Supabase: `postulaciones_solicitud`
/// Columnas: id, solicitud_id, trabajador_id, precio_ofertado,
///           tiempo_estimado_llegada, estado, fecha_creacion
///           ('mensaje' no existe en la tabla — omitido del payload)
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/postulacion_solicitud_model.dart';

class PostulacionesService {
  final SupabaseClient _client;
  static const _table = 'postulaciones_solicitud';

  PostulacionesService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Crea una nueva postulación de un trabajador a una solicitud.
  Future<PostulacionSolicitudModel> create(PostulacionSolicitudModel p) async {
    final data = await _client
        .from(_table)
        .insert(p.toMap())
        .select()
        .single();
    return PostulacionSolicitudModel.fromMap(data);
  }

  /// Lista todas las postulaciones de una solicitud específica.
  Future<List<PostulacionSolicitudModel>> getBySolicitud(
      String solicitudId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('solicitud_id', solicitudId)
        .order('fecha_creacion');
    return (data as List)
        .map((e) => PostulacionSolicitudModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Lista las postulaciones activas de un trabajador.
  Future<List<PostulacionSolicitudModel>> getByTrabajador(
      String trabajadorId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('trabajador_id', trabajadorId)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => PostulacionSolicitudModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Cambia el estado de una postulación (acepta, rechaza, etc.).
  Future<void> updateEstado(String postulacionId, EstadoPostulacion estado) async {
    await _client
        .from(_table)
        .update({'estado': estado.name})
        .eq('id', postulacionId);
  }

  /// Comprueba si un trabajador ya se postuló a una solicitud.
  Future<bool> yaPostulado(
      {required String solicitudId, required String trabajadorId}) async {
    final data = await _client
        .from(_table)
        .select('id')
        .eq('solicitud_id', solicitudId)
        .eq('trabajador_id', trabajadorId)
        .maybeSingle();
    return data != null;
  }

  /// [Realtime] Stream de cambios en las postulaciones de una solicitud.
  /// Útil para el cliente que espera nuevos interesados.
  Stream<List<PostulacionSolicitudModel>> streamBySolicitud(
      String solicitudId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('solicitud_id', solicitudId)
        .map((rows) => rows
            .map((e) => PostulacionSolicitudModel.fromMap(e))
            .toList());
  }

  /// [Realtime] Stream de cambios en las postulaciones de un trabajador.
  /// Útil para que el trabajador sepa si fue seleccionado.
  Stream<List<PostulacionSolicitudModel>> streamByTrabajador(
      String trabajadorId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('trabajador_id', trabajadorId)
        .map((rows) => rows
            .map((e) => PostulacionSolicitudModel.fromMap(e))
            .toList());
  }

  /// Rechaza todas las postulaciones de una solicitud excepto la seleccionada.
  /// Debe llamarse justo después de marcar la postulación elegida como `aceptada`.
  Future<void> rechazarOtrasPostulaciones({
    required String solicitudId,
    required String postulacionAceptadaId,
  }) async {
    await _client
        .from(_table)
        .update({'estado': EstadoPostulacion.rechazada.name})
        .eq('solicitud_id', solicitudId)
        .neq('id', postulacionAceptadaId)
        .eq('estado', EstadoPostulacion.pendiente.name);
  }
}
