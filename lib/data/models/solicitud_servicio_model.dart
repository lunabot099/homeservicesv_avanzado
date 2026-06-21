/// solicitud_servicio_model.dart
/// Modelo de la tabla `solicitudes_servicio`.
/// Representa una solicitud de trabajo creada por un cliente.
library;

import 'dart:typed_data';

/// Urgencia de la solicitud.
enum UrgenciaSolicitud {
  urgente,
  hoy,
  manana,
  esta_semana,
  flexible;

  String get label {
    switch (this) {
      case UrgenciaSolicitud.urgente:
        return 'Urgente';
      case UrgenciaSolicitud.hoy:
        return 'Hoy';
      case UrgenciaSolicitud.manana:
        return 'Mañana';
      case UrgenciaSolicitud.esta_semana:
        return 'Esta semana';
      case UrgenciaSolicitud.flexible:
        return 'Flexible';
    }
  }

  static UrgenciaSolicitud fromString(String v) => UrgenciaSolicitud.values
      .firstWhere((e) => e.name == v, orElse: () => UrgenciaSolicitud.flexible);
}

/// Tipo de pago preferido.
enum TipoPago {
  por_dia,
  por_obra,
  a_convenir;

  String get label {
    switch (this) {
      case TipoPago.por_dia:
        return 'Por día';
      case TipoPago.por_obra:
        return 'Por obra';
      case TipoPago.a_convenir:
        return 'A convenir';
    }
  }

  static TipoPago fromString(String v) => TipoPago.values
      .firstWhere((e) => e.name == v, orElse: () => TipoPago.a_convenir);
}

/// Estado de la solicitud durante su ciclo de vida.
enum EstadoSolicitud {
  // ignore: constant_identifier_names
  en_busqueda,
  postulaciones_recibidas,
  confirmada,
  en_camino,
  ha_llegado,
  en_proceso,
  finalizado_pendiente,
  completada,
  cancelada,
  // ignore: constant_identifier_names
  expirada;

  String get label {
    switch (this) {
      case EstadoSolicitud.en_busqueda:
        return 'Buscando trabajador';
      case EstadoSolicitud.postulaciones_recibidas:
        return 'Trabajadores interesados';
      case EstadoSolicitud.confirmada:
        return 'Confirmada';
      case EstadoSolicitud.en_camino:
        return 'En camino';
      case EstadoSolicitud.ha_llegado:
        return 'Ha llegado';
      case EstadoSolicitud.en_proceso:
        return 'Trabajo en proceso';
      case EstadoSolicitud.finalizado_pendiente:
        return 'Finalizado — pendiente confirmación';
      case EstadoSolicitud.completada:
        return 'Completada';
      case EstadoSolicitud.cancelada:
        return 'Cancelada';
      case EstadoSolicitud.expirada:
        return 'Expirada';
    }
  }

  static EstadoSolicitud fromString(String v) =>
      EstadoSolicitud.values.firstWhere((e) => e.name == v,
          orElse: () => EstadoSolicitud.en_busqueda);
}

