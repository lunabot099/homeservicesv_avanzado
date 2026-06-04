/// solicitudes_service.dart
/// Servicio de acceso a datos de `solicitudes_servicio` en Supabase.
/// Extendido en Fase 3 con métodos del trabajador y Realtime.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/solicitud_servicio_model.dart';

class SolicitudesService {
  final SupabaseClient _client;
  static const _table = 'solicitudes_servicio';

  SolicitudesService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── Operaciones del cliente ──────────────────────────────────

  /// Crea una nueva solicitud de servicio.
  Future<SolicitudServicioModel> createSolicitud(SolicitudServicioModel s) async {
    final data = await _client
        .from(_table)
        .insert(s.toMap())
        .select()
        .single();
    return SolicitudServicioModel.fromMap(data);
  }

  /// Obtiene las solicitudes de un cliente ordenadas por fecha desc.
  Future<List<SolicitudServicioModel>> getSolicitudesByCliente(
      String clienteId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => SolicitudServicioModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene una solicitud por su ID.
  Future<SolicitudServicioModel?> getSolicitudById(String id) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return SolicitudServicioModel.fromMap(data);
  }

  // ── Operaciones del trabajador ────────────────────────────────

  /// Lista las solicitudes disponibles para un trabajador.
  /// Estado `buscando` o `postulaciones_recibidas`, excluyendo las que ya canceló.
  Future<List<SolicitudServicioModel>> getSolicitudesDisponibles({
    String? departamento,
    String? categoriaId,
  }) async {
    var query = _client
        .from(_table)
        .select()
        .inFilter('estado', [
          EstadoSolicitud.en_busqueda.name,
          EstadoSolicitud.postulaciones_recibidas.name,
        ]);

    if (departamento != null) {
      query = query.eq('departamento', departamento);
    }
    if (categoriaId != null) {
      query = query.eq('categoria', categoriaId);
    }

    final data = await query.order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => SolicitudServicioModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Solicitudes activas donde el trabajador fue seleccionado.
  Future<List<SolicitudServicioModel>> getSolicitudesActivasTrabajador(
      String trabajadorId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('trabajador_seleccionado_id', trabajadorId)
        .not('estado', 'in', '(${EstadoSolicitud.cancelada.name},${EstadoSolicitud.completada.name},${EstadoSolicitud.expirada.name})')
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => SolicitudServicioModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Historial completo del trabajador.
  Future<List<SolicitudServicioModel>> getHistorialTrabajador(
      String trabajadorId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('trabajador_seleccionado_id', trabajadorId)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => SolicitudServicioModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Estado del servicio ───────────────────────────────────────

  /// Actualiza el estado de una solicitud.
  Future<SolicitudServicioModel> updateEstado({
    required String id,
    required EstadoSolicitud estado,
    String? trabajadorId,
  }) async {
    final updates = <String, dynamic>{'estado': estado.name};
    if (trabajadorId != null) updates['trabajador_seleccionado_id'] = trabajadorId;

    final data = await _client
        .from(_table)
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return SolicitudServicioModel.fromMap(data);
  }

  /// Cancela una solicitud.
  Future<void> cancelarSolicitud(String id) async {
    await _client
        .from(_table)
        .update({'estado': EstadoSolicitud.cancelada.name})
        .eq('id', id);
  }

  // ── Realtime ──────────────────────────────────────────────────

  /// [Realtime] Stream de cambios de estado de una solicitud específica.
  /// Útil para el cliente viendo el tracking y el trabajador esperando confirmación.
  Stream<SolicitudServicioModel?> streamSolicitud(String solicitudId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', solicitudId)
        .map((rows) => rows.isNotEmpty
            ? SolicitudServicioModel.fromMap(rows.first)
            : null);
  }

  /// [Realtime] Stream de solicitudes disponibles (para la home del trabajador).
  Stream<List<SolicitudServicioModel>> streamSolicitudesDisponibles({
    String? departamento,
  }) {
    var stream = _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('estado', EstadoSolicitud.en_busqueda.name);

    return stream.map((rows) => rows
        .map((e) => SolicitudServicioModel.fromMap(e))
        .where((s) => departamento == null || s.departamento == departamento)
        .toList());
  }

  // ── Expiración automática ─────────────────────────────────────

  /// Marca como `expirada` todas las solicitudes en búsqueda creadas
  /// hace más de 1 hora (3600 segundos) que aún no tienen trabajador.
  Future<void> expirarSolicitudesAntiguas() async {
    final limite = DateTime.now().toUtc().subtract(const Duration(hours: 1)).toIso8601String();
    await _client
        .from(_table)
        .update({'estado': EstadoSolicitud.expirada.name})
        .inFilter('estado', [
          EstadoSolicitud.en_busqueda.name,
          EstadoSolicitud.postulaciones_recibidas.name,
        ])
        .lt('fecha_creacion', limite)
        .isFilter('trabajador_seleccionado_id', null);
  }

  /// Elimina solicitudes con estado `expirada` creadas hace más de 90 minutos.
  Future<void> limpiarExpiradas() async {
    final limite = DateTime.now().toUtc().subtract(const Duration(minutes: 90)).toIso8601String();
    await _client
        .from(_table)
        .delete()
        .eq('estado', EstadoSolicitud.expirada.name)
        .lt('fecha_creacion', limite);
  }
}
