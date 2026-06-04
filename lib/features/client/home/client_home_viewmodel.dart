/// client_home_viewmodel.dart
/// ViewModel del home del cliente — incluye carga de solicitud activa
/// y chat asociado para mostrar accesos rápidos en la pantalla principal.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/categoria_servicio_model.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/perfil_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

class ClientHomeViewModel extends ChangeNotifier {
  final SessionController _sessionController;
  final SolicitudesRepository _solicitudesRepo;
  final ChatsRepository _chatsRepo;

  final List<CategoriaServicioModel> categorias = CategoriasServicioMock.lista;

  SolicitudServicioModel? _solicitudActiva;
  ChatModel? _chatActivo;
  bool _cargandoActiva = false;

  ClientHomeViewModel({
    required SessionController sessionController,
    SolicitudesRepository? solicitudesRepo,
    ChatsRepository? chatsRepo,
  })  : _sessionController = sessionController,
        _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _chatsRepo = chatsRepo ?? ChatsRepository();

  PerfilModel? get perfil => _sessionController.currentPerfil;

  String get saludo {
    final nombre = perfil?.nombreCompleto ?? '';
    if (nombre.isEmpty) return '¡Hola!';
    final primerNombre = nombre.split(' ').first;
    return '¡Hola, $primerNombre!';
  }

  double? get promedioCalificacion => perfil?.promedioCalificacion;
  int? get cantidadResenas => perfil?.cantidadResenas;

  /// Solicitud en curso del cliente (en búsqueda, confirmada, en proceso, etc.)
  SolicitudServicioModel? get solicitudActiva => _solicitudActiva;

  /// Chat asociado a la solicitud confirmada, si existe.
  ChatModel? get chatActivo => _chatActivo;
  bool get cargandoActiva => _cargandoActiva;

  /// True si la solicitud está en fase de búsqueda de trabajador.
  bool get enBusqueda =>
      _solicitudActiva != null &&
      (_solicitudActiva!.estado == EstadoSolicitud.en_busqueda ||
          _solicitudActiva!.estado == EstadoSolicitud.postulaciones_recibidas);

  /// True si ya hay trabajador confirmado y el servicio está en curso.
  bool get enServicio =>
      _solicitudActiva != null &&
      !enBusqueda &&
      _solicitudActiva!.estado != EstadoSolicitud.completada &&
      _solicitudActiva!.estado != EstadoSolicitud.cancelada &&
      _solicitudActiva!.estado != EstadoSolicitud.expirada;

  /// Carga la solicitud activa más reciente del cliente.
  Future<void> cargarSolicitudActiva() async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null) return;

    _cargandoActiva = true;
    notifyListeners();

    try {
      final todas = await _solicitudesRepo.getSolicitudesByCliente(userId);
      // Tomar la primera activa (no completada, cancelada ni expirada)
      _solicitudActiva = todas.where((s) =>
              s.estado != EstadoSolicitud.completada &&
              s.estado != EstadoSolicitud.cancelada &&
              s.estado != EstadoSolicitud.expirada)
          .firstOrNull;

      // Si hay servicio confirmado, buscar el chat
      if (_solicitudActiva != null && enServicio && _solicitudActiva!.id != null) {
        try {
          _chatActivo = await _chatsRepo.getChatDeSolicitud(_solicitudActiva!.id!);
        } catch (_) {
          _chatActivo = null;
        }
      } else {
        _chatActivo = null;
      }
    } catch (e) {
      debugPrint('[ClientHomeVM] Error al cargar solicitud activa: $e');
    } finally {
      _cargandoActiva = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _sessionController.signOut();
  }
}
