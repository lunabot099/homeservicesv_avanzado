/// worker_applications_viewmodel.dart
/// ViewModel de la pantalla de mis postulaciones (solicitudes donde me postulé).
/// Usa suscripción Realtime para reflejar automáticamente cuando el cliente
/// acepta o rechaza una postulación del trabajador.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/postulaciones_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

/// Par postulación + solicitud para mostrar en la lista.
class ApplicationItem {
  final PostulacionSolicitudModel postulacion;
  final SolicitudServicioModel? solicitud;

  const ApplicationItem({required this.postulacion, this.solicitud});

  bool get estaEnProceso {
    if (postulacion.estado != EstadoPostulacion.aceptada) return false;

    switch (solicitud?.estado) {
      case EstadoSolicitud.confirmada:
      case EstadoSolicitud.en_camino:
      case EstadoSolicitud.ha_llegado:
      case EstadoSolicitud.en_proceso:
      case EstadoSolicitud.finalizado_pendiente:
        return true;
      default:
        return false;
    }
  }

  bool get estaFinalizada => solicitud?.estado == EstadoSolicitud.completada;
}

enum WorkerApplicationsFilter {
  enProceso,
  pendiente,
  rechazada,
  finalizada,
  todas,
}

class WorkerApplicationsViewModel extends ChangeNotifier {
  final PostulacionesRepository _postulacionesRepo;
  final SolicitudesRepository _solicitudesRepo;
  final SessionController _sessionController;

  List<ApplicationItem> _items = [];
  WorkerApplicationsFilter _filtro = WorkerApplicationsFilter.enProceso;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PostulacionSolicitudModel>>? _streamSub;

  WorkerApplicationsViewModel({
    PostulacionesRepository? postulacionesRepo,
    SolicitudesRepository? solicitudesRepo,
    required SessionController sessionController,
  })  : _postulacionesRepo = postulacionesRepo ?? PostulacionesRepository(),
        _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _sessionController = sessionController;

  List<ApplicationItem> get items {
    switch (_filtro) {
      case WorkerApplicationsFilter.enProceso:
        return _items.where((i) => i.estaEnProceso).toList();
      case WorkerApplicationsFilter.pendiente:
        return _items
            .where((i) => i.postulacion.estado == EstadoPostulacion.pendiente)
            .toList();
      case WorkerApplicationsFilter.rechazada:
        return _items
            .where((i) =>
                i.postulacion.estado == EstadoPostulacion.rechazada ||
                i.postulacion.estado == EstadoPostulacion.cancelada)
            .toList();
      case WorkerApplicationsFilter.finalizada:
        return _items.where((i) => i.estaFinalizada).toList();
      case WorkerApplicationsFilter.todas:
        return _items;
    }
  }

  WorkerApplicationsFilter get filtro => _filtro;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setFiltro(WorkerApplicationsFilter filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  Future<void> loadPostulaciones() async {
    final trabajadorId = _sessionController.currentUser?.id;
    if (trabajadorId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Carga inicial puntual
      final postulaciones =
          await _postulacionesRepo.getMisPostulaciones(trabajadorId);
      _items = await _buildItems(postulaciones);
    } catch (e) {
      debugPrint('[WorkerApplicationsVM] Error carga inicial: $e');
      _items = [];
      _error = 'No se pudieron cargar las postulaciones.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Suscribir a Realtime para actualizaciones automáticas
    _suscribirRealtime(trabajadorId);
  }

  /// Suscribe al stream Realtime para que cuando el cliente acepte/rechace,
  /// la pantalla del trabajador se actualice automáticamente.
  void _suscribirRealtime(String trabajadorId) {
    _streamSub?.cancel();
    _streamSub = _postulacionesRepo.streamMisPostulaciones(trabajadorId).listen(
      (postulaciones) async {
        _items = await _buildItems(postulaciones);
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[WorkerApplicationsVM] Error Realtime: $e');
      },
    );
  }

  /// Convierte postulaciones a items enriquecidos con su solicitud.
  /// Ordena: en proceso → pendiente → finalizadas → rechazadas/canceladas.
  Future<List<ApplicationItem>> _buildItems(
      List<PostulacionSolicitudModel> postulaciones) async {
    final futures = postulaciones.map((p) async {
      try {
        final solicitud =
            await _solicitudesRepo.getSolicitudById(p.solicitudId);
        return ApplicationItem(postulacion: p, solicitud: solicitud);
      } catch (_) {
        return ApplicationItem(postulacion: p, solicitud: null);
      }
    });
    final items = await Future.wait(futures);

    items.sort((a, b) {
      int priority(ApplicationItem item) {
        if (item.estaEnProceso) return 0;
        if (item.postulacion.estado == EstadoPostulacion.pendiente) return 1;
        if (item.estaFinalizada) return 2;
        return 3;
      }

      final byPriority = priority(a).compareTo(priority(b));
      if (byPriority != 0) return byPriority;

      final aDate = a.solicitud?.fechaActualizacion ??
          a.solicitud?.fechaCreacion ??
          a.postulacion.fechaCreacion;
      final bDate = b.solicitud?.fechaActualizacion ??
          b.solicitud?.fechaCreacion ??
          b.postulacion.fechaCreacion;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return items;
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
