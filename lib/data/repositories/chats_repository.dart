/// chats_repository.dart
/// Repositorio de chats y mensajes — abstrae ChatsService y MensajesService.
library;

import '../models/chat_model.dart';
import '../models/mensaje_chat_model.dart';
import '../services/chats_service.dart';
import '../services/mensajes_service.dart';

class ChatsRepository {
  final ChatsService _chatsService;
  final MensajesService _mensajesService;

  ChatsRepository({
    ChatsService? chatsService,
    MensajesService? mensajesService,
  })  : _chatsService = chatsService ?? ChatsService(),
        _mensajesService = mensajesService ?? MensajesService();

  // ── Chat ─────────────────────────────────────────────────────

  /// Obtiene o crea el chat para una solicitud confirmada.
  Future<ChatModel> getOCrearChat({
    required String solicitudId,
    required String clienteId,
    required String trabajadorId,
  }) async {
    try {
      return await _chatsService.getOCrear(
        solicitudId: solicitudId,
        clienteId: clienteId,
        trabajadorId: trabajadorId,
      );
    } catch (e) {
      throw Exception('Error al obtener/crear chat: $e');
    }
  }

  /// Obtiene el chat de una solicitud.
  Future<ChatModel?> getChatDeSolicitud(String solicitudId) async {
    try {
      return await _chatsService.getBySolicitud(solicitudId);
    } catch (e) {
      throw Exception('Error al obtener chat: $e');
    }
  }

  /// Obtiene todos los chats del usuario.
  Future<List<ChatModel>> getMisChats(String userId) async {
    try {
      return await _chatsService.getMisChats(userId);
    } catch (e) {
      throw Exception('Error al obtener chats: $e');
    }
  }

  /// Programa la eliminación de mensajes (llamar al completar servicio).
  Future<void> programarLimpieza(String chatId) async {
    try {
      await _chatsService.programarEliminacion(chatId);
    } catch (e) {
      throw Exception('Error al programar limpieza: $e');
    }
  }

  // ── Mensajes ─────────────────────────────────────────────────

  /// Envía un mensaje de texto.
  Future<MensajeChatModel> enviarTexto({
    required String chatId,
    required String remitenteId,
    required String texto,
  }) async {
    try {
      return await _mensajesService.enviar(MensajeChatModel(
        chatId: chatId,
        remitenteId: remitenteId,
        tipo: TipoMensaje.texto,
        contenido: texto,
      ));
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  /// Envía un mensaje con imagen (la URL ya viene de StorageService).
  Future<MensajeChatModel> enviarImagen({
    required String chatId,
    required String remitenteId,
    required String archivoUrl,
  }) async {
    try {
      return await _mensajesService.enviar(MensajeChatModel(
        chatId: chatId,
        remitenteId: remitenteId,
        tipo: TipoMensaje.imagen,
        archivoUrl: archivoUrl,
      ));
    } catch (e) {
      throw Exception('Error al enviar imagen: $e');
    }
  }

  /// Obtiene los mensajes de un chat.
  Future<List<MensajeChatModel>> getMensajes(String chatId,
      {int limit = 50}) async {
    try {
      return await _mensajesService.getMensajes(chatId, limit: limit);
    } catch (e) {
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  /// [Realtime] Stream de mensajes del chat.
  Stream<List<MensajeChatModel>> streamMensajes(String chatId) {
    return _mensajesService.streamMensajes(chatId);
  }

  /// Marca todos los mensajes como leídos para el usuario actual.
  Future<void> marcarLeidos({
    required String chatId,
    required String usuarioId,
  }) async {
    try {
      await _mensajesService.marcarLeidos(
          chatId: chatId, usuarioId: usuarioId);
    } catch (e) {
      throw Exception('Error al marcar mensajes: $e');
    }
  }

  /// Envía un mensaje de sistema automático.
  Future<void> enviarEventoSistema({
    required String chatId,
    required String contenido,
  }) async {
    try {
      await _mensajesService.enviarMensajeSistema(
          chatId: chatId, contenido: contenido);
    } catch (e) {
      // Silencioso — los mensajes de sistema no son críticos
    }
  }
}
