/// formulario_repository.dart
/// Repositorio del formulario de aplicación de trabajadores.
/// Abstracción entre ViewModels y FormularioService.
library;

import '../models/formulario_trabajador_model.dart';
import '../services/formulario_service.dart';

class FormularioRepository {
  final FormularioService _service;

  FormularioRepository({FormularioService? service})
      : _service = service ?? FormularioService();

  /// Envía el formulario de aplicación de un trabajador.
  Future<FormularioTrabajadorModel> submitFormulario(
    FormularioTrabajadorModel formulario,
  ) async {
    try {
      return await _service.submitFormulario(formulario);
    } catch (e) {
      throw Exception('No se pudo enviar el formulario: ${e.toString()}');
    }
  }

  /// Consulta el estado de un formulario por correo.
  Future<FormularioTrabajadorModel?> getFormularioByCorreo(String correo) async {
    try {
      return await _service.getFormularioByCorreo(correo);
    } catch (e) {
      throw Exception('No se pudo consultar el formulario: ${e.toString()}');
    }
  }

  /// Obtiene un formulario por ID.
  Future<FormularioTrabajadorModel?> getFormularioById(String id) async {
    try {
      return await _service.getFormularioById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el formulario: ${e.toString()}');
    }
  }
}
