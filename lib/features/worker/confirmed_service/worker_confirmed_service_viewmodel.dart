/// worker_confirmed_service_viewmodel.dart
/// ViewModel del servicio confirmado — vista previa al trabajo en curso.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';

class WorkerConfirmedServiceViewModel extends ChangeNotifier {
  SolicitudServicioModel? _solicitud;
  WorkerCatalogItemModel? _clienteInfo; // Datos del cliente (adaptado del modelo)

  SolicitudServicioModel? get solicitud => _solicitud;
  WorkerCatalogItemModel? get clienteInfo => _clienteInfo;

  void load({
    required SolicitudServicioModel solicitud,
    WorkerCatalogItemModel? clienteInfo,
  }) {
    _solicitud = solicitud;
    _clienteInfo = clienteInfo;
    notifyListeners();
  }

  String get direccionCompleta {
    final s = _solicitud;
    if (s == null) return '';
    final partes = [
      s.calle,
      s.numeroCasa,
      s.colonia,
      s.municipio,
      s.departamento,
    ].whereType<String>().where((p) => p.isNotEmpty).toList();
    return partes.join(', ');
  }

  String get metodoPago => _solicitud?.tipoPago.label ?? '—';

  String get montoAcordadoLabel {
    final monto = _solicitud?.montoAcordado;
    if (monto == null) return 'A convenir';
    return '\$${monto.toStringAsFixed(2)}';
  }
}
