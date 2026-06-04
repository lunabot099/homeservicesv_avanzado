/// worker_reviews_viewmodel.dart
/// ViewModel de la pantalla de reseñas recibidas por el trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/resena_model.dart';
import '../../../data/repositories/resenas_repository.dart';
import '../../../state/session_controller.dart';

class WorkerReviewsViewModel extends ChangeNotifier {
  final ResenasRepository _resenasRepo;
  final SessionController _sessionController;

  List<ResenaModel> _resenas = [];
  bool _isLoading = false;
  String? _error;

  WorkerReviewsViewModel({
    ResenasRepository? resenasRepo,
    required SessionController sessionController,
  })  : _resenasRepo = resenasRepo ?? ResenasRepository(),
        _sessionController = sessionController;

  List<ResenaModel> get resenas => _resenas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get promedio {
    if (_resenas.isEmpty) return 0;
    return _resenas.map((r) => r.calificacion).reduce((a, b) => a + b) /
        _resenas.length;
  }

  int get totalResenas => _resenas.length;

  Future<void> loadResenas() async {
    final trabajadorId = _sessionController.currentUser?.id;
    if (trabajadorId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resenas = await _resenasRepo.getResenasByTrabajador(trabajadorId);
    } catch (_) {
      _resenas = _mockResenas();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ResenaModel> _mockResenas() => [
        ResenaModel(
          id: 'r1',
          solicitudId: 's1',
          clienteId: 'c1',
          trabajadorId: _sessionController.currentUser?.id ?? 'w1',
          emisorId: 'c1',
          tipo: TipoResena.clienteATrabajador,
          calificacion: 5.0,
          comentario: 'Excelente trabajo, muy puntual y profesional.',
          fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ResenaModel(
          id: 'r2',
          solicitudId: 's2',
          clienteId: 'c2',
          trabajadorId: _sessionController.currentUser?.id ?? 'w1',
          emisorId: 'c2',
          tipo: TipoResena.clienteATrabajador,
          calificacion: 4.5,
          comentario: 'Buen servicio, dejó todo limpio. Recomendado.',
          preguntasRapidas: ['Puntual', 'Profesional'],
          fechaCreacion: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ResenaModel(
          id: 'r3',
          solicitudId: 's3',
          clienteId: 'c3',
          trabajadorId: _sessionController.currentUser?.id ?? 'w1',
          emisorId: 'c3',
          tipo: TipoResena.clienteATrabajador,
          calificacion: 4.0,
          comentario: 'Bien, aunque tardó un poco más de lo esperado.',
          fechaCreacion: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];
}
