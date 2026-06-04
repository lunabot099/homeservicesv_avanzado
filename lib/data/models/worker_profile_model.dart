/// worker_profile_model.dart
/// Modelo correspondiente a la tabla `worker_profiles` en Supabase.
/// Extiende `perfiles` usando el mismo `id`.
library;

/// Enum para el estado de verificación del trabajador.
enum EstadoVerificacion {
  pendiente,
  aprobado,
  rechazado;

  static EstadoVerificacion fromString(String value) {
    return EstadoVerificacion.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoVerificacion.pendiente,
    );
  }
}

/// Modelo del perfil extendido de trabajador.
/// Mapea 1:1 con la tabla `worker_profiles` de Supabase.
///
/// Campos nuevos (fase perfil v2):
///   - `especialidades`  → text[]  — lista de especialidades seleccionadas
///   - `latitud`         → double  — centro de zona de cobertura
///   - `longitud`        → double  — centro de zona de cobertura
///   - `radioKm`         → int     — radio fijo de 6 km
///
/// Campos legacy mantenidos por compatibilidad:
///   - `oficio_principal` — no se muestra en UI nueva pero se preserva en BD
///   - `zona_cobertura`   — no se muestra en UI nueva pero se preserva en BD
class WorkerProfileModel {
  final String id;
  final String? dui;
  final EstadoVerificacion estadoVerificacion;
  final String? experiencia;
  final double? tarifa;
  final bool disponibilidad;
  final String? descripcion;
  final bool verificado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  // ── Campos de especialidades (fase v2) ─────────────────────────
  /// Lista de especialidades seleccionadas por el trabajador.
  final List<String> especialidades;

  // ── Campos de cobertura geográfica (fase v2) ────────────────────
  /// Latitud del centro de la zona de cobertura.
  final double? latitud;

  /// Longitud del centro de la zona de cobertura.
  final double? longitud;

  /// Radio de cobertura en kilómetros. Fijo en 6 por ahora.
  final int radioKm;

  // ── Campos legacy — conservados para compatibilidad ─────────────
  /// Oficio principal (legacy — reemplazado por `especialidades`).
  final String? oficioPrincipal;

  /// Zona de cobertura textual (legacy — reemplazada por lat/lng/radio).
  final String? zonaCobertura;

  const WorkerProfileModel({
    required this.id,
    this.dui,
    this.estadoVerificacion = EstadoVerificacion.pendiente,
    this.experiencia,
    this.tarifa,
    this.disponibilidad = false,
    this.descripcion,
    this.verificado = false,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.especialidades = const [],
    this.latitud,
    this.longitud,
    this.radioKm = 6,
    // legacy
    this.oficioPrincipal,
    this.zonaCobertura,
  });

  /// Crea un [WorkerProfileModel] desde un mapa de Supabase.
  factory WorkerProfileModel.fromMap(Map<String, dynamic> map) {
    // Especialidades: puede venir como List<dynamic> o null
    final rawEsp = map['especialidades'];
    final especialidades = rawEsp != null
        ? List<String>.from(rawEsp as List)
        : <String>[];

    return WorkerProfileModel(
      id: map['id'] as String,
      dui: map['dui'] as String?,
      estadoVerificacion: EstadoVerificacion.fromString(
        map['estado_verificacion'] as String? ?? 'pendiente',
      ),
      experiencia: map['experiencia'] as String?,
      tarifa: (map['tarifa'] as num?)?.toDouble(),
      disponibilidad: map['disponibilidad'] as bool? ?? false,
      descripcion: map['descripcion'] as String?,
      verificado: map['verificado'] as bool? ?? false,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String)
          : null,
      // v2 — especialidades y geolocalización
      especialidades: especialidades,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      radioKm: (map['radio_km'] as int?) ?? 6,
      // legacy
      oficioPrincipal: map['oficio_principal'] as String?,
      zonaCobertura: map['zona_cobertura'] as String?,
    );
  }

  /// Convierte el modelo a mapa para insertar/actualizar en Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (dui != null) 'dui': dui,
      'estado_verificacion': estadoVerificacion.name,
      if (experiencia != null) 'experiencia': experiencia,
      if (tarifa != null) 'tarifa': tarifa,
      'disponibilidad': disponibilidad,
      if (descripcion != null) 'descripcion': descripcion,
      'verificado': verificado,
      // v2 — especialidades
      'especialidades': especialidades,
      // v2 — cobertura geográfica
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      'radio_km': radioKm,
      // legacy — se preservan si existen
      if (oficioPrincipal != null) 'oficio_principal': oficioPrincipal,
      if (zonaCobertura != null) 'zona_cobertura': zonaCobertura,
    };
  }

  /// Retorna una copia con los campos modificados.
  WorkerProfileModel copyWith({
    String? id,
    String? dui,
    EstadoVerificacion? estadoVerificacion,
    String? experiencia,
    double? tarifa,
    bool? disponibilidad,
    String? descripcion,
    bool? verificado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<String>? especialidades,
    double? latitud,
    double? longitud,
    int? radioKm,
    String? oficioPrincipal,
    String? zonaCobertura,
  }) {
    return WorkerProfileModel(
      id: id ?? this.id,
      dui: dui ?? this.dui,
      estadoVerificacion: estadoVerificacion ?? this.estadoVerificacion,
      experiencia: experiencia ?? this.experiencia,
      tarifa: tarifa ?? this.tarifa,
      disponibilidad: disponibilidad ?? this.disponibilidad,
      descripcion: descripcion ?? this.descripcion,
      verificado: verificado ?? this.verificado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      especialidades: especialidades ?? this.especialidades,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      radioKm: radioKm ?? this.radioKm,
      oficioPrincipal: oficioPrincipal ?? this.oficioPrincipal,
      zonaCobertura: zonaCobertura ?? this.zonaCobertura,
    );
  }

  @override
  String toString() =>
      'WorkerProfileModel(id: $id, especialidades: $especialidades, verificado: $verificado)';
}
