/// worker_profile_viewmodel.dart
/// ViewModel del perfil editable del trabajador.
/// Lee de AMBAS tablas (perfiles + worker_profiles), pero escribe:
///   - `perfiles`        → foto_perfil_url (único campo que el trabajador edita de perfiles)
///   - `worker_profiles` → descripción, tarifa, especialidades, lat/lng, radio_km, disponibilidad
library;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/perfil_model.dart';
import '../../../data/models/worker_profile_model.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/workers_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/supabase_client_service.dart';
import '../../../state/session_controller.dart';

/// Catálogo fijo de especialidades disponibles para el trabajador.
const List<String> kEspecialidadesDisponibles = [
  'Electricidad',
  'Plomería',
  'Albañilería',
  'Pintura',
  'Carpintería',
  'Aire acondicionado',
  'Jardinería',
  'Cerrajería',
  'Limpieza',
  'Mecánica automotriz',
  'Instalación de piso',
  'Instalación de cielo falso',
  'Mecánico en estructuras metálicas',
];

class WorkerProfileViewModel extends ChangeNotifier {
  final PerfilesRepository _perfilesRepo;
  final WorkersRepository _workersRepo;
  final StorageService _storageService;
  final SessionController _sessionController;

  PerfilModel? _perfil;
  WorkerProfileModel? _workerProfile;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _error;
  String? _successMessage;

  // ── Campos editables ────────────────────────────────────────────
  String _descripcion = '';
  double? _tarifaPorDia;
  bool _disponible = true;

  // v2: especialidades como lista
  List<String> _especialidades = [];

  // v2: cobertura geográfica
  double? _latitud;
  double? _longitud;
  final int _radioKm = 6; // fijo

  // Foto de perfil local elegida (previsualización)
  Uint8List? _fotoBytes;
  String _fotoMime = 'image/jpeg';

  WorkerProfileViewModel({
    PerfilesRepository? perfilesRepo,
    WorkersRepository? workersRepo,
    StorageService? storageService,
    required SessionController sessionController,
  })  : _perfilesRepo = perfilesRepo ?? PerfilesRepository(),
        _workersRepo = workersRepo ?? WorkersRepository(),
        _storageService = storageService ?? StorageService(),
        _sessionController = sessionController;

  // ── Getters ────────────────────────────────────────────────────
  PerfilModel? get perfil => _perfil;
  WorkerProfileModel? get workerProfile => _workerProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get error => _error;
  String? get successMessage => _successMessage;

  String get descripcion => _descripcion;
  double? get tarifaPorDia => _tarifaPorDia;
  bool get disponible => _disponible;

  // v2 getters
  List<String> get especialidades => List.unmodifiable(_especialidades);
  double? get latitud => _latitud;
  double? get longitud => _longitud;
  int get radioKm => _radioKm;

  /// Bytes de la foto recién elegida (para previsualización local).
  Uint8List? get fotoBytes => _fotoBytes;

  /// URL de la foto actual del trabajador.
  /// Prioridad: foto recién elegida (local) → perfiles.foto_perfil_url.
  String? get fotoUrl => _perfil?.fotoPerfilUrl;

  // Estado de verificación
  EstadoVerificacion get estadoVerificacion =>
      _workerProfile?.estadoVerificacion ?? EstadoVerificacion.pendiente;

  bool get verificado => _workerProfile?.verificado ?? false;

  // ── Carga de datos ─────────────────────────────────────────────

