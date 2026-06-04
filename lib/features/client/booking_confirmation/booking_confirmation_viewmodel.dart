/// booking_confirmation_viewmodel.dart
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';

class BookingConfirmationViewModel extends ChangeNotifier {
  SolicitudServicioModel? _solicitud;
  WorkerCatalogItemModel? _trabajador;

  SolicitudServicioModel? get solicitud => _solicitud;
  WorkerCatalogItemModel? get trabajador => _trabajador;

  void load({
    required SolicitudServicioModel solicitud,
    required WorkerCatalogItemModel trabajador,
  }) {
    _solicitud = solicitud;
    _trabajador = trabajador;
    notifyListeners();
  }

  /// TODO: Implementar confirmación real en Supabase.
  /// - Actualizar solicitud con trabajador_id
  /// - Actualizar estado a 'confirmada'
  /// - Notificar al trabajador
  Future<bool> confirmar() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
