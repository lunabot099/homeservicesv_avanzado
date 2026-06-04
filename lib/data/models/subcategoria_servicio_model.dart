/// subcategoria_servicio_model.dart
/// Modelo de la tabla `subcategorias_servicio`.
/// Cada subcategoría pertenece a una categoría principal.
library;

class SubcategoriaServicioModel {
  final String id;
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final int orden;

  const SubcategoriaServicioModel({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    this.orden = 0,
  });

  factory SubcategoriaServicioModel.fromMap(Map<String, dynamic> map) {
    return SubcategoriaServicioModel(
      id: map['id'] as String,
      categoriaId: map['categoria_id'] as String,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String?,
      activo: map['activo'] as bool? ?? true,
      orden: map['orden'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoria_id': categoriaId,
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        'activo': activo,
        'orden': orden,
      };

  @override
  String toString() =>
      'SubcategoriaServicioModel(id: $id, categoriaId: $categoriaId, nombre: $nombre)';
}

/// Mock por categoría para usar mientras no exista la tabla en Supabase.
class SubcategoriasMock {
  static const Map<String, List<Map<String, dynamic>>> _data = {
    'fontaneria': [
      {'id': 'font_1', 'nombre': 'Reparar fuga', 'orden': 1},
      {'id': 'font_2', 'nombre': 'Destapar tubería', 'orden': 2},
      {'id': 'font_3', 'nombre': 'Instalar lavamanos', 'orden': 3},
      {'id': 'font_4', 'nombre': 'Reparación de inodoro', 'orden': 4},
      {'id': 'font_5', 'nombre': 'Instalación general', 'orden': 5},
      {'id': 'font_6', 'nombre': 'Otro', 'orden': 6},
    ],
    'albanileria': [
      {'id': 'alba_1', 'nombre': 'Reparar pared', 'orden': 1},
      {'id': 'alba_2', 'nombre': 'Levantar pared', 'orden': 2},
      {'id': 'alba_3', 'nombre': 'Reparar techo', 'orden': 3},
      {'id': 'alba_4', 'nombre': 'Otro', 'orden': 4},
    ],
    'carpinteria': [
      {'id': 'carp_1', 'nombre': 'Reparar mueble', 'orden': 1},
      {'id': 'carp_2', 'nombre': 'Mueble a medida', 'orden': 2},
      {'id': 'carp_3', 'nombre': 'Instalar puerta', 'orden': 3},
      {'id': 'carp_4', 'nombre': 'Ajustes', 'orden': 4},
      {'id': 'carp_5', 'nombre': 'Otro', 'orden': 5},
    ],
    'electricidad': [
      {'id': 'elec_1', 'nombre': 'Instalación eléctrica', 'orden': 1},
      {'id': 'elec_2', 'nombre': 'Reparar tomacorriente', 'orden': 2},
      {'id': 'elec_3', 'nombre': 'Instalar lámpara', 'orden': 3},
      {'id': 'elec_4', 'nombre': 'Revisión del panel', 'orden': 4},
      {'id': 'elec_5', 'nombre': 'Otro', 'orden': 5},
    ],
    'ceramica': [
      {'id': 'cer_1', 'nombre': 'Instalar cerámica', 'orden': 1},
      {'id': 'cer_2', 'nombre': 'Reparar cerámica', 'orden': 2},
      {'id': 'cer_3', 'nombre': 'Pulir piso', 'orden': 3},
      {'id': 'cer_4', 'nombre': 'Otro', 'orden': 4},
    ],
    'cielo_falso': [
      {'id': 'ciel_1', 'nombre': 'Instalar cielo falso', 'orden': 1},
      {'id': 'ciel_2', 'nombre': 'Reparar cielo falso', 'orden': 2},
      {'id': 'ciel_3', 'nombre': 'Otro', 'orden': 3},
    ],
    'pintura': [
      {'id': 'pint_1', 'nombre': 'Pintar habitación', 'orden': 1},
      {'id': 'pint_2', 'nombre': 'Pintar fachada', 'orden': 2},
      {'id': 'pint_3', 'nombre': 'Pintar muebles', 'orden': 3},
      {'id': 'pint_4', 'nombre': 'Otro', 'orden': 4},
    ],
    'soldadura': [
      {'id': 'sold_1', 'nombre': 'Portón o verja', 'orden': 1},
      {'id': 'sold_2', 'nombre': 'Escalera metálica', 'orden': 2},
      {'id': 'sold_3', 'nombre': 'Reparación de estructura', 'orden': 3},
      {'id': 'sold_4', 'nombre': 'Otro', 'orden': 4},
    ],
    'mecanica': [
      {'id': 'mec_1', 'nombre': 'Cambio de aceite', 'orden': 1},
      {'id': 'mec_2', 'nombre': 'Revisión general', 'orden': 2},
      {'id': 'mec_3', 'nombre': 'Reparación de frenos', 'orden': 3},
      {'id': 'mec_4', 'nombre': 'Otro', 'orden': 4},
    ],
  };

  static List<SubcategoriaServicioModel> getByCategoria(String categoriaId) {
    final raw = _data[categoriaId] ?? [{'id': 'otro', 'nombre': 'Otro', 'orden': 1}];
    return raw
        .map((e) => SubcategoriaServicioModel.fromMap({
              ...e,
              'categoria_id': categoriaId,
            }))
        .toList();
  }
}
