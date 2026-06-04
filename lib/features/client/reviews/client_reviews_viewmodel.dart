/// client_reviews_viewmodel.dart
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/resena_model.dart';
import '../../../data/repositories/resenas_repository.dart';
import '../../../state/session_controller.dart';

class ClientReviewsViewModel extends ChangeNotifier {
  final ResenasRepository _resenasRepository;
  final SessionController _sessionController;

  List<ResenaModel> _resenas = [];
  bool _isLoading = false;
  String? _error;

  ClientReviewsViewModel({
    ResenasRepository? resenasRepository,
    required SessionController sessionController,
  })  : _resenasRepository = resenasRepository ?? ResenasRepository(),
        _sessionController = sessionController;

  List<ResenaModel> get resenas => _resenas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get promedioCalificacion {
    if (_resenas.isEmpty) return 0;
    return _resenas.map((r) => r.calificacion).reduce((a, b) => a + b) /
        _resenas.length;
  }

  Future<void> loadResenas() async {
    final clienteId = _sessionController.currentUser?.id;
    if (clienteId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resenas = await _resenasRepository.getResenasByCliente(clienteId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
