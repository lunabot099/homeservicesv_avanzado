/// client_service_tracking_viewmodel.dart
/// ViewModel del seguimiento del servicio en curso.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';

class ClientServiceTrackingViewModel extends ChangeNotifier {
  final SolicitudesRepository _solicitudesRepo;
  final ChatsRepository _chatsRepo;
  final PerfilesRepository _perfilesRepo;
  SolicitudServicioModel? _solicitud;
  WorkerCatalogItemModel? _trabajador;
  bool _showReportSheet = false;
  bool _isLoading = false;
  String? _error;

  ClientServiceTrackingViewModel({
    SolicitudesRepository? solicitudesRepo,
    ChatsRepository? chatsRepo,
    PerfilesRepository? perfilesRepo,
  })  : _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _chatsRepo = chatsRepo ?? ChatsRepository(),
        _perfilesRepo = perfilesRepo ?? PerfilesRepository();

  SolicitudServicioModel? get solicitud => _solicitud;
  WorkerCatalogItemModel? get trabajador => _trabajador;
  bool get showReportSheet => _showReportSheet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void load({
    required SolicitudServicioModel solicitud,
    WorkerCatalogItemModel? trabajador,
  }) {
    _solicitud = solicitud;
    _trabajador = trabajador;
    notifyListeners();
  }

  /// Carga el seguimiento usando solo el ID de la ruta.
  /// Esto permite volver a abrir la pantalla desde Home o por URL directa.
  Future<void> loadById(String solicitudId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final solicitud = await _solicitudesRepo.getSolicitudById(solicitudId);
      _solicitud = solicitud;

      final trabajadorId = solicitud?.trabajadorId;
      if (trabajadorId != null && trabajadorId.isNotEmpty) {
        final perfil = await _perfilesRepo.getPerfilById(trabajadorId);
        if (perfil != null) {
          _trabajador = WorkerCatalogItemModel(
            trabajadorId: perfil.id,
            nombre: perfil.nombreCompleto,
            fotoUrl: perfil.fotoPerfilUrl,
            calificacion: perfil.promedioCalificacion ?? 0,
            cantidadResenas: perfil.cantidadResenas ?? 0,
            verificado: true,
          );
        }
      }
    } catch (e) {
      _error = 'No se pudo cargar el seguimiento del servicio.';
      debugPrint('[ClientTrackingVM] Error al cargar seguimiento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleReportSheet() {
    _showReportSheet = !_showReportSheet;
    notifyListeners();
  }

  void hideReportSheet() {
    _showReportSheet = false;
    notifyListeners();
  }

  /// Actualiza el estado del servicio.
  /// TODO: Suscribirse a Supabase Realtime en lugar de polling.
  void updateEstado(EstadoSolicitud nuevoEstado) {
    if (_solicitud == null) return;
    _solicitud = _solicitud!.copyWith(estado: nuevoEstado);
    notifyListeners();
  }

  /// Finaliza el trabajo confirmando desde el lado del cliente y elimina el chat.
  Future<void> finalizarTrabajo() async {
    final solicitudId = _solicitud?.id;
    if (solicitudId == null) {
      updateEstado(EstadoSolicitud.completada);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitud = await _solicitudesRepo.updateEstado(
        id: solicitudId,
        estado: EstadoSolicitud.completada,
      );
      await _chatsRepo.eliminarChatDeSolicitud(solicitudId);
    } catch (e) {
      updateEstado(EstadoSolicitud.completada);
      try {
        await _chatsRepo.eliminarChatDeSolicitud(solicitudId);
      } catch (_) {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía un reporte de problema.
  /// TODO: Llamar a ReportesRepository cuando esté implementado.
  Future<bool> enviarReporte({
    required String motivo,
    String? descripcion,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    _showReportSheet = false;
    notifyListeners();
    return true;
  }
}
