/// habilidad_trabajador_model.dart
/// Modelo de la tabla `habilidades_trabajador`.
/// Permite que un trabajador declare múltiples habilidades específicas.
library;

class HabilidadTrabajadorModel {
  final String? id;
  final String trabajadorId;
  final String nombre;

  const HabilidadTrabajadorModel({
    this.id,
    required this.trabajadorId,
    required this.nombre,
  });

  factory HabilidadTrabajadorModel.fromMap(Map<String, dynamic> map) {
    return HabilidadTrabajadorModel(
      id: map['id'] as String?,
      trabajadorId: map['trabajador_id'] as String,
      nombre: map['nombre'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'trabajador_id': trabajadorId,
        'nombre': nombre,
      };

  @override
  String toString() =>
      'HabilidadTrabajadorModel(id: $id, nombre: $nombre)';
}
