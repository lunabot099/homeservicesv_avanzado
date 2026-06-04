/// resenas_service.dart
/// Servicio de acceso a datos de `resenas` en Supabase.
/// Soporta calificaciones bidireccionales: cliente→trabajador y trabajador→cliente.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resena_model.dart';

class ResenasService {
  final SupabaseClient _client;
  static const _table = 'resenas';

  ResenasService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Crea una nueva reseña (cualquier dirección).
  Future<ResenaModel> createResena(ResenaModel resena) async {
    final data = await _client
        .from(_table)
        .insert(resena.toMap())
        .select()
        .single();
    return ResenaModel.fromMap(data);
  }

  /// Reseñas recibidas por un trabajador (de clientes).
  Future<List<ResenaModel>> getResenasByTrabajador(String trabajadorId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('trabajador_id', trabajadorId)
        .eq('tipo', TipoResena.clienteATrabajador.dbValue)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => ResenaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Reseñas emitidas por un cliente (de trabajadores).
  Future<List<ResenaModel>> getResenasByCliente(String clienteId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('cliente_id', clienteId)
        .eq('tipo', TipoResena.clienteATrabajador.dbValue)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => ResenaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Reseñas que el trabajador ha dejado a clientes.
  Future<List<ResenaModel>> getResenasDeTrabajadorAClientes(
      String trabajadorId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('trabajador_id', trabajadorId)
        .eq('tipo', TipoResena.trabajadorACliente.dbValue)
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => ResenaModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Verifica si ya existe una reseña para una solicitud y un tipo específico.
  Future<bool> yaCalificado({
    required String solicitudId,
    required String emisorId,
    required TipoResena tipo,
  }) async {
    final data = await _client
        .from(_table)
        .select('id')
        .eq('solicitud_id', solicitudId)
        .eq('emisor_id', emisorId)
        .eq('tipo', tipo.dbValue)
        .maybeSingle();
    return data != null;
  }
}
