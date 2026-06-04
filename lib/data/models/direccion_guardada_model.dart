/// direccion_guardada_model.dart
/// Modelo de la tabla `direcciones_guardadas`.
/// Direcciones que un cliente guarda para reutilizar en solicitudes.
library;

class DireccionGuardadaModel {
  final String? id;
  final String clienteId;
  final String alias; // 'Casa', 'Trabajo', 'Mamá', etc.
  final String departamento;
  final String municipio;
  final String? colonia;
  final String? calle;
  final String? numeroCasa;
  final String? puntoReferencia;
  final double? latitud;
  final double? longitud;
  final bool esPrincipal;
  final DateTime? fechaCreacion;

  const DireccionGuardadaModel({
    this.id,
    required this.clienteId,
    required this.alias,
    required this.departamento,
    required this.municipio,
    this.colonia,
    this.calle,
    this.numeroCasa,
    this.puntoReferencia,
    this.latitud,
    this.longitud,
    this.esPrincipal = false,
    this.fechaCreacion,
  });

  factory DireccionGuardadaModel.fromMap(Map<String, dynamic> map) {
    return DireccionGuardadaModel(
      id: map['id'] as String?,
      clienteId: map['cliente_id'] as String,
      alias: map['alias'] as String? ?? 'Casa',
      departamento: map['departamento'] as String? ?? '',
      municipio: map['municipio'] as String? ?? '',
      colonia: map['colonia'] as String?,
      calle: map['calle'] as String?,
      numeroCasa: map['numero_casa'] as String?,
      puntoReferencia: map['punto_referencia'] as String?,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      esPrincipal: map['es_principal'] as bool? ?? false,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'cliente_id': clienteId,
        'alias': alias,
        'departamento': departamento,
        'municipio': municipio,
        if (colonia != null) 'colonia': colonia,
        if (calle != null) 'calle': calle,
        if (numeroCasa != null) 'numero_casa': numeroCasa,
        if (puntoReferencia != null) 'punto_referencia': puntoReferencia,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
        'es_principal': esPrincipal,
      };

  /// Dirección legible para mostrar en UI.
  String get displayAddress {
    final parts = [
      if (calle != null) calle,
      if (colonia != null) colonia,
      municipio,
      departamento,
    ];
    return parts.join(', ');
  }

  @override
  String toString() =>
      'DireccionGuardadaModel(id: $id, alias: $alias, dir: $displayAddress)';
}
