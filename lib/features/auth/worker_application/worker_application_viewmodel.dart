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

  Uint8List? _antecedentesBytes;
  String _antecedentesMime = 'application/pdf';

  // ── Estado de carga por archivo ───────────────────────────────
  bool _uploadingFotoPerfil = false;
  bool _uploadingDui = false;
  bool _uploadingAntecedentes = false;

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
  Uint8List? get antecedentesBytes => _antecedentesBytes;
  String get antecedentesMime => _antecedentesMime;

  bool get hayFotoPerfil => _fotoPerfilBytes != null;
  bool get hayFotoDui => _fotoDuiBytes != null;
  bool get hayAntecedentes => _antecedentesBytes != null;

  bool get uploadingFotoPerfil => _uploadingFotoPerfil;
  bool get uploadingDui => _uploadingDui;
  bool get uploadingAntecedentes => _uploadingAntecedentes;

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

  void setAntecedentesBytes(
    Uint8List bytes, {
    String mime = 'application/pdf',
  }) {
    _antecedentesBytes = bytes;
    _antecedentesMime = mime;
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
    String? direccion,
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
      final correo = perfil?.correo ?? '';
      final celular = perfil?.telefono ?? '';

      String? fotoPerfilUrl;
      String? fotoDuiUrl;
      String? antecedentesUrl;

      // ── 1. Subir foto de perfil ───────────────────────────────
      if (_fotoPerfilBytes != null) {
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
      }

      // ── 2. Subir foto de DUI ──────────────────────────────────
      if (_fotoDuiBytes != null) {
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
      }

      // ── 3. Subir antecedentes ─────────────────────────────────
      if (_antecedentesBytes != null) {
        _uploadingAntecedentes = true;
        notifyListeners();
        try {
          antecedentesUrl = await _storageService.uploadAntecedentesBytes(
            userId: userId,
            bytes: _antecedentesBytes!,
            contentType: _antecedentesMime,
          );
        } finally {
          _uploadingAntecedentes = false;
          notifyListeners();
        }
      }

      // ── 4. Guardar formulario en Supabase ─────────────────────
      final formulario = FormularioTrabajadorModel(
        nombreCompleto: nombre,
        correo: correo,
        celular: celular,
        dui: dui,
        direccion: direccion,
        fotoPerfilUrl: fotoPerfilUrl,
        fotoDuiUrl: fotoDuiUrl,
        antecedentespenalesUrl: antecedentesUrl,
      );

      await _formularioRepository.submitFormulario(formulario);
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
    _antecedentesBytes = null;
    _uploadingFotoPerfil = false;
    _uploadingDui = false;
    _uploadingAntecedentes = false;
    notifyListeners();
  }
}
