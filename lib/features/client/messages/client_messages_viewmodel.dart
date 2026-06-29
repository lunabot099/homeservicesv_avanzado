/// client_messages_viewmodel.dart
/// ViewModel de la pantalla de mensajes del cliente.
/// Carga chats reales desde Supabase y enriquece con datos del perfil
/// del trabajador (nombre y foto) y el último mensaje de cada chat.
library;

import 'package:flutter/foundation.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

/// Modelo de vista para cada fila en la lista de chats del cliente.
class ChatPreviewModel {
  final String chatId;
  final String solicitudId;
  final String trabajadorId;
  final String nombreTrabajador;
  final String? fotoTrabajadorUrl;
  final String ultimoMensaje;
  final DateTime fechaUltimoMensaje;
  final bool tieneMensajesNoLeidos;

  const ChatPreviewModel({
    required this.chatId,
    required this.solicitudId,
    required this.trabajadorId,
    required this.nombreTrabajador,
    this.fotoTrabajadorUrl,
    required this.ultimoMensaje,
    required this.fechaUltimoMensaje,
    this.tieneMensajesNoLeidos = false,
  });
}

class ClientMessagesViewModel extends ChangeNotifier {
  final ChatsRepository _chatsRepo;
  final PerfilesRepository _perfilesRepo;
  final SolicitudesRepository _solicitudesRepo;
  final SessionController _sessionController;

  List<ChatPreviewModel> _chats = [];
  bool _isLoading = false;
  String? _error;

  List<ChatPreviewModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ClientMessagesViewModel({
    ChatsRepository? chatsRepo,
    PerfilesRepository? perfilesRepo,
    SolicitudesRepository? solicitudesRepo,
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _perfilesRepo = perfilesRepo ?? PerfilesRepository(),
        _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _sessionController = sessionController;

  /// Carga y enriquece los chats del cliente desde Supabase.
  Future<void> loadChats() async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawChats = await _chatsRepo.getMisChats(userId);

      // Enriquecer cada chat con datos del perfil del trabajador
      final futures = rawChats.map((chat) async {
        final solicitud =
            await _solicitudesRepo.getSolicitudById(chat.solicitudId);
        if (!_chatActivo(solicitud)) return null;

        String nombre = 'Trabajador';
        String? fotoUrl;

        try {
          final perfil = await _perfilesRepo.getPerfilById(chat.trabajadorId);
          if (perfil != null) {
            nombre = perfil.nombreCompleto;
            fotoUrl = perfil.fotoPerfilUrl;
          }
        } catch (_) {}

        // Obtener el último mensaje del chat
        String ultimoMensajeTexto = 'Chat activo';
        DateTime fechaMensaje = chat.creadoEn ?? DateTime.now();
        try {
          final ultimo = await _chatsRepo.getUltimoMensaje(chat.id!);
          if (ultimo != null) {
            ultimoMensajeTexto =
                _textoMensaje(ultimo.tipo.name, ultimo.contenido);
            fechaMensaje = ultimo.creadoEn ?? fechaMensaje;
          }
        } catch (_) {}

        return ChatPreviewModel(
          chatId: chat.id!,
          solicitudId: chat.solicitudId,
          trabajadorId: chat.trabajadorId,
          nombreTrabajador: nombre,
          fotoTrabajadorUrl: fotoUrl,
          ultimoMensaje: ultimoMensajeTexto,
          fechaUltimoMensaje: fechaMensaje,
          tieneMensajesNoLeidos: (chat.mensajesNoLeidos ?? 0) > 0,
        );
      });

      _chats =
          (await Future.wait(futures)).whereType<ChatPreviewModel>().toList();
      // Ordenar por más reciente primero
      _chats
          .sort((a, b) => b.fechaUltimoMensaje.compareTo(a.fechaUltimoMensaje));
    } catch (e) {
      debugPrint('[ClientMessagesVM] Error: $e');
      _error = 'No se pudieron cargar los mensajes.';
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _textoMensaje(String? tipo, String? contenido) {
    if (tipo == 'imagen') return '📷 Imagen';
    if (tipo == 'sistema') return '🔔 ${contenido ?? 'Evento del servicio'}';
    return contenido ?? 'Chat activo';
  }
}

bool _chatActivo(SolicitudServicioModel? solicitud) {
  final estado = solicitud?.estado;
  return estado == EstadoSolicitud.confirmada ||
      estado == EstadoSolicitud.en_camino ||
      estado == EstadoSolicitud.ha_llegado ||
      estado == EstadoSolicitud.en_proceso ||
      estado == EstadoSolicitud.finalizado_pendiente;
}
