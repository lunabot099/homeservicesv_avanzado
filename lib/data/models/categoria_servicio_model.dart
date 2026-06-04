/// categoria_servicio_model.dart
/// Modelo de la tabla `categorias_servicio`.
/// Cada categoría agrupa un conjunto de subservicios (fontanería, electricidad, etc.)
library;

class CategoriaServicioModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;
  final String? iconoCodigo; // nombre del ícono Material (ej: 'plumbing')
  final bool activo;
  final int orden;

  const CategoriaServicioModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.iconoUrl,
    this.iconoCodigo,
    this.activo = true,
    this.orden = 0,
  });

  factory CategoriaServicioModel.fromMap(Map<String, dynamic> map) {
    return CategoriaServicioModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String?,
      iconoUrl: map['icono_url'] as String?,
      iconoCodigo: map['icono_codigo'] as String?,
      activo: map['activo'] as bool? ?? true,
      orden: map['orden'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        if (iconoUrl != null) 'icono_url': iconoUrl,
        if (iconoCodigo != null) 'icono_codigo': iconoCodigo,
        'activo': activo,
        'orden': orden,
      };

  @override
  String toString() => 'CategoriaServicioModel(id: $id, nombre: $nombre)';
}

/// Datos de categorías mock para usar mientras la tabla no exista en la BD.
/// Reemplazar por llamada real a Supabase cuando la tabla esté creada.
class CategoriasServicioMock {
  static const List<Map<String, dynamic>> data = [
    {'id': 'fontaneria', 'nombre': 'Fontanería', 'icono_codigo': 'plumbing', 'orden': 1},
    {'id': 'albanileria', 'nombre': 'Albañilería', 'icono_codigo': 'foundation', 'orden': 2},
    {'id': 'carpinteria', 'nombre': 'Carpintería', 'icono_codigo': 'carpenter', 'orden': 3},
    {'id': 'electricidad', 'nombre': 'Electricidad', 'icono_codigo': 'electrical_services', 'orden': 4},
    {'id': 'ceramica', 'nombre': 'Cerámica / Piso', 'icono_codigo': 'grid_view', 'orden': 5},
    {'id': 'cielo_falso', 'nombre': 'Cielo Falso', 'icono_codigo': 'roofing', 'orden': 6},
    {'id': 'pintura', 'nombre': 'Pintura', 'icono_codigo': 'format_paint', 'orden': 7},
    {'id': 'soldadura', 'nombre': 'Soldadura', 'icono_codigo': 'hardware', 'orden': 8},
    {'id': 'mecanica', 'nombre': 'Mecánica', 'icono_codigo': 'directions_car', 'orden': 9},
  ];

  static List<CategoriaServicioModel> get lista =>
      data.map((e) => CategoriaServicioModel.fromMap(e)).toList();
}
