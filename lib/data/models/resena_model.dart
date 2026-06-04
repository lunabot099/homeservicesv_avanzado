/// resena_model.dart
/// Modelo de la tabla `resenas`.
/// Soporta calificaciones en ambas direcciones:
/// - cliente → trabajador (TipoResena.clienteATrabajador)
/// - trabajador → cliente (TipoResena.trabajadorACliente)
library;

/// Dirección de la calificación.
enum TipoResena {
  clienteATrabajador,
  trabajadorACliente;

  static TipoResena fromString(String v) => v == 'trabajador_a_cliente'
      ? TipoResena.trabajadorACliente
      : TipoResena.clienteATrabajador;

  String get dbValue =>
      this == TipoResena.trabajadorACliente ? 'trabajador_a_cliente' : 'cliente_a_trabajador';
}

class ResenaModel {
  final String? id;
  final String solicitudId;
  final String clienteId;
  final String trabajadorId;
  /// Quien emite la reseña (clienteId o trabajadorId dependiendo del tipo)
  final String emisorId;
  final TipoResena tipo;
  final double calificacion; // 1.0 - 5.0
  final String? comentario;
  final List<String>? preguntasRapidas;
  final DateTime? fechaCreacion;

  const ResenaModel({
    this.id,
    required this.solicitudId,
    required this.clienteId,
    required this.trabajadorId,
    required this.emisorId,
    this.tipo = TipoResena.clienteATrabajador,
    required this.calificacion,
    this.comentario,
    this.preguntasRapidas,
    this.fechaCreacion,
  });

  factory ResenaModel.fromMap(Map<String, dynamic> map) {
    return ResenaModel(
      id: map['id'] as String?,
      solicitudId: map['solicitud_id'] as String,
      clienteId: map['cliente_id'] as String,
      trabajadorId: map['trabajador_id'] as String,
      emisorId: map['emisor_id'] as String? ?? map['cliente_id'] as String,
      tipo: TipoResena.fromString(map['tipo'] as String? ?? 'cliente_a_trabajador'),
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 5.0,
      comentario: map['comentario'] as String?,
      preguntasRapidas: (map['preguntas_rapidas'] as List?)?.cast<String>(),
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'solicitud_id': solicitudId,
        'cliente_id': clienteId,
        'trabajador_id': trabajadorId,
        'emisor_id': emisorId,
        'tipo': tipo.dbValue,
        'calificacion': calificacion,
        if (comentario != null) 'comentario': comentario,
        if (preguntasRapidas != null) 'preguntas_rapidas': preguntasRapidas,
      };

  @override
  String toString() =>
      'ResenaModel(id: $id, tipo: ${tipo.name}, calificacion: $calificacion)';
}
