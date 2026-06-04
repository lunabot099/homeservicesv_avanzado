/// formulario_trabajador_model.dart
/// Modelo correspondiente a la tabla `formulario_trabajador` en Supabase.
/// Usado para el proceso de aplicación / onboarding de trabajadores.
library;

/// Enum para el estado del formulario de trabajador.
enum EstadoFormulario {
  pendiente,
  aprobado,
  rechazado,
  en_revision;

  static EstadoFormulario fromString(String value) {
    return EstadoFormulario.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoFormulario.pendiente,
    );
  }
}

/// Modelo del formulario de aplicación de trabajador.
/// Mapea 1:1 con la tabla `formulario_trabajador` de Supabase.
class FormularioTrabajadorModel {
  final String? id;
  final String nombreCompleto;
  final String correo;
  final String celular;
  final String dui;
  final String? direccion;
  final String? fotoPerfilUrl;
  final String? fotoDuiUrl;
  final String? antecedentespenalesUrl;
  final EstadoFormulario estado;
  final String? notasAdmin;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const FormularioTrabajadorModel({
    this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.celular,
    required this.dui,
    this.direccion,
    this.fotoPerfilUrl,
    this.fotoDuiUrl,
    this.antecedentespenalesUrl,
    this.estado = EstadoFormulario.pendiente,
    this.notasAdmin,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  /// Crea un [FormularioTrabajadorModel] desde un mapa de Supabase.
  factory FormularioTrabajadorModel.fromMap(Map<String, dynamic> map) {
    return FormularioTrabajadorModel(
      id: map['id'] as String?,
      nombreCompleto: map['nombre_completo'] as String? ?? '',
      correo: map['correo'] as String? ?? '',
      celular: map['celular'] as String? ?? '',
      dui: map['dui'] as String? ?? '',
      direccion: map['direccion'] as String?,
      fotoPerfilUrl: map['foto_perfil_url'] as String?,
      fotoDuiUrl: map['foto_dui_url'] as String?,
      antecedentespenalesUrl: map['antecedentes_penales_url'] as String?,
      estado: EstadoFormulario.fromString(
        map['estado'] as String? ?? 'pendiente',
      ),
      notasAdmin: map['notas_admin'] as String?,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String)
          : null,
    );
  }

  /// Convierte el modelo a mapa para insertar en Supabase.
  Map<String, dynamic> toMap() {
    return {
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'celular': celular,
      'dui': dui,
      if (direccion != null) 'direccion': direccion,
      if (fotoPerfilUrl != null) 'foto_perfil_url': fotoPerfilUrl,
      if (fotoDuiUrl != null) 'foto_dui_url': fotoDuiUrl,
      if (antecedentespenalesUrl != null)
        'antecedentes_penales_url': antecedentespenalesUrl,
      'estado': estado.name,
      if (notasAdmin != null) 'notas_admin': notasAdmin,
    };
  }

  /// Retorna una copia con los campos modificados.
  FormularioTrabajadorModel copyWith({
    String? id,
    String? nombreCompleto,
    String? correo,
    String? celular,
    String? dui,
    String? direccion,
    String? fotoPerfilUrl,
    String? fotoDuiUrl,
    String? antecedentespenalesUrl,
    EstadoFormulario? estado,
    String? notasAdmin,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return FormularioTrabajadorModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      celular: celular ?? this.celular,
      dui: dui ?? this.dui,
      direccion: direccion ?? this.direccion,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      fotoDuiUrl: fotoDuiUrl ?? this.fotoDuiUrl,
      antecedentespenalesUrl: antecedentespenalesUrl ?? this.antecedentespenalesUrl,
      estado: estado ?? this.estado,
      notasAdmin: notasAdmin ?? this.notasAdmin,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() =>
      'FormularioTrabajadorModel(id: $id, nombre: $nombreCompleto, estado: ${estado.name})';
}