  /// Carga el perfil base (perfiles) y el perfil extendido (worker_profiles).
  /// Si perfiles.foto_perfil_url está vacío, intenta sincronizarla desde
  /// formulario_trabajador (la foto subida durante el onboarding).
  Future<void> loadPerfil() async {
    _perfil = _sessionController.currentPerfil;
    if (_perfil == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workerProfile = await _workersRepo.getWorkerById(_perfil!.id);

      if (_workerProfile != null) {
        _descripcion = _workerProfile!.descripcion ?? '';
        _tarifaPorDia = _workerProfile!.tarifa;
        _disponible = _workerProfile!.disponibilidad;
        _especialidades = List<String>.from(_workerProfile!.especialidades);
        _latitud = _workerProfile!.latitud;
        _longitud = _workerProfile!.longitud;
      }

      // Si el perfil base no tiene foto, intentar sincronizarla desde
      // el formulario de solicitud del trabajador.
      if (_perfil!.fotoPerfilUrl == null || _perfil!.fotoPerfilUrl!.isEmpty) {
        await _sincronizarFotoDesdeFormulario(_perfil!.id);
      }
    } catch (e) {
      _workerProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca la foto en `formulario_trabajador` y, si existe,
  /// la copia a `perfiles.foto_perfil_url` para que quede como
  /// fuente principal desde ese momento.
  Future<void> _sincronizarFotoDesdeFormulario(String userId) async {
    try {
      final data = await SupabaseClientService.client
          .from('formulario_trabajador')
          .select('foto_perfil_url')
          .eq('user_id', userId)
          .order('fecha_creacion', ascending: false)
          .limit(1)
          .maybeSingle();

      final fotoUrl = data?['foto_perfil_url'] as String?;
      if (fotoUrl != null && fotoUrl.isNotEmpty) {
        // Propagar la URL al perfil base
        final updated = await _perfilesRepo.updatePerfil(
          id: userId,
          fields: {'foto_perfil_url': fotoUrl},
        );
        _perfil = updated;
        // También actualizar en sesión
        await _sessionController.refreshPerfil();
        _perfil = _sessionController.currentPerfil;
      }
    } catch (_) {
      // Si el campo no existe en la tabla o la consulta falla, ignorar silenciosamente.
      // La foto simplemente no se sincroniza y el avatar fallback se muestra.
    }
  }

  // ── Setters ────────────────────────────────────────────────────

  void setDescripcion(String v) {
    _descripcion = v;
    notifyListeners();
  }

  void setTarifa(String v) {
    _tarifaPorDia = double.tryParse(v);
    notifyListeners();
  }

  void toggleDisponible() {
    _disponible = !_disponible;
    notifyListeners();
  }

  // v2 — especialidades

  /// Agrega o quita una especialidad de la lista seleccionada.
  void toggleEspecialidad(String especialidad) {
    if (_especialidades.contains(especialidad)) {
      _especialidades.remove(especialidad);
    } else {
      _especialidades.add(especialidad);
    }
    notifyListeners();
  }

  bool isEspecialidadSeleccionada(String especialidad) =>
      _especialidades.contains(especialidad);

  // v2 — cobertura geográfica

  /// Establece la ubicación del centro de cobertura desde el mapa.
  void setUbicacionCobertura(double latitud, double longitud) {
    _latitud = latitud;
    _longitud = longitud;
    notifyListeners();
  }

  // ── Foto de perfil ─────────────────────────────────────────────

  /// Abre el selector de imágenes, carga los bytes y los guarda localmente
  /// para previsualización inmediata. La subida real ocurre al guardar.
  Future<void> elegirFotoPerfil() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';

      _fotoBytes = bytes;
      _fotoMime = mime;
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo seleccionar la imagen: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Sube la foto elegida a Storage y actualiza `perfiles.foto_perfil_url`.
  Future<bool> subirFotoPerfil() async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null || _fotoBytes == null) return false;

    _isUploadingPhoto = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _storageService.uploadFotoPerfilBytes(
        userId: userId,
        bytes: _fotoBytes!,
        contentType: _fotoMime,
      );

      // Actualizar perfiles.foto_perfil_url
      final updated = await _perfilesRepo.updatePerfil(
        id: userId,
        fields: {'foto_perfil_url': url},
      );
      _perfil = updated;
      _fotoBytes = null; // Ya subida, limpiar buffer local

      await _sessionController.refreshPerfil();
      _perfil = _sessionController.currentPerfil;

      return true;
    } catch (e) {
      _error = 'No se pudo subir la foto: ${e.toString().replaceFirst("Exception: ", "")}';
      return false;
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  // ── Guardar perfil ─────────────────────────────────────────────

  /// Guarda todos los datos profesionales del trabajador en `worker_profiles`.
  /// Si hay una foto nueva elegida, la sube primero.
  /// NO escribe ningún campo profesional en `perfiles`.
  Future<bool> guardarPerfil() async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null) return false;

    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 1. Si hay foto nueva pendiente, subirla antes de guardar el resto
      if (_fotoBytes != null) {
        final fotoOk = await subirFotoPerfil();
        if (!fotoOk) {
          // El error ya está en _error; detener guardado
          return false;
        }
      }

      // 2. Todos los campos profesionales van a `worker_profiles`
      final workerFields = <String, dynamic>{
        if (_descripcion.isNotEmpty) 'descripcion': _descripcion,
        if (_tarifaPorDia != null) 'tarifa': _tarifaPorDia,
        'disponibilidad': _disponible,
        'especialidades': _especialidades,
        if (_latitud != null) 'latitud': _latitud,
        if (_longitud != null) 'longitud': _longitud,
        'radio_km': _radioKm,
      };

      if (_workerProfile == null) {
        _workerProfile = await _workersRepo.createWorkerProfile(
          WorkerProfileModel(
            id: userId,
            descripcion: _descripcion.isNotEmpty ? _descripcion : null,
            tarifa: _tarifaPorDia,
            disponibilidad: _disponible,
            especialidades: _especialidades,
            latitud: _latitud,
            longitud: _longitud,
            radioKm: _radioKm,
          ),
        );
      } else {
        _workerProfile = await _workersRepo.updateWorkerProfile(
          id: userId,
          fields: workerFields,
        );
      }

      await _sessionController.refreshPerfil();
      _perfil = _sessionController.currentPerfil;

      _successMessage = 'Perfil actualizado correctamente.';
      return true;
    } catch (e) {
      _error =
          'No se pudo guardar el perfil: ${e.toString().replaceFirst("Exception: ", "")}';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
