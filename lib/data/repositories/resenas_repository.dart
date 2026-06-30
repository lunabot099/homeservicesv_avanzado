/// resenas_repository.dart
/// Repositorio de reseñas — extendido en Fase 3 con soporte bidireccional.
library;

import '../models/resena_model.dart';
import '../services/resenas_service.dart';
import 'solicitudes_repository.dart';

class ResenasRepository {
  final ResenasService _service;
  final SolicitudesRepository _solicitudesRepository;

  ResenasRepository({
    ResenasService? service,
    SolicitudesRepository? solicitudesRepository,
  })  : _service = service ?? ResenasService(),
        _solicitudesRepository =
            solicitudesRepository ?? SolicitudesRepository();

  Future<ResenaModel> createResena(ResenaModel resena) async {
    try {
      final solicitud =
          await _solicitudesRepository.getSolicitudById(resena.solicitudId);
      if (solicitud == null) {
        throw Exception(
          'No se encontró la solicitud real de este servicio. Vuelve al seguimiento e intenta calificar desde ahí.',
        );
      }

      if (solicitud.clienteId != resena.clienteId ||
          solicitud.trabajadorId != resena.trabajadorId) {
        throw Exception(
          'Los datos de la calificación no coinciden con el servicio confirmado.',
        );
      }

      // Verificar si ya calificó
      final yaExiste = await _service.yaCalificado(
        solicitudId: resena.solicitudId,
        emisorId: resena.emisorId,
        tipo: resena.tipo,
      );
      if (yaExiste) {
        throw Exception('Ya enviaste una reseña para este servicio.');
      }
      return await _service.createResena(resena);
    } catch (e) {
      throw Exception(
          'No se pudo guardar la reseña: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Reseñas recibidas por un trabajador.
  Future<List<ResenaModel>> getResenasByTrabajador(String trabajadorId) async {
    try {
      return await _service.getResenasByTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('No se pudieron obtener las reseñas: $e');
    }
  }

  /// Reseñas enviadas por un cliente.
  Future<List<ResenaModel>> getResenasByCliente(String clienteId) async {
    try {
      return await _service.getResenasByCliente(clienteId);
    } catch (e) {
      throw Exception('No se pudieron obtener tus reseñas: $e');
    }
  }

  /// Reseñas que el trabajador dejó a clientes.
  Future<List<ResenaModel>> getResenasDeTrabajadorAClientes(
      String trabajadorId) async {
    try {
      return await _service.getResenasDeTrabajadorAClientes(trabajadorId);
    } catch (e) {
      throw Exception('No se pudieron obtener las reseñas: $e');
    }
  }
}
