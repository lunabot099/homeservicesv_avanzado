/// client_messages_viewmodel.dart
/// ViewModel de la pantalla de mensajes del cliente.
/// Carga chats reales desde Supabase y enriquece con datos del perfil
/// del trabajador (nombre y foto) y el último mensaje de cada chat.
library;

import 'package:flutter/foundation.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
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
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _perfilesRepo = perfilesRepo ?? PerfilesRepository(),
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
          final mensajes = await _chatsRepo.getMensajes(chat.id!, limit: 1);
          if (mensajes.isNotEmpty) {
            final ultimo = mensajes.last;
            ultimoMensajeTexto = _textoMensaje(ultimo.tipo.name, ultimo.contenido);
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

      _chats = await Future.wait(futures);
      // Ordenar por más reciente primero
      _chats.sort((a, b) => b.fechaUltimoMensaje.compareTo(a.fechaUltimoMensaje));
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
