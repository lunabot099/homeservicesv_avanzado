/// request_location_viewmodel.dart
/// ViewModel de la pantalla de selección de ubicación del servicio.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';

/// Departamentos de El Salvador con sus municipios.
const Map<String, List<String>> departamentosMunicipios = {
  'San Salvador': [
    'San Salvador', 'Soyapango', 'Mejicanos', 'Apopa', 'Ciudad Delgado',
    'San Marcos', 'Cuscatancingo', 'Santa Tecla', 'Antiguo Cuscatlán',
    'Santo Tomás', 'San Martín', 'Tonacatepeque', 'Panchimalco',
  ],
  'La Libertad': [
    'Santa Tecla', 'Colón', 'Quezaltepeque', 'San Juan Opico',
    'Zaragoza', 'Ciudad Arce', 'Jayaque', 'Huizúcar',
  ],
  'La Paz': [
    'Zacatecoluca', 'San Luis Talpa', 'Olocuilta', 'San Pedro Masahuat',
  ],
  'Sonsonate': ['Sonsonate', 'Acajutla', 'Izalco', 'Nahuizalco'],
  'Santa Ana': ['Santa Ana', 'Chalchuapa', 'Coatepeque', 'Texistepeque'],
  'San Miguel': ['San Miguel', 'Moncagua', 'Quelepa', 'Uluazapa'],
  'Usulután': ['Usulután', 'Jiquilisco', 'Santiago de María'],
  'Cuscatlán': ['Cojutepeque', 'Suchitoto', 'San Pedro Perulapán'],
  'Chalatenango': ['Chalatenango', 'Nueva Concepción', 'La Palma'],
  'Cabañas': ['Sensuntepeque', 'Ilobasco', 'Victoria'],
  'Morazán': ['San Francisco Gotera', 'Jocoro', 'Corinto'],
  'La Unión': ['La Unión', 'Santa Rosa de Lima', 'Pasaquina'],
  'Ahuachapán': ['Ahuachapán', 'Atiquizaya', 'Tacuba'],
  'San Vicente': ['San Vicente', 'Apastepeque', 'Tecoluca'],
};

class RequestLocationViewModel extends ChangeNotifier {
  String? _departamento;
  String? _municipio;
  String _colonia = '';
  String _calle = '';
  String _numeroCasa = '';
  String _puntoReferencia = '';
  bool _usandoUbicacionActual = false;
  double? _latitud;
  double? _longitud;

  String? get departamento => _departamento;
  String? get municipio => _municipio;
  String get colonia => _colonia;
  String get calle => _calle;
  String get numeroCasa => _numeroCasa;
  String get puntoReferencia => _puntoReferencia;
  bool get estaUsandoUbicacion => _usandoUbicacionActual;
  double? get latitud => _latitud;
  double? get longitud => _longitud;

  List<String> get departamentos => departamentosMunicipios.keys.toList();

  List<String> get municipios {
    if (_departamento == null) return [];
    return departamentosMunicipios[_departamento!] ?? [];
  }

  bool get puedeAvanzar =>
      _departamento != null &&
      _municipio != null &&
      _colonia.trim().isNotEmpty;

  void setDepartamento(String? v) {
    _departamento = v;
    _municipio = null;
    notifyListeners();
  }

  void setMunicipio(String? v) {
    _municipio = v;
    notifyListeners();
  }

  void setColonia(String v) {
    _colonia = v;
    notifyListeners();
  }

  void setCalle(String v) {
    _calle = v;
    notifyListeners();
  }

  void setNumeroCasa(String v) {
    _numeroCasa = v;
    notifyListeners();
  }

  void setPuntoReferencia(String v) {
    _puntoReferencia = v;
    notifyListeners();
  }

  /// Establece la ubicación GPS del dispositivo (mock en esta fase).
  /// TODO: Reemplazar con geolocator.getCurrentPosition() en fase de integración GPS.
  Future<void> usarUbicacionActual() async {
    _usandoUbicacionActual = true;
    // Coordenadas de demostración — San Salvador, El Salvador
    _latitud = 13.6929;
    _longitud = -89.2182;
    notifyListeners();
  }

  /// Limpia la ubicación GPS previamente establecida.
  void limpiarGps() {
    _usandoUbicacionActual = false;
    _latitud = null;
    _longitud = null;
    notifyListeners();
  }

  /// Aplica los datos de ubicación a la solicitud.
  SolicitudServicioModel aplicarA(SolicitudServicioModel solicitud) {
    return solicitud.copyWith(
      departamento: _departamento,
      municipio: _municipio,
      colonia: _colonia.isEmpty ? null : _colonia,
      calle: _calle.isEmpty ? null : _calle,
      numeroCasa: _numeroCasa.isEmpty ? null : _numeroCasa,
      puntoReferencia: _puntoReferencia.isEmpty ? null : _puntoReferencia,
      latitud: _latitud,
      longitud: _longitud,
    );
  }
}
