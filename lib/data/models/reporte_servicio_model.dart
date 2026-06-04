/// reporte_servicio_model.dart
/// Modelo de la tabla `reportes_servicio`.
library;

enum MotivoReporte {
  no_se_presento,
  no_respondio,
  llego_tarde,
  cancelo,
  problema_servicio,
  otro;

  String get label {
    switch (this) {
      case MotivoReporte.no_se_presento: return 'El trabajador no se presentó';
      case MotivoReporte.no_respondio: return 'No respondió';
      case MotivoReporte.llego_tarde: return 'Llegó tarde';
      case MotivoReporte.cancelo: return 'Canceló';
      case MotivoReporte.problema_servicio: return 'Problema con el servicio';
      case MotivoReporte.otro: return 'Otro';
    }
  }

  static MotivoReporte fromString(String v) => MotivoReporte.values
      .firstWhere((e) => e.name == v, orElse: () => MotivoReporte.otro);
}

class ReporteServicioModel {
  final String? id;
  final String solicitudId;
  final String reportadoPorId;
  final MotivoReporte motivo;
  final String? descripcion;
  final DateTime? fechaCreacion;

  const ReporteServicioModel({
    this.id,
    required this.solicitudId,
    required this.reportadoPorId,
    required this.motivo,
    this.descripcion,
    this.fechaCreacion,
  });

  factory ReporteServicioModel.fromMap(Map<String, dynamic> map) {
    return ReporteServicioModel(
      id: map['id'] as String?,
      solicitudId: map['solicitud_id'] as String,
      reportadoPorId: map['reportado_por_id'] as String,
      motivo: MotivoReporte.fromString(map['motivo'] as String? ?? 'otro'),
      descripcion: map['descripcion'] as String?,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'solicitud_id': solicitudId,
        'reportado_por_id': reportadoPorId,
        'motivo': motivo.name,
        if (descripcion != null) 'descripcion': descripcion,
      };
}
