/// rate_worker_viewmodel.dart
/// ViewModel de la pantalla de calificación del trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/resena_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/repositories/resenas_repository.dart';

class RateWorkerViewModel extends ChangeNotifier {
  final ResenasRepository _resenasRepository;

  WorkerCatalogItemModel? _trabajador;
  String? _solicitudId;
  String? _clienteId;

  double _calificacion = 0;
  String _comentario = '';
  List<String> _preguntasRapidas = [];
  bool _guardarFavorito = false;
  bool _isLoading = false;
  bool _enviado = false;
  String? _error;

  RateWorkerViewModel({ResenasRepository? resenasRepository})
      : _resenasRepository = resenasRepository ?? ResenasRepository();

  double get calificacion => _calificacion;
  String get comentario => _comentario;
  bool get guardarFavorito => _guardarFavorito;
  bool get isLoading => _isLoading;
  bool get enviado => _enviado;
  String? get error => _error;
  WorkerCatalogItemModel? get trabajador => _trabajador;
  bool get puedeEnviar => _calificacion > 0;

  void load({
    required WorkerCatalogItemModel trabajador,
    required String solicitudId,
    required String clienteId,
  }) {
    _trabajador = trabajador;
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

  void toggleGuardarFavorito() {
    _guardarFavorito = !_guardarFavorito;
    notifyListeners();
  }

  void togglePreguntaRapida(String pregunta) {
    if (_preguntasRapidas.contains(pregunta)) {
      _preguntasRapidas = _preguntasRapidas.where((p) => p != pregunta).toList();
    } else {
      _preguntasRapidas = [..._preguntasRapidas, pregunta];
    }
    notifyListeners();
  }

  Future<bool> enviarCalificacion() async {
    if (_calificacion == 0 || _solicitudId == null || _clienteId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resena = ResenaModel(
        solicitudId: _solicitudId!,
        clienteId: _clienteId!,
        trabajadorId: _trabajador!.trabajadorId,
        emisorId: _clienteId!,
        tipo: TipoResena.clienteATrabajador,
        calificacion: _calificacion,
        comentario: _comentario.isEmpty ? null : _comentario,
        preguntasRapidas: _preguntasRapidas.isEmpty ? null : _preguntasRapidas,
      );
      await _resenasRepository.createResena(resena);
      // TODO: Si guardarFavorito, agregar a favoritos_trabajador
      _enviado = true;
      return true;
    } catch (e) {
      _error = 'No se pudo enviar la calificación.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
