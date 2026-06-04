/// client_service_tracking_viewmodel.dart
/// ViewModel del seguimiento del servicio en curso.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';

class ClientServiceTrackingViewModel extends ChangeNotifier {
  SolicitudServicioModel? _solicitud;
  WorkerCatalogItemModel? _trabajador;
  bool _showReportSheet = false;
  bool _isLoading = false;
  String? _error;

  SolicitudServicioModel? get solicitud => _solicitud;
  WorkerCatalogItemModel? get trabajador => _trabajador;
  bool get showReportSheet => _showReportSheet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void load({
    required SolicitudServicioModel solicitud,
    required WorkerCatalogItemModel trabajador,
  }) {
    _solicitud = solicitud;
    _trabajador = trabajador;
    notifyListeners();
  }

  void toggleReportSheet() {
    _showReportSheet = !_showReportSheet;
    notifyListeners();
  }

  void hideReportSheet() {
    _showReportSheet = false;
    notifyListeners();
  }

  /// Actualiza el estado del servicio.
  /// TODO: Suscribirse a Supabase Realtime en lugar de polling.
  void updateEstado(EstadoSolicitud nuevoEstado) {
    if (_solicitud == null) return;
    _solicitud = _solicitud!.copyWith(estado: nuevoEstado);
    notifyListeners();
  }

  /// Finaliza el trabajo confirmando desde el lado del cliente.
  /// TODO: Llamar a SolicitudesRepository.updateEstado()
  Future<void> finalizarTrabajo() async {
    updateEstado(EstadoSolicitud.completada);
  }

  /// Envía un reporte de problema.
  /// TODO: Llamar a ReportesRepository cuando esté implementado.
  Future<bool> enviarReporte({
    required String motivo,
    String? descripcion,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    _showReportSheet = false;
    notifyListeners();
    return true;
  }
}