class SolicitudServicioModel {
  final String? id;
  final String clienteId;
  final String? trabajadorId;
  final String categoriaId;
  final String? subcategoriaId;
  final String descripcion;
  final List<String> imagenesUrls;
  final List<Uint8List> imagenesPendientesBytes;
  final UrgenciaSolicitud urgencia;
  final TipoPago tipoPago;
  final double? presupuestoEstimado;
  final String? horarioPreferido;
  // Ubicación
  final String? departamento;
  final String? municipio;
  final String? colonia;
  final String? calle;
  final String? numeroCasa;
  final String? puntoReferencia;
  final double? latitud;
  final double? longitud;
  // Estado
  final EstadoSolicitud estado;
  final double? montoAcordado;
  final DateTime? fechaServicio;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const SolicitudServicioModel({
    this.id,
    required this.clienteId,
    this.trabajadorId,
    required this.categoriaId,
    this.subcategoriaId,
    required this.descripcion,
    this.imagenesUrls = const [],
    this.imagenesPendientesBytes = const [],
    this.urgencia = UrgenciaSolicitud.flexible,
    this.tipoPago = TipoPago.a_convenir,
    this.presupuestoEstimado,
    this.horarioPreferido,
    this.departamento,
    this.municipio,
    this.colonia,
    this.calle,
    this.numeroCasa,
    this.puntoReferencia,
    this.latitud,
    this.longitud,
    this.estado = EstadoSolicitud.en_busqueda,
    this.montoAcordado,
    this.fechaServicio,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory SolicitudServicioModel.fromMap(Map<String, dynamic> map) {
    return SolicitudServicioModel(
      id: map['id'] as String?,
      clienteId: map['cliente_id'] as String,
      trabajadorId: map['trabajador_seleccionado_id'] as String?,
      categoriaId: map['categoria'] as String,
      subcategoriaId: map['subcategoria'] as String?,
      descripcion: map['descripcion'] as String? ?? '',
      imagenesUrls: _parseStringList(map['imagenes_urls']),
      urgencia: UrgenciaSolicitud.fromString(
          map['urgencia'] as String? ?? 'flexible'),
      tipoPago:
          TipoPago.fromString(map['tipo_pago'] as String? ?? 'a_convenir'),
      presupuestoEstimado: (map['presupuesto_estimado'] as num?)?.toDouble(),
      horarioPreferido: map['horario_preferido'] as String?,
      departamento: map['departamento'] as String?,
      municipio: map['municipio'] as String?,
      colonia: map['colonia'] as String?,
      calle: map['calle'] as String?,
      numeroCasa: map['casa'] as String?,
      puntoReferencia: map['punto_referencia'] as String?,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      estado:
          EstadoSolicitud.fromString(map['estado'] as String? ?? 'buscando'),
      montoAcordado: (map['monto_acordado'] as num?)?.toDouble(),
      fechaServicio: map['fecha_servicio'] != null
          ? DateTime.tryParse(map['fecha_servicio'] as String)
          : null,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'cliente_id': clienteId,
        if (trabajadorId != null) 'trabajador_seleccionado_id': trabajadorId,
        'categoria': categoriaId,
        if (subcategoriaId != null) 'subcategoria': subcategoriaId,
        'descripcion': descripcion,
        if (imagenesUrls.isNotEmpty) 'imagenes_urls': imagenesUrls,
        'urgencia': urgencia.name,
        'tipo_pago': tipoPago.name,
        if (presupuestoEstimado != null)
          'presupuesto_estimado': presupuestoEstimado,
        if (horarioPreferido != null) 'horario_preferido': horarioPreferido,
        if (departamento != null) 'departamento': departamento,
        if (municipio != null) 'municipio': municipio,
        if (colonia != null) 'colonia': colonia,
        if (calle != null) 'calle': calle,
        if (numeroCasa != null) 'casa': numeroCasa,
        if (puntoReferencia != null) 'punto_referencia': puntoReferencia,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
        'estado': estado.name,
      };

  SolicitudServicioModel copyWith({
    String? id,
    String? clienteId,
    String? trabajadorId,
    String? categoriaId,
    String? subcategoriaId,
    String? descripcion,
    List<String>? imagenesUrls,
    List<Uint8List>? imagenesPendientesBytes,
    UrgenciaSolicitud? urgencia,
    TipoPago? tipoPago,
    double? presupuestoEstimado,
    String? horarioPreferido,
    String? departamento,
    String? municipio,
    String? colonia,
    String? calle,
    String? numeroCasa,
    String? puntoReferencia,
    double? latitud,
    double? longitud,
    EstadoSolicitud? estado,
    double? montoAcordado,
    DateTime? fechaServicio,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) =>
      SolicitudServicioModel(
        id: id ?? this.id,
        clienteId: clienteId ?? this.clienteId,
        trabajadorId: trabajadorId ?? this.trabajadorId,
        categoriaId: categoriaId ?? this.categoriaId,
        subcategoriaId: subcategoriaId ?? this.subcategoriaId,
        descripcion: descripcion ?? this.descripcion,
        imagenesUrls: imagenesUrls ?? this.imagenesUrls,
        imagenesPendientesBytes:
            imagenesPendientesBytes ?? this.imagenesPendientesBytes,
        urgencia: urgencia ?? this.urgencia,
        tipoPago: tipoPago ?? this.tipoPago,
        presupuestoEstimado: presupuestoEstimado ?? this.presupuestoEstimado,
        horarioPreferido: horarioPreferido ?? this.horarioPreferido,
        departamento: departamento ?? this.departamento,
        municipio: municipio ?? this.municipio,
        colonia: colonia ?? this.colonia,
        calle: calle ?? this.calle,
        numeroCasa: numeroCasa ?? this.numeroCasa,
        puntoReferencia: puntoReferencia ?? this.puntoReferencia,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
        estado: estado ?? this.estado,
        montoAcordado: montoAcordado ?? this.montoAcordado,
        fechaServicio: fechaServicio ?? this.fechaServicio,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      );

  @override
  String toString() =>
      'SolicitudServicioModel(id: $id, categoria: $categoriaId, estado: ${estado.name})';
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().where((e) => e.isNotEmpty).toList();
  }
  return const [];
}
