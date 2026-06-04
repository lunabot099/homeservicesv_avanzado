/// worker_service_tracking_viewmodel.dart
/// ViewModel de la pantalla de trabajo en curso — controla el estado del servicio.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

class WorkerServiceTrackingViewModel extends ChangeNotifier {
  final SolicitudesRepository _solicitudesRepo;

  SolicitudServicioModel? _solicitud;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  StreamSubscription<SolicitudServicioModel?>? _estadoSubscription;

  WorkerServiceTrackingViewModel({
    SolicitudesRepository? solicitudesRepo,
    // sessionController se acepta por compatibilidad con la vista pero no se usa todavía
    required SessionController sessionController,
  })  : _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository();

  SolicitudServicioModel? get solicitud => _solicitud;
  EstadoSolicitud? get estadoActual => _solicitud?.estado;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;

  /// Secuencia completa que el trabajador puede recorrer (incluyendo el arranque).
  static const _secuencia = [
    EstadoSolicitud.confirmada,
    EstadoSolicitud.en_camino,
    EstadoSolicitud.ha_llegado,
    EstadoSolicitud.en_proceso,
    EstadoSolicitud.finalizado_pendiente,
  ];

  /// Estado siguiente disponible para marcar.
  EstadoSolicitud? get siguienteEstado {
    final actual = estadoActual;
    if (actual == null) return null;
    final idx = _secuencia.indexOf(actual);
    // Si no está en la secuencia o ya es el último paso → null
    if (idx < 0 || idx >= _secuencia.length - 1) return null;
    return _secuencia[idx + 1];
  }

  bool get puedeMarcarse => siguienteEstado != null;
  bool get trabajoFinalizado =>
      estadoActual == EstadoSolicitud.finalizado_pendiente ||
      estadoActual == EstadoSolicitud.completada;

  void loadSolicitud(SolicitudServicioModel s) {
    _solicitud = s;
    // Suscribir a cambios en tiempo real
    if (s.id != null) {
      _estadoSubscription?.cancel();
      _estadoSubscription =
          _solicitudesRepo.streamSolicitud(s.id!).listen((updated) {
        if (updated != null) {
          _solicitud = updated;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  /// Avanza al siguiente estado del servicio.
  Future<bool> avanzarEstado() async {
    final next = siguienteEstado;
    if (next == null || _solicitud?.id == null) return false;

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      _solicitud = await _solicitudesRepo.updateEstado(
        id: _solicitud!.id!,
        estado: next,
      );
      return true;
    } catch (e) {
      // Mock offline: actualizar localmente
      _solicitud = _solicitud!.copyWith(estado: next);
      return true;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  String labelParaEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.en_camino:
        return 'Marcar: Estoy en camino';
      case EstadoSolicitud.ha_llegado:
        return 'Marcar: He llegado';
      case EstadoSolicitud.en_proceso:
        return 'Marcar: Trabajo en proceso';
      case EstadoSolicitud.finalizado_pendiente:
        return 'Marcar: Trabajo finalizado';
      default:
        return estado.label;
    }
  }

  @override
  void dispose() {
    _estadoSubscription?.cancel();
    super.dispose();
  }
}
