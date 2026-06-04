/// worker_profile_detail_viewmodel.dart
/// ViewModel del perfil detalle de un trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/resena_model.dart';

class WorkerProfileDetailViewModel extends ChangeNotifier {
  WorkerCatalogItemModel? _worker;
  List<ResenaModel> _resenas = [];
  bool _isLoading = false;
  String? _error;

  WorkerCatalogItemModel? get worker => _worker;
  List<ResenaModel> get resenas => _resenas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga los datos del trabajador.
  /// TODO: llamar a WorkersRepository.getWorkerById() y ResenasRepository.getResenasByTrabajador()
  Future<void> loadWorker(WorkerCatalogItemModel worker) async {
    _isLoading = true;
    _worker = worker;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    // Mock de reseñas — reemplazar con datos reales
    _resenas = [];
    _isLoading = false;
    notifyListeners();
  }
}
