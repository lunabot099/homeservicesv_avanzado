/// service_selection_viewmodel.dart
/// ViewModel de la pantalla de selección de subcategoría de servicio.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/categoria_servicio_model.dart';
import '../../../data/models/subcategoria_servicio_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';

class ServiceSelectionViewModel extends ChangeNotifier {
  CategoriaServicioModel? _categoria;
  SubcategoriaServicioModel? _subcategoriaSeleccionada;
  String? _descripcionPersonalizada;
  bool _mostrarCampoPersonalizado = false;

  // ── Datos de la solicitud en construcción ─────────────────────
  // Esta solicitud se va armando pantalla a pantalla
  SolicitudServicioModel? _solicitudEnConstruccion;

  List<SubcategoriaServicioModel> _subcategorias = [];

  ServiceSelectionViewModel();

  CategoriaServicioModel? get categoria => _categoria;
  SubcategoriaServicioModel? get subcategoriaSeleccionada => _subcategoriaSeleccionada;
  List<SubcategoriaServicioModel> get subcategorias => _subcategorias;
  bool get mostrarCampoPersonalizado => _mostrarCampoPersonalizado;
  String? get descripcionPersonalizada => _descripcionPersonalizada;
  SolicitudServicioModel? get solicitudEnConstruccion => _solicitudEnConstruccion;

  /// Carga la categoría y sus subcategorías (usa mock).
  /// TODO: Reemplazar mock por llamada real a Supabase cuando la tabla exista.
  void loadCategoria(String categoriaId) {
    final cats = CategoriasServicioMock.lista;
    _categoria = cats.firstWhere(
      (c) => c.id == categoriaId,
      orElse: () => CategoriaServicioModel(id: categoriaId, nombre: categoriaId),
    );
    _subcategorias = SubcategoriasMock.getByCategoria(categoriaId);
    _subcategoriaSeleccionada = null;
    _mostrarCampoPersonalizado = false;
    notifyListeners();
  }

  void selectSubcategoria(SubcategoriaServicioModel sub) {
    _subcategoriaSeleccionada = sub;
    _mostrarCampoPersonalizado = sub.nombre == 'Otro';
    _descripcionPersonalizada = null;
    notifyListeners();
  }

  void setDescripcionPersonalizada(String desc) {
    _descripcionPersonalizada = desc;
    notifyListeners();
  }

  /// Verifica si hay una selección válida para continuar.
  bool get puedeAvanzar {
    if (_subcategoriaSeleccionada == null) return false;
    if (_mostrarCampoPersonalizado) {
      return _descripcionPersonalizada != null &&
          _descripcionPersonalizada!.trim().isNotEmpty;
    }
    return true;
  }

  /// Prepara la solicitud con los datos de esta pantalla.
  void prepararSolicitud(String clienteId) {
    _solicitudEnConstruccion = SolicitudServicioModel(
      clienteId: clienteId,
      categoriaId: _categoria!.id,
      subcategoriaId: _subcategoriaSeleccionada?.id,
      descripcion: _mostrarCampoPersonalizado
          ? (_descripcionPersonalizada ?? '')
          : _subcategoriaSeleccionada?.nombre ?? '',
    );
    notifyListeners();
  }
}
