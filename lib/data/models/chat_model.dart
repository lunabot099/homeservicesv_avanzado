/// chat_model.dart
/// Modelo de la tabla `chats`.
/// Cada chat está ligado a una solicitud de servicio específica.
///
/// Regla de negocio:
/// - Solo existe UN chat por solicitud
/// - Se crea cuando el trabajador es seleccionado y el servicio se confirma
/// - Los mensajes se eliminan automáticamente 7 días después de finalizado el trabajo
library;

class ChatModel {
  final String? id;
  final String solicitudId;
  final String clienteId;
  final String trabajadorId;
  final DateTime? creadoEn;
  /// Fecha en que se marcarán los mensajes para eliminación (solicitud.completada + 7 días)
  final DateTime? eliminarMensajesEn;

  // ── Campos de presentación (NO columnas de BD) ────────────────────────────
  /// Texto del último mensaje — se puebla desde un JOIN/RPC, no desde la tabla `chats`.
  final String? ultimoMensaje;
  /// Cantidad de mensajes no leídos — campo calculado, no almacenado.
  final int? mensajesNoLeidos;

  const ChatModel({
    this.id,
    required this.solicitudId,
    required this.clienteId,
    required this.trabajadorId,
    this.creadoEn,
    this.eliminarMensajesEn,
    // Presentación
    this.ultimoMensaje,
    this.mensajesNoLeidos,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String?,
      solicitudId: map['solicitud_id'] as String,
      clienteId: map['cliente_id'] as String,
      trabajadorId: map['trabajador_id'] as String,
      creadoEn: map['creado_en'] != null
          ? DateTime.tryParse(map['creado_en'] as String)
          : null,
      eliminarMensajesEn: map['eliminar_mensajes_en'] != null
          ? DateTime.tryParse(map['eliminar_mensajes_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'solicitud_id': solicitudId,
        'cliente_id': clienteId,
        'trabajador_id': trabajadorId,
        if (eliminarMensajesEn != null)
          'eliminar_mensajes_en': eliminarMensajesEn!.toIso8601String(),
        // ultimoMensaje y mensajesNoLeidos son de presentación — no se persisten
      };

  @override
  String toString() =>
      'ChatModel(id: $id, solicitudId: $solicitudId)';
}
