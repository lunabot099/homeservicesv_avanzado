/// client_profile_viewmodel.dart
library;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/perfil_model.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../state/session_controller.dart';

class ClientProfileViewModel extends ChangeNotifier {
  final PerfilesRepository _perfilesRepository;
  final StorageService _storageService;
  final SessionController _sessionController;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _error;
  String? _successMessage;

  // Bytes de la foto nueva elegida (previsualización local)
  Uint8List? _fotoBytes;
  String _fotoMime = 'image/jpeg';

  ClientProfileViewModel({
    PerfilesRepository? perfilesRepository,
    StorageService? storageService,
    required SessionController sessionController,
  })  : _perfilesRepository = perfilesRepository ?? PerfilesRepository(),
        _storageService = storageService ?? StorageService(),
        _sessionController = sessionController;

  PerfilModel? get perfil => _sessionController.currentPerfil;
  bool get isSaving => _isSaving;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get error => _error;
  String? get successMessage => _successMessage;

  /// Bytes de la foto elegida (previsualización antes de guardar)
  Uint8List? get fotoBytes => _fotoBytes;

  // ── Foto de perfil ──────────────────────────────────────────

  /// Abre el selector de imágenes para elegir una nueva foto.
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
      _fotoBytes = bytes;
      _fotoMime = picked.mimeType ?? 'image/jpeg';
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo seleccionar la imagen.';
      notifyListeners();
    }
  }

  /// Sube la foto elegida y actualiza `perfiles.foto_perfil_url`.
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
      await _perfilesRepository.updatePerfil(
        id: userId,
        fields: {'foto_perfil_url': url},
      );
      _fotoBytes = null;
      await _sessionController.refreshPerfil();
      _successMessage = 'Foto actualizada correctamente.';
      return true;
    } catch (e) {
      _error =
          'No se pudo actualizar la foto: ${e.toString().replaceFirst("Exception: ", "")}';
      return false;
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  // ── Datos del perfil ─────────────────────────────────────────

  /// Actualiza nombre y teléfono. Si hay foto pendiente, la sube primero.
  Future<bool> updatePerfil({
    required String nombreCompleto,
    String? telefono,
  }) async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null) return false;

    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Si hay foto nueva, subirla antes de guardar los demás campos
      if (_fotoBytes != null) {
        final fotoOk = await subirFotoPerfil();
        if (!fotoOk) return false;
      }

      await _perfilesRepository.updatePerfil(
        id: userId,
        fields: {
          'nombre_completo': nombreCompleto,
          if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        },
      );
      await _sessionController.refreshPerfil();
      _successMessage = 'Perfil actualizado correctamente.';
      return true;
    } catch (e) {
      _error = 'No se pudo actualizar el perfil.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _sessionController.signOut();
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
