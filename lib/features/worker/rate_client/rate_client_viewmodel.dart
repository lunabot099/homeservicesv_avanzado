/// rate_client_viewmodel.dart
/// ViewModel para que el trabajador califique al cliente.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/resena_model.dart';
import '../../../data/repositories/resenas_repository.dart';
import '../../../state/session_controller.dart';

class RateClientViewModel extends ChangeNotifier {
  final ResenasRepository _resenasRepo;
  final SessionController _sessionController;

  String? _solicitudId;
  String? _clienteId;
  double _calificacion = 0;
  String _comentario = '';
  List<String> _preguntasRapidas = [];
  bool _isLoading = false;
  bool _enviado = false;
  String? _error;

  RateClientViewModel({
    ResenasRepository? resenasRepo,
    required SessionController sessionController,
  })  : _resenasRepo = resenasRepo ?? ResenasRepository(),
        _sessionController = sessionController;

  double get calificacion => _calificacion;
  String get comentario => _comentario;
  List<String> get preguntasRapidas => _preguntasRapidas;
  bool get isLoading => _isLoading;
  bool get enviado => _enviado;
  String? get error => _error;
  bool get puedeEnviar => _calificacion > 0;

  void load({required String solicitudId, required String clienteId}) {
    _solicitudId = solicitudId;
    _clienteId = clienteId;
    notifyListeners();
  }

  void setCalificacion(double v) {
    _calificacion = v;
    notifyListeners();
  }

  void setComentario(String v) {
    _comentario = v;
    notifyListeners();
  }

  void togglePregunta(String p) {
    if (_preguntasRapidas.contains(p)) {
      _preguntasRapidas = _preguntasRapidas.where((x) => x != p).toList();
    } else {
      _preguntasRapidas = [..._preguntasRapidas, p];
    }
    notifyListeners();
  }

  Future<bool> enviarCalificacion() async {
    final trabajadorId = _sessionController.currentUser?.id;
    if (_calificacion == 0 ||
        _solicitudId == null ||
        _clienteId == null ||
        trabajadorId == null) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _resenasRepo.createResena(ResenaModel(
        solicitudId: _solicitudId!,
        clienteId: _clienteId!,
        trabajadorId: trabajadorId,
        emisorId: trabajadorId,
        tipo: TipoResena.trabajadorACliente,
        calificacion: _calificacion,
        comentario: _comentario.isEmpty ? null : _comentario,
        preguntasRapidas: _preguntasRapidas.isEmpty ? null : _preguntasRapidas,
      ));
      _enviado = true;
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
