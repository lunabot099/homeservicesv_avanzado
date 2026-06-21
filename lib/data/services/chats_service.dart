/// chats_service.dart
/// Servicio para operaciones sobre la tabla `chats`.
///
/// Regla: Un solo chat por solicitud. Se crea al confirmar el servicio.
/// Los mensajes se configuran para eliminarse 7 días post-finalización.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatsService {
  final SupabaseClient _client;
  static const _table = 'chats';

  ChatsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Obtiene el chat de una solicitud, o lo crea si no existe.
  Future<ChatModel> getOCrear({
    required String solicitudId,
    required String clienteId,
    required String trabajadorId,
  }) async {
    // Intentar obtener chat existente
    final existing = await _client
        .from(_table)
        .select()
        .eq('solicitud_id', solicitudId)
        .maybeSingle();

    if (existing != null) {
      return ChatModel.fromMap(existing);
    }

    // Crear nuevo chat
    final data = await _client.from(_table).insert({
      'solicitud_id': solicitudId,
      'cliente_id': clienteId,
      'trabajador_id': trabajadorId,
    }).select().single();

    return ChatModel.fromMap(data);
  }

  /// Obtiene el chat asociado a una solicitud.
  Future<ChatModel?> getBySolicitud(String solicitudId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('solicitud_id', solicitudId)
        .maybeSingle();
    return data != null ? ChatModel.fromMap(data) : null;
  }

  /// Obtiene un chat por su ID.
  Future<ChatModel?> getById(String chatId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id', chatId)
        .maybeSingle();
    return data != null ? ChatModel.fromMap(data) : null;
  }

  /// Obtiene todos los chats de un usuario (cliente o trabajador).
  Future<List<ChatModel>> getMisChats(String userId) async {
    // OR en postGREST: buscar como cliente O como trabajador
    final data = await _client
        .from(_table)
        .select()
        .or('cliente_id.eq.$userId,trabajador_id.eq.$userId')
        .order('creado_en', ascending: false);
    return (data as List)
        .map((e) => ChatModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Marca la fecha de expiración de mensajes (7 días desde ahora).
  /// Se llama cuando el servicio se marca como completado.
  Future<void> programarEliminacion(String chatId) async {
    final expiracion = DateTime.now().add(const Duration(days: 7));
    await _client
        .from(_table)
        .update({'eliminar_mensajes_en': expiracion.toIso8601String()})
        .eq('id', chatId);
  }
}
