/// postulacion_solicitud_model.dart
/// Modelo de la tabla `postulaciones_solicitud`.
/// Un trabajador se postula a una solicitud de servicio de un cliente.
library;

enum EstadoPostulacion {
  pendiente,
  aceptada,
  rechazada,
  cancelada;

  static EstadoPostulacion fromString(String v) => EstadoPostulacion.values
      .firstWhere((e) => e.name == v, orElse: () => EstadoPostulacion.pendiente);
}

class PostulacionSolicitudModel {
  final String? id;
  final String solicitudId;
  final String trabajadorId;
  final double? precioEstimado;   // → 'precio_estimado' en DB
  final String? mensajeInicial;   // → 'mensaje_inicial' en DB
  final EstadoPostulacion estado;
  final DateTime? fechaCreacion;

  const PostulacionSolicitudModel({
    this.id,
    required this.solicitudId,
    required this.trabajadorId,
    this.precioEstimado,
    this.mensajeInicial,
    this.estado = EstadoPostulacion.pendiente,
    this.fechaCreacion,
  });

  factory PostulacionSolicitudModel.fromMap(Map<String, dynamic> map) {
    return PostulacionSolicitudModel(
      id: map['id'] as String?,
      solicitudId: map['solicitud_id'] as String,
      trabajadorId: map['trabajador_id'] as String,
      precioEstimado: (map['precio_estimado'] as num?)?.toDouble(),
      mensajeInicial: map['mensaje_inicial'] as String?,
      estado: EstadoPostulacion.fromString(map['estado'] as String? ?? 'pendiente'),
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
    );
  }

  /// Columnas reales de `postulaciones_solicitud`:
  /// solicitud_id, trabajador_id, mensaje_inicial, precio_estimado,
  /// estado, fecha_creacion, fecha_actualizacion
  Map<String, dynamic> toMap() => {
        'solicitud_id': solicitudId,
        'trabajador_id': trabajadorId,
        if (precioEstimado != null) 'precio_estimado': precioEstimado,
        if (mensajeInicial != null) 'mensaje_inicial': mensajeInicial,
        'estado': estado.name,
      };

  @override
  String toString() =>
      'PostulacionSolicitudModel(id: $id, solicitudId: $solicitudId, estado: ${estado.name})';
}

/// Worker con datos enriquecidos para mostrar en catálogo.
/// Combina datos de `perfiles` + `worker_profiles` + postulación.
class WorkerCatalogItemModel {
  final String trabajadorId;
  final String nombre;
  final String? fotoUrl;
  final String? especialidad;
  final double calificacion;
  final int cantidadResenas;
  final double? tarifa;
  final int? tiempoEstimadoLlegada;
  final double? distanciaKm;
  final bool verificado;
  final bool disponible;
  final bool destacado;
  // Datos de la postulación asociada (puede ser null si es mock)
  final PostulacionSolicitudModel? postulacion;

  const WorkerCatalogItemModel({
    required this.trabajadorId,
    required this.nombre,
    this.fotoUrl,
    this.especialidad,
    this.calificacion = 0,
    this.cantidadResenas = 0,
    this.tarifa,
    this.tiempoEstimadoLlegada,
    this.distanciaKm,
    this.verificado = false,
    this.disponible = true,
    this.destacado = false,
    this.postulacion,
  });

  /// Mock de trabajadores para desarrollo de UI sin datos reales.
  static List<WorkerCatalogItemModel> mockList(String categoriaId) {
    return [
      WorkerCatalogItemModel(
        trabajadorId: 'w1',
        nombre: 'Carlos Hernández',
        especialidad: categoriaId,
        calificacion: 4.8,
        cantidadResenas: 124,
        tarifa: 35.0,
        tiempoEstimadoLlegada: 20,
        distanciaKm: 1.2,
        verificado: true,
        destacado: true,
      ),
      WorkerCatalogItemModel(
        trabajadorId: 'w2',
        nombre: 'Miguel Ángel Ramos',
        especialidad: categoriaId,
        calificacion: 4.5,
        cantidadResenas: 87,
        tarifa: 28.0,
        tiempoEstimadoLlegada: 35,
        distanciaKm: 2.5,
        verificado: true,
      ),
      WorkerCatalogItemModel(
        trabajadorId: 'w3',
        nombre: 'José Luis Martínez',
        especialidad: categoriaId,
        calificacion: 4.2,
        cantidadResenas: 43,
        tarifa: 25.0,
        tiempoEstimadoLlegada: 45,
        distanciaKm: 3.8,
        verificado: false,
      ),
      WorkerCatalogItemModel(
        trabajadorId: 'w4',
        nombre: 'Roberto Fuentes',
        especialidad: categoriaId,
        calificacion: 4.9,
        cantidadResenas: 202,
        tarifa: 40.0,
        tiempoEstimadoLlegada: 15,
        distanciaKm: 0.8,
        verificado: true,
        destacado: true,
      ),
    ];
  }
}
