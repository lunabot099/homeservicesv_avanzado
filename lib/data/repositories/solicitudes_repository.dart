/// solicitudes_repository.dart
/// Repositorio de solicitudes — extendido en Fase 3 con métodos del trabajador.
library;

import '../models/solicitud_servicio_model.dart';
import '../services/solicitudes_service.dart';
import '../services/storage_service.dart';

class SolicitudesRepository {
  final SolicitudesService _service;
  final StorageService _storageService;

  SolicitudesRepository({
    SolicitudesService? service,
    StorageService? storageService,
  })  : _service = service ?? SolicitudesService(),
        _storageService = storageService ?? StorageService();

  // ── Cliente ───────────────────────────────────────────────────

  Future<SolicitudServicioModel> createSolicitud(
      SolicitudServicioModel s) async {
    try {
      var creada = await _service.createSolicitud(s.copyWith(
        imagenesUrls: const [],
        imagenesPendientesBytes: const [],
      ));

      if (s.imagenesPendientesBytes.isEmpty || creada.id == null) {
        return creada;
      }

      final urls = <String>[];
      for (var i = 0; i < s.imagenesPendientesBytes.length; i++) {
        final url = await _storageService.uploadSolicitudImagenBytes(
          solicitudId: creada.id!,
          index: i,
          bytes: s.imagenesPendientesBytes[i],
        );
        urls.add(url);
      }

      creada = await _service.updateImagenesUrls(
        id: creada.id!,
        imagenesUrls: urls,
      );
      return creada;
    } catch (e) {
      throw Exception('No se pudo crear la solicitud: $e');
    }
  }

  Future<List<SolicitudServicioModel>> getSolicitudesByCliente(
      String clienteId) async {
    try {
      return await _service.getSolicitudesByCliente(clienteId);
    } catch (e) {
      throw Exception('No se pudieron obtener las solicitudes: $e');
    }
  }

  Future<SolicitudServicioModel?> getSolicitudById(String id) async {
    try {
      return await _service.getSolicitudById(id);
    } catch (e) {
      throw Exception('No se pudo obtener la solicitud: $e');
    }
  }

  Future<void> cancelarSolicitud(String id) async {
    try {
      await _service.cancelarSolicitud(id);
    } catch (e) {
      throw Exception('No se pudo cancelar la solicitud: $e');
    }
  }

  // ── Trabajador ────────────────────────────────────────────────

  /// Solicitudes disponibles para postularse.
  Future<List<SolicitudServicioModel>> getSolicitudesDisponibles({
    String? departamento,
    String? categoriaId,
  }) async {
    try {
      return await _service.getSolicitudesDisponibles(
          departamento: departamento, categoriaId: categoriaId);
    } catch (e) {
      throw Exception('No se pudieron obtener solicitudes disponibles: $e');
    }
  }

  /// Solicitudes activas donde el trabajador fue seleccionado.
  Future<List<SolicitudServicioModel>> getSolicitudesActivasTrabajador(
      String trabajadorId) async {
    try {
      return await _service.getSolicitudesActivasTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('No se pudieron obtener solicitudes activas: $e');
    }
  }

  /// Historial completo del trabajador.
  Future<List<SolicitudServicioModel>> getHistorialTrabajador(
      String trabajadorId) async {
    try {
      return await _service.getHistorialTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('No se pudo obtener historial: $e');
    }
  }

  // ── Estado del servicio ───────────────────────────────────────

  /// Actualiza el estado del servicio (cliente o trabajador).
  Future<SolicitudServicioModel> updateEstado({
    required String id,
    required EstadoSolicitud estado,
    String? trabajadorId,
  }) async {
    try {
      return await _service.updateEstado(
        id: id,
        estado: estado,
        trabajadorId: trabajadorId,
      );
    } catch (e) {
      throw Exception('No se pudo actualizar el estado: $e');
    }
  }

  // ── Realtime ──────────────────────────────────────────────────

  Stream<SolicitudServicioModel?> streamSolicitud(String solicitudId) =>
      _service.streamSolicitud(solicitudId);

  Stream<List<SolicitudServicioModel>> streamSolicitudesDisponibles({
    String? departamento,
  }) =>
      _service.streamSolicitudesDisponibles(departamento: departamento);

  // ── Expiración automática ─────────────────────────────────────────────────

  /// Expira solicitudes sin aceptar con más de 1 hora de antigüedad.
  Future<void> expirarSolicitudesAntiguas() async {
    try {
      await _service.expirarSolicitudesAntiguas();
    } catch (_) {}
  }

  /// Elimina solicitudes expiradas con más de 90 minutos de antigüedad.
  Future<void> limpiarExpiradas() async {
    try {
      await _service.limpiarExpiradas();
    } catch (_) {}
  }
}
