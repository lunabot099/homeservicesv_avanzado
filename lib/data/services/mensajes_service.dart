/// mensajes_service.dart
/// Servicio para operaciones sobre la tabla `mensajes_chat`.
///
/// Diseño ligero:
/// - Solo guarda texto, hora, remitente, referencia de archivo
/// - Imágenes en Supabase Storage → aquí solo la URL
/// - Realtime: stream de mensajes nuevos por chat
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mensaje_chat_model.dart';

class MensajesService {
  final SupabaseClient _client;
  static const _table = 'mensajes_chat';

  MensajesService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Envía un nuevo mensaje.
  Future<MensajeChatModel> enviar(MensajeChatModel mensaje) async {
    final data = await _client
        .from(_table)
        .insert(mensaje.toMap())
        .select()
        .single();
    return MensajeChatModel.fromMap(data);
  }

  /// Obtiene todos los mensajes de un chat (paginado).
  Future<List<MensajeChatModel>> getMensajes(
    String chatId, {
    int limit = 50,
    String? cursorId, // id del último mensaje para paginación
  }) async {
    var query = _client
        .from(_table)
        .select()
        .eq('chat_id', chatId)
        .order('fecha_creacion', ascending: true)
        .limit(limit);

    final data = await query;
    return (data as List)
        .map((e) => MensajeChatModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el último mensaje de un chat.
  Future<MensajeChatModel?> getUltimoMensaje(String chatId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('chat_id', chatId)
        .order('fecha_creacion', ascending: false)
        .limit(1);

    if ((data as List).isEmpty) return null;
    return MensajeChatModel.fromMap(data.first);
  }

  /// [Realtime] Stream de mensajes nuevos en un chat.
  /// Supabase filtra por chat_id para eficiencia.
  Stream<List<MensajeChatModel>> streamMensajes(String chatId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('fecha_creacion')
        .map((rows) => rows
            .map((e) => MensajeChatModel.fromMap(e))
            .toList());
  }

  /// Marca todos los mensajes de un chat como leídos para un usuario.
  Future<void> marcarLeidos({
    required String chatId,
    required String usuarioId,
  }) async {
    await _client
        .from(_table)
        .update({'leido': true})
        .eq('chat_id', chatId)
        .neq('emisor_id', usuarioId)
        .eq('leido', false);
  }

  /// Elimina todos los mensajes de un chat (llamado por Supabase Edge Function
  /// o manualmente cuando llega la fecha de expiración).
  Future<void> eliminarMensajesDeChat(String chatId) async {
    await _client.from(_table).delete().eq('chat_id', chatId);
  }

  /// Inserta un mensaje de sistema (evento del servicio).
  Future<void> enviarMensajeSistema({
    required String chatId,
    required String contenido,
  }) async {
    await _client.from(_table).insert({
      'chat_id': chatId,
      'emisor_id': 'system',       // columna real
      'tipo_mensaje': 'sistema',   // columna real
      'texto': contenido,          // columna real
      'leido': true,
    });
  }
}
