/// worker_request_detail_viewmodel.dart
/// ViewModel del detalle de una solicitud disponible para el trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/repositories/postulaciones_repository.dart';
import '../../../state/session_controller.dart';

class WorkerRequestDetailViewModel extends ChangeNotifier {
  final PostulacionesRepository _postulacionesRepo;
  final SessionController _sessionController;

  SolicitudServicioModel? _solicitud;
  bool _yaPostulado = false;
  bool _isLoading = false;
  bool _postulado = false;
  String? _error;

  double? _precioEstimado;
  String _mensajeInicial = '';

  WorkerRequestDetailViewModel({
    PostulacionesRepository? postulacionesRepo,
    required SessionController sessionController,
  })  : _postulacionesRepo = postulacionesRepo ?? PostulacionesRepository(),
        _sessionController = sessionController;

  SolicitudServicioModel? get solicitud => _solicitud;
  bool get yaPostulado => _yaPostulado;
  bool get isLoading => _isLoading;
  bool get postulado => _postulado;
  String? get error => _error;
  double? get precioEstimado => _precioEstimado;
  String get mensajeInicial => _mensajeInicial;

  void loadSolicitud(SolicitudServicioModel s) {
    _solicitud = s;
    notifyListeners();
  }

  void setPrecio(String v) {
    _precioEstimado = double.tryParse(v);
    notifyListeners();
  }

  void setMensaje(String v) {
    _mensajeInicial = v;
    notifyListeners();
  }

  /// Postula al trabajador a la solicitud actual.
  Future<bool> postularse() async {
    if (_solicitud == null) return false;
    final trabajadorId = _sessionController.currentUser?.id;
    if (trabajadorId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postulacionesRepo.postularse(PostulacionSolicitudModel(
        solicitudId: _solicitud!.id!,
        trabajadorId: trabajadorId,
        precioEstimado: _precioEstimado,
        mensajeInicial: _mensajeInicial.isEmpty ? null : _mensajeInicial,
      ));
      _postulado = true;
      _yaPostulado = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
