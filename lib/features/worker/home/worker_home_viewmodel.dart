/// worker_home_viewmodel.dart
/// ViewModel de la pantalla principal del trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/perfil_model.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

class WorkerHomeViewModel extends ChangeNotifier {
  final SolicitudesRepository _solicitudesRepo;
  final SessionController _sessionController;

  List<SolicitudServicioModel> _solicitudesDisponibles = [];
  bool _disponible = true;
  bool _isLoading = false;
  String? _error;

  WorkerHomeViewModel({
    SolicitudesRepository? solicitudesRepo,
    required SessionController sessionController,
  })  : _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _sessionController = sessionController;

  PerfilModel? get perfil => _sessionController.currentPerfil;
  List<SolicitudServicioModel> get solicitudesDisponibles => _solicitudesDisponibles;
  bool get disponible => _disponible;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get saludo {
    final nombre = perfil?.nombreCompleto ?? '';
    if (nombre.isEmpty) return '¡Hola!';
    return '¡Hola, ${nombre.split(' ').first}!';
  }

  double? get promedioCalificacion => perfil?.promedioCalificacion;
  int? get cantidadResenas => perfil?.cantidadResenas;

  Future<void> loadSolicitudesDisponibles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Filtrar por departamento del trabajador cuando esté disponible
      _solicitudesDisponibles = await _solicitudesRepo.getSolicitudesDisponibles();
    } catch (e) {
      // En modo desarrollo, usar mocks
      _solicitudesDisponibles = _mockSolicitudes();
      _error = null; // no mostrar error en dev con mocks
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDisponibilidad() {
    _disponible = !_disponible;
    // TODO: Actualizar disponibilidad en worker_profiles en Supabase
    notifyListeners();
  }

  /// Actualiza la lista en tiempo real (llamado desde el stream Realtime).
  void onNuevaSolicitud(List<SolicitudServicioModel> nuevas) {
    _solicitudesDisponibles = nuevas;
    notifyListeners();
  }

  /// [Realtime] Suscripción a nuevas solicitudes disponibles.
  /// TODO: Iniciar en initState de la View.
  Stream<List<SolicitudServicioModel>> get solicitudesStream =>
      _solicitudesRepo.streamSolicitudesDisponibles(
        departamento: null, // TODO: filtrar por departamento del trabajador
      );

  List<SolicitudServicioModel> _mockSolicitudes() => [
        SolicitudServicioModel(
          id: 'mock-1',
          clienteId: 'cliente-1',
          categoriaId: 'plomeria',
          descripcion: 'Fuga de agua en lavandería, necesito reparación urgente.',
          urgencia: UrgenciaSolicitud.urgente,
          tipoPago: TipoPago.por_obra,
          presupuestoEstimado: 40.0,
          departamento: 'San Salvador',
          municipio: 'San Salvador',
          colonia: 'Col. Escalón',
          estado: EstadoSolicitud.en_busqueda,
        ),
        SolicitudServicioModel(
          id: 'mock-2',
          clienteId: 'cliente-2',
          categoriaId: 'electricidad',
          descripcion: 'Instalación de 3 tomacorrientes en sala y cuarto.',
          urgencia: UrgenciaSolicitud.hoy,
          tipoPago: TipoPago.por_dia,
          presupuestoEstimado: 30.0,
          departamento: 'San Salvador',
          municipio: 'Santa Tecla',
          colonia: 'Urb. Lomas del Pino',
          estado: EstadoSolicitud.en_busqueda,
        ),
        SolicitudServicioModel(
          id: 'mock-3',
          clienteId: 'cliente-3',
          categoriaId: 'carpinteria',
          descripcion: 'Reparación de puerta principal, bisagras y cerradura.',
          urgencia: UrgenciaSolicitud.esta_semana,
          tipoPago: TipoPago.a_convenir,
          departamento: 'La Libertad',
          municipio: 'Santa Tecla',
          colonia: 'Col. Los Suecos',
          estado: EstadoSolicitud.postulaciones_recibidas,
        ),
      ];
}
