/// worker_application_viewmodel.dart
/// ViewModel del formulario de aplicación para trabajadores.
///
/// REQUIERE sesión activa. Usa [SessionController.currentUser!.id]
/// como userId real para Storage y para el formulario en Supabase.
///
/// Compatibilidad multiplataforma:
/// - Los archivos se manejan como Uint8List (funciona en web, móvil y escritorio).
/// - La subida usa uploadBinary de Supabase Storage.
library;

import 'package:flutter/foundation.dart';
import '../../../data/repositories/formulario_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/models/formulario_trabajador_model.dart';
import '../../../state/session_controller.dart';

class WorkerApplicationViewModel extends ChangeNotifier {
  final FormularioRepository _formularioRepository;
  final StorageService _storageService;
  final SessionController _sessionController;

  bool _isLoading = false;
  String? _error;
  bool _enviado = false;

  // ── Bytes de los archivos seleccionados ───────────────────────
  Uint8List? _fotoPerfilBytes;
  String _fotoPerfilMime = 'image/jpeg';

  Uint8List? _fotoDuiBytes;
  String _fotoDuiMime = 'image/jpeg';

  Uint8List? _antecedentesPenalesBytes;
  String _antecedentesPenalesMime = 'application/pdf';

  Uint8List? _antecedentesPolicialesBytes;
  String _antecedentesPolicialesMime = 'application/pdf';

  // ── Estado de carga por archivo ───────────────────────────────
  bool _uploadingFotoPerfil = false;
  bool _uploadingDui = false;
  bool _uploadingAntecedentesPenales = false;
  bool _uploadingAntecedentesPoliciales = false;

  WorkerApplicationViewModel({
    FormularioRepository? formularioRepository,
    StorageService? storageService,
    required SessionController sessionController,
  })  : _formularioRepository = formularioRepository ?? FormularioRepository(),
        _storageService = storageService ?? StorageService(),
        _sessionController = sessionController;

  // ── Getters ───────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get enviado => _enviado;

  Uint8List? get fotoPerfilBytes => _fotoPerfilBytes;
  Uint8List? get fotoDuiBytes => _fotoDuiBytes;
  Uint8List? get antecedentesPenalesBytes => _antecedentesPenalesBytes;
  String get antecedentesPenalesMime => _antecedentesPenalesMime;

  Uint8List? get antecedentesPolicialesBytes => _antecedentesPolicialesBytes;
  String get antecedentesPolicialesMime => _antecedentesPolicialesMime;

  bool get hayFotoPerfil => _fotoPerfilBytes != null;
  bool get hayFotoDui => _fotoDuiBytes != null;
  bool get hayAntecedentesPenales => _antecedentesPenalesBytes != null;
  bool get hayAntecedentesPoliciales => _antecedentesPolicialesBytes != null;

  bool get uploadingFotoPerfil => _uploadingFotoPerfil;
  bool get uploadingDui => _uploadingDui;
  bool get uploadingAntecedentesPenales => _uploadingAntecedentesPenales;
  bool get uploadingAntecedentesPoliciales => _uploadingAntecedentesPoliciales;

  // ── Setters de archivos ───────────────────────────────────────

  void setFotoPerfilBytes(Uint8List bytes, {String mime = 'image/jpeg'}) {
    _fotoPerfilBytes = bytes;
    _fotoPerfilMime = mime;
    notifyListeners();
  }

  void setFotoDuiBytes(Uint8List bytes, {String mime = 'image/jpeg'}) {
    _fotoDuiBytes = bytes;
    _fotoDuiMime = mime;
    notifyListeners();
  }

  void setAntecedentesPenalesBytes(
    Uint8List bytes, {
    String mime = 'application/pdf',
  }) {
    _antecedentesPenalesBytes = bytes;
    _antecedentesPenalesMime = mime;
    notifyListeners();
  }

  void setAntecedentesPolicialesBytes(
    Uint8List bytes, {
    String mime = 'application/pdf',
  }) {
    _antecedentesPolicialesBytes = bytes;
    _antecedentesPolicialesMime = mime;
    notifyListeners();
  }

  // ── Envío del formulario ──────────────────────────────────────

