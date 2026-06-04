/// mensaje_chat_model.dart
/// Modelo de la tabla `mensajes_chat`.
///
/// Diseño ligero — guarda solo lo esencial:
/// - texto del mensaje
/// - hora (timestamp)
/// - remitente (user id)
/// - referencia de archivo (url en storage si aplica)
///
/// Las imágenes van a Supabase Storage, aquí solo se guarda la URL.
/// El campo `tipo` permite distinguir texto / imagen / mensaje de sistema.
/// El campo `leido` facilita indicadores de lectura sin complejidad extra.
library;

/// Tipos de mensaje permitidos en el chat.
enum TipoMensaje {
  texto,
  imagen,
  sistema; // mensajes automáticos: "Servicio confirmado", "Trabajo finalizado", etc.

  static TipoMensaje fromString(String v) => TipoMensaje.values
      .firstWhere((e) => e.name == v, orElse: () => TipoMensaje.texto);
}

class MensajeChatModel {
  final String? id;
  final String chatId;
  final String remitenteId;
  final TipoMensaje tipo;
  /// Contenido de texto. Null para mensajes de imagen pura.
  final String? contenido;
  /// URL del archivo en Supabase Storage (solo si tipo == imagen).
  final String? archivoUrl;
  final bool leido;
  final DateTime? creadoEn;

  const MensajeChatModel({
    this.id,
    required this.chatId,
    required this.remitenteId,
    this.tipo = TipoMensaje.texto,
    this.contenido,
    this.archivoUrl,
    this.leido = false,
    this.creadoEn,
  });

  bool get esImagen => tipo == TipoMensaje.imagen;
  bool get esSistema => tipo == TipoMensaje.sistema;

  factory MensajeChatModel.fromMap(Map<String, dynamic> map) {
    return MensajeChatModel(
      id: map['id'] as String?,
      chatId: map['chat_id'] as String,
      // Columna real en Supabase: emisor_id
      remitenteId: map['emisor_id'] as String? ?? '',
      // Columna real: tipo_mensaje
      tipo: TipoMensaje.fromString(map['tipo_mensaje'] as String? ?? 'texto'),
      // Columna real: texto
      contenido: map['texto'] as String?,
      archivoUrl: map['archivo_url'] as String?,
      leido: map['leido'] as bool? ?? false,
      // Columna real: fecha_creacion
      creadoEn: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'chat_id': chatId,
        'emisor_id': remitenteId,        // columna real
        'tipo_mensaje': tipo.name,        // columna real
        if (contenido != null) 'texto': contenido,  // columna real
        if (archivoUrl != null) 'archivo_url': archivoUrl,
        'leido': leido,
      };

  /// Mensaje de sistema para eventos del ciclo de vida del servicio.
  factory MensajeChatModel.sistema({
    required String chatId,
    required String contenido,
  }) {
    return MensajeChatModel(
      chatId: chatId,
      remitenteId: 'system',
      tipo: TipoMensaje.sistema,
      contenido: contenido,
    );
  }

  @override
  String toString() =>
      'MensajeChatModel(id: $id, tipo: ${tipo.name}, remitente: $remitenteId)';
}
