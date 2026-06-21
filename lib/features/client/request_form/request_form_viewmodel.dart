/// request_form_viewmodel.dart
/// ViewModel del formulario de descripción del trabajo.
library;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/solicitud_servicio_model.dart';

class RequestFormViewModel extends ChangeNotifier {
  String _descripcion = '';
  UrgenciaSolicitud _urgencia = UrgenciaSolicitud.flexible;
  TipoPago _tipoPago = TipoPago.a_convenir;
  String _horario = '';
  double? _presupuesto;

  /// Bytes de las imágenes seleccionadas (para preview en web y móvil).
  final List<Uint8List> _imagenesBytes = [];

  /// Archivos originales (para subir a storage en fases futuras).
  final List<XFile> _imagenesFiles = [];

  // ignore: unused_field — reservado para indicar estado de subida futura
  final bool _isUploading = false;
  String? _error;

  String get descripcion => _descripcion;
  UrgenciaSolicitud get urgencia => _urgencia;
  TipoPago get tipoPago => _tipoPago;
  String get horario => _horario;
  double? get presupuesto => _presupuesto;
  List<Uint8List> get imagenesBytes => List.unmodifiable(_imagenesBytes);
  List<XFile> get imagenesFiles => List.unmodifiable(_imagenesFiles);
  int get imagenesCount => _imagenesBytes.length;
  bool get isUploading => _isUploading;
  String? get error => _error;

  bool get puedeAvanzar => _descripcion.trim().length >= 10;

  void setDescripcion(String v) {
    _descripcion = v;
    notifyListeners();
  }

  void setUrgencia(UrgenciaSolicitud v) {
    _urgencia = v;
    notifyListeners();
  }

  void setTipoPago(TipoPago v) {
    _tipoPago = v;
    notifyListeners();
  }

  void setHorario(String v) {
    _horario = v;
    notifyListeners();
  }

  void setPresupuesto(String v) {
    _presupuesto = double.tryParse(v);
    notifyListeners();
  }

  /// Abre el selector de imágenes (compatible con Flutter Web y móvil).
  Future<void> pickImagen() async {
    if (_imagenesBytes.length >= 3) return;
    _error = null;

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (xfile == null) return; // usuario canceló

      final bytes = await xfile.readAsBytes();
      _imagenesBytes.add(bytes);
      _imagenesFiles.add(xfile);
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo seleccionar la imagen.';
      notifyListeners();
    }
  }

  void removeImagen(int index) {
    if (index < 0 || index >= _imagenesBytes.length) return;
    _imagenesBytes.removeAt(index);
    _imagenesFiles.removeAt(index);
    notifyListeners();
  }

  /// Aplica los datos del formulario a una solicitud existente.
  SolicitudServicioModel aplicarA(SolicitudServicioModel solicitud) {
    return solicitud.copyWith(
      descripcion: _descripcion,
      urgencia: _urgencia,
      tipoPago: _tipoPago,
      horarioPreferido: _horario.isEmpty ? null : _horario,
      presupuestoEstimado: _presupuesto,
      imagenesPendientesBytes: List<Uint8List>.from(_imagenesBytes),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
