/// formulario_service.dart
/// Servicio de acceso a datos de la tabla `formulario_trabajador` en Supabase.
/// Gestiona el envío y consulta del formulario de aplicación de trabajadores.
/// NO debe ser llamado directamente desde widgets — usar FormularioRepository.
library;

import '../models/formulario_trabajador_model.dart';
import 'supabase_client_service.dart';

class FormularioService {
  static const String _table = 'formulario_trabajador';

  final _client = SupabaseClientService.client;

  /// Envía un nuevo formulario de trabajador.
  Future<FormularioTrabajadorModel> submitFormulario(
    FormularioTrabajadorModel formulario,
  ) async {
    final data = await _client
        .from(_table)
        .insert(formulario.toMap())
        .select()
        .single();

    return FormularioTrabajadorModel.fromMap(data);
  }

  /// Obtiene el formulario de un trabajador por su correo.
  Future<FormularioTrabajadorModel?> getFormularioByCorreo(String correo) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('correo', correo)
        .maybeSingle();

    if (data == null) return null;
    return FormularioTrabajadorModel.fromMap(data);
  }

  /// Obtiene un formulario por su ID.
  Future<FormularioTrabajadorModel?> getFormularioById(String id) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return FormularioTrabajadorModel.fromMap(data);
  }
}
