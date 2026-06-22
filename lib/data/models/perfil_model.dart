/// perfil_model.dart
/// Modelo correspondiente a la tabla `perfiles` en Supabase.
/// La tabla `perfiles` extiende a `auth.users` usando el mismo `id`.
library;

/// Enum para los roles de usuario de la app.
enum UserRole {
  cliente,
  trabajador,
  admin;

  /// Convierte el string de la BD al enum correspondiente.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.cliente,
    );
  }
}

/// Modelo de perfil de usuario.
/// Mapea 1:1 con la tabla `perfiles` de Supabase.
class PerfilModel {
  final String id;
  final String nombreCompleto;
  final String correo;
  final String? telefono;
  final UserRole rol;
  final String? fotoPerfilUrl;
  final double? promedioCalificacion;
  final int? cantidadResenas;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const PerfilModel({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    this.telefono,
    required this.rol,
    this.fotoPerfilUrl,
    this.promedioCalificacion,
    this.cantidadResenas,
    this.activo = true,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  /// Crea un [PerfilModel] desde un mapa de Supabase.
  factory PerfilModel.fromMap(Map<String, dynamic> map) {
    final nombre = map['nombre_completo'] ?? map['nombre'];

    return PerfilModel(
      id: map['id'] as String,
      nombreCompleto: nombre as String? ?? '',
      correo: map['correo'] as String? ?? '',
      telefono: map['telefono'] as String?,
      rol: UserRole.fromString(map['rol'] as String? ?? 'cliente'),
      fotoPerfilUrl: map['foto_perfil_url'] as String?,
      promedioCalificacion: (map['promedio_calificacion'] as num?)?.toDouble(),
      cantidadResenas: map['cantidad_resenas'] as int?,
      activo: map['activo'] as bool? ?? true,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String)
          : null,
    );
  }

  /// Convierte el modelo a un mapa para insertar/actualizar en Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombreCompleto,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      if (telefono != null) 'telefono': telefono,
      'rol': rol.name,
      if (fotoPerfilUrl != null) 'foto_perfil_url': fotoPerfilUrl,
      if (promedioCalificacion != null)
        'promedio_calificacion': promedioCalificacion,
      if (cantidadResenas != null) 'cantidad_resenas': cantidadResenas,
      'activo': activo,
    };
  }

  /// Retorna una copia del perfil con los campos modificados.
  PerfilModel copyWith({
    String? id,
    String? nombreCompleto,
    String? correo,
    String? telefono,
    UserRole? rol,
    String? fotoPerfilUrl,
    double? promedioCalificacion,
    int? cantidadResenas,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return PerfilModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      promedioCalificacion: promedioCalificacion ?? this.promedioCalificacion,
      cantidadResenas: cantidadResenas ?? this.cantidadResenas,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() =>
      'PerfilModel(id: $id, nombre: $nombreCompleto, rol: ${rol.name})';
}
