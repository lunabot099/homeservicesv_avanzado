/// workers_catalog_viewmodel.dart
/// ViewModel del catálogo de trabajadores interesados.
/// Carga postulaciones reales de Supabase y construye WorkerCatalogItemModel
/// combinando datos de postulaciones con datos del perfil del trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/postulaciones_repository.dart';

enum CatalogFilter { mejorCalificados, masCercanos, menorPrecio, mayorExperiencia }

class WorkersCatalogViewModel extends ChangeNotifier {
  final PostulacionesRepository _postulacionesRepo;
  final PerfilesRepository _perfilesRepo;

  SolicitudServicioModel? _solicitud;
  List<WorkerCatalogItemModel> _workers = [];
  CatalogFilter _filtro = CatalogFilter.mejorCalificados;
  WorkerCatalogItemModel? _seleccionado;
  bool _isLoading = false;
  String? _error;

  WorkersCatalogViewModel({
    PostulacionesRepository? postulacionesRepo,
    PerfilesRepository? perfilesRepo,
  })  : _postulacionesRepo = postulacionesRepo ?? PostulacionesRepository(),
        _perfilesRepo = perfilesRepo ?? PerfilesRepository();

  List<WorkerCatalogItemModel> get workers => _workersOrdenados();
  CatalogFilter get filtro => _filtro;
  WorkerCatalogItemModel? get seleccionado => _seleccionado;
  bool get isLoading => _isLoading;
  SolicitudServicioModel? get solicitud => _solicitud;
  String? get error => _error;

  /// Carga los trabajadores que se postularon a la solicitud desde Supabase.
  /// Si falla (ej. sin conexión), cae al mock para no bloquear el flujo.
  Future<void> loadWorkers(SolicitudServicioModel solicitud) async {
    _isLoading = true;
    _error = null;
    _solicitud = solicitud;
    notifyListeners();

    try {
      if (solicitud.id != null) {
        // Obtener postulaciones reales de la solicitud
        final postulaciones = await _postulacionesRepo
            .getPostulacionesDeSolicitud(solicitud.id!);

        if (postulaciones.isNotEmpty) {
          // Cargar perfiles en paralelo para obtener nombre y foto reales
          final futures = postulaciones.map((p) async {
            String nombre = 'Trabajador';
            String? fotoUrl;
            try {
              final perfil = await _perfilesRepo.getPerfilById(p.trabajadorId);
              if (perfil != null) {
                nombre = perfil.nombreCompleto;
                fotoUrl = perfil.fotoPerfilUrl;
              }
            } catch (_) {}
            return WorkerCatalogItemModel(
              trabajadorId: p.trabajadorId,
              nombre: nombre,
              fotoUrl: fotoUrl,
              tarifa: p.precioEstimado,
              postulacion: p,
              disponible: true,
            );
          });
          _workers = await Future.wait(futures);
        } else {
          // Sin postulaciones reales aún — muestra estado vacío (no mock)
          _workers = [];
        }
      } else {
        // Solicitud sin id (flujo mock) — usar datos de demostración
        _workers = WorkerCatalogItemModel.mockList(solicitud.categoriaId);
      }
    } catch (e) {
      debugPrint('[WorkersCatalogVM] Error al cargar postulaciones: $e');
      _error = 'No se pudieron cargar los trabajadores.';
      // Fallback a mock en errores de conexión
      _workers = WorkerCatalogItemModel.mockList(solicitud.categoriaId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFiltro(CatalogFilter filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  void selectWorker(WorkerCatalogItemModel worker) {
    _seleccionado = worker;
    notifyListeners();
  }

  List<WorkerCatalogItemModel> _workersOrdenados() {
    final sorted = [..._workers];
    switch (_filtro) {
      case CatalogFilter.mejorCalificados:
        sorted.sort((a, b) => b.calificacion.compareTo(a.calificacion));
      case CatalogFilter.masCercanos:
        sorted.sort((a, b) =>
            (a.distanciaKm ?? 999).compareTo(b.distanciaKm ?? 999));
      case CatalogFilter.menorPrecio:
        sorted.sort((a, b) => (a.tarifa ?? 999).compareTo(b.tarifa ?? 999));
      case CatalogFilter.mayorExperiencia:
        sorted.sort((a, b) =>
            b.cantidadResenas.compareTo(a.cantidadResenas));
    }
    return sorted;
  }
}
