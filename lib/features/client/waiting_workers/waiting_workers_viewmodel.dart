/// waiting_workers_viewmodel.dart
/// ViewModel de la pantalla de espera de trabajadores.
/// La solicitud llega ya creada en Supabase (con id real).
/// Suscribe en tiempo real a postulaciones_solicitud via Supabase Realtime.
/// Incluye timer de expiración automática (1 h → expirada, 90 min → cleanup).
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../data/repositories/postulaciones_repository.dart';

class WaitingWorkersViewModel extends ChangeNotifier {
  final SolicitudesRepository _solicitudesRepo;
  final PostulacionesRepository _postulacionesRepo;

  SolicitudServicioModel? _solicitud;
  List<PostulacionSolicitudModel> _postulaciones = [];
  bool _isLoadingPostulaciones = false;
  bool _cancelado = false;
  bool _expirada = false;
  String? _error;
  StreamSubscription<List<PostulacionSolicitudModel>>? _streamSub;
  Timer? _expiracionTimer;

  WaitingWorkersViewModel({
    SolicitudesRepository? solicitudesRepo,
    PostulacionesRepository? postulacionesRepo,
  })  : _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _postulacionesRepo = postulacionesRepo ?? PostulacionesRepository();

  SolicitudServicioModel? get solicitud => _solicitud;
  List<PostulacionSolicitudModel> get postulaciones =>
      List.unmodifiable(_postulaciones);
  int get trabajadoresInteresados => _postulaciones.length;
  bool get isLoadingPostulaciones => _isLoadingPostulaciones;
  bool get cancelado => _cancelado;
  bool get expirada => _expirada;
  String? get error => _error;

  /// Registra la solicitud ya creada en Supabase e inicia la suscripción Realtime
  /// y el timer de expiración automática.
  void recibirSolicitudCreada(SolicitudServicioModel s) {
    _solicitud = s;
    notifyListeners();
    if (s.id != null) {
      _suscribirPostulaciones(s.id!);
      _iniciarTimerExpiracion(s);
    }
    // Limpieza background: elimina solicitudes expiradas > 90 min
    _solicitudesRepo.limpiarExpiradas();
  }

  /// Inicia el timer basado en el tiempo ya transcurrido desde la creación.
  void _iniciarTimerExpiracion(SolicitudServicioModel s) {
    _expiracionTimer?.cancel();

    final creacion = s.fechaCreacion ?? DateTime.now();
    final transcurrido = DateTime.now().difference(creacion);
    const limite = Duration(hours: 1);

    if (transcurrido >= limite) {
      // Ya superó la hora — expirar inmediatamente
      _expirarSolicitud();
      return;
    }

    final restante = limite - transcurrido;
    debugPrint('[WaitingWorkersVM] Expiración en ${restante.inMinutes} min');
    _expiracionTimer = Timer(restante, _expirarSolicitud);
  }

  /// Marca la solicitud como expirada en BD y notifica a la UI para navegar.
  Future<void> _expirarSolicitud() async {
    if (_solicitud?.id == null) return;
    try {
      await _solicitudesRepo.updateEstado(
        id: _solicitud!.id!,
        estado: EstadoSolicitud.expirada,
      );
    } catch (e) {
      debugPrint('[WaitingWorkersVM] Error al expirar solicitud: $e');
    }
    _expirada = true;
    notifyListeners();
  }

  /// Suscribe al stream Realtime de postulaciones para esta solicitud.
  void _suscribirPostulaciones(String solicitudId) {
    _isLoadingPostulaciones = true;
    notifyListeners();

    _streamSub?.cancel();
    _streamSub = _postulacionesRepo
        .streamPostulaciones(solicitudId)
        .listen(
          (lista) {
            _postulaciones = lista;
            _isLoadingPostulaciones = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('[WaitingWorkersVM] Error Realtime: $e');
            _isLoadingPostulaciones = false;
            // Fallback: carga manual puntual
            _cargarPuntual(solicitudId);
          },
        );
  }

  /// Carga puntual manual — fallback o refresh explícito.
  Future<void> _cargarPuntual(String solicitudId) async {
    _isLoadingPostulaciones = true;
    notifyListeners();
    try {
      _postulaciones = await _postulacionesRepo
          .getPostulacionesDeSolicitud(solicitudId);
    } catch (e) {
      debugPrint('[WaitingWorkersVM] Error al cargar postulaciones: $e');
    } finally {
      _isLoadingPostulaciones = false;
      notifyListeners();
    }
  }

  /// Recarga manual (botón "Actualizar").
  Future<void> refrescar() async {
    if (_solicitud?.id != null) {
      await _cargarPuntual(_solicitud!.id!);
    }
  }

  /// Cancela la solicitud activa y navega al home.
  Future<void> cancelarSolicitud() async {
    if (_solicitud?.id != null) {
      try {
        await _solicitudesRepo.cancelarSolicitud(_solicitud!.id!);
      } catch (e) {
        _error = 'No se pudo cancelar la solicitud.';
        notifyListeners();
        return;
      }
    }
    _cancelado = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _expiracionTimer?.cancel();
    super.dispose();
  }
}