  /// Sube los archivos a Storage usando el userId real de Auth y guarda
  /// el formulario en la tabla `formulario_trabajador`.
  ///
  /// Solo recibe [dui] y [direccion] del formulario.
  /// Nombre, correo y celular se toman del perfil autenticado (sin duplicar datos).
  Future<bool> submitApplication({
    required String dui,
    required String direccion,
    double? latitud,
    double? longitud,
  }) async {
    _isLoading = true;
    _error = null;
    _enviado = false;
    notifyListeners();

    try {
      // Todos los identificadores vienen del perfil autenticado
      final userId = _sessionController.currentUser?.id;
      final perfil = _sessionController.currentPerfil;

      if (userId == null) {
        _error = 'No hay sesión activa. Inicia sesión nuevamente.';
        return false;
      }

      // Datos personales desde el perfil base — no se duplican
      final nombre = perfil?.nombreCompleto ?? '';
      final correo =
          _sessionController.currentUser?.email ?? perfil?.correo ?? '';
      final celular = perfil?.telefono ?? '';

      String? fotoPerfilUrl;
      String? fotoDuiUrl;
      String? antecedentesPenalesUrl;
      String? antecedentesPolicialesUrl;

      if (direccion.trim().isEmpty) {
        _error = 'La dirección de casa es obligatoria.';
        return false;
      }

      if (_fotoPerfilBytes == null) {
        _error = 'La foto de perfil es obligatoria.';
        return false;
      }
      if (_fotoDuiBytes == null) {
        _error = 'La foto del DUI es obligatoria.';
        return false;
      }
      if (_antecedentesPenalesBytes == null) {
        _error = 'Los antecedentes penales son obligatorios.';
        return false;
      }
      if (_antecedentesPolicialesBytes == null) {
        _error = 'Los antecedentes policiales son obligatorios.';
        return false;
      }

      // ── 1. Subir foto de perfil ───────────────────────────────
      _uploadingFotoPerfil = true;
      notifyListeners();
      try {
        fotoPerfilUrl = await _storageService.uploadFotoPerfilBytes(
          userId: userId,
          bytes: _fotoPerfilBytes!,
          contentType: _fotoPerfilMime,
        );
      } finally {
        _uploadingFotoPerfil = false;
        notifyListeners();
      }

      // ── 2. Subir foto de DUI ──────────────────────────────────
      _uploadingDui = true;
      notifyListeners();
      try {
        fotoDuiUrl = await _storageService.uploadFotoDuiBytes(
          userId: userId,
          bytes: _fotoDuiBytes!,
          contentType: _fotoDuiMime,
        );
      } finally {
        _uploadingDui = false;
        notifyListeners();
      }

      // ── 3. Subir antecedentes penales ─────────────────────────
      _uploadingAntecedentesPenales = true;
      notifyListeners();
      try {
        antecedentesPenalesUrl = await _storageService.uploadAntecedentesBytes(
          userId: userId,
          bytes: _antecedentesPenalesBytes!,
          contentType: _antecedentesPenalesMime,
        );
      } finally {
        _uploadingAntecedentesPenales = false;
        notifyListeners();
      }

      // ── 4. Subir antecedentes policiales ──────────────────────
      _uploadingAntecedentesPoliciales = true;
      notifyListeners();
      try {
        antecedentesPolicialesUrl =
            await _storageService.uploadAntecedentesPolicialesBytes(
          userId: userId,
          bytes: _antecedentesPolicialesBytes!,
          contentType: _antecedentesPolicialesMime,
        );
      } finally {
        _uploadingAntecedentesPoliciales = false;
        notifyListeners();
      }

      // ── 4. Guardar formulario en Supabase ─────────────────────
      final formulario = FormularioTrabajadorModel(
        userId: userId,
        nombreCompleto: nombre,
        correo: correo,
        celular: celular,
        dui: dui,
        direccion: direccion.trim(),
        latitud: latitud,
        longitud: longitud,
        fotoPerfilUrl: fotoPerfilUrl,
        fotoDuiUrl: fotoDuiUrl,
        antecedentespenalesUrl: antecedentesPenalesUrl,
        antecedentesPolicialesUrl: antecedentesPolicialesUrl,
      );

      await _formularioRepository.submitFormulario(formulario);
      await _sessionController.refreshPerfil();
      _enviado = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _enviado = false;
    _fotoPerfilBytes = null;
    _fotoDuiBytes = null;
    _antecedentesPenalesBytes = null;
    _antecedentesPolicialesBytes = null;
    _uploadingFotoPerfil = false;
    _uploadingDui = false;
    _uploadingAntecedentesPenales = false;
    _uploadingAntecedentesPoliciales = false;
    notifyListeners();
  }
}
