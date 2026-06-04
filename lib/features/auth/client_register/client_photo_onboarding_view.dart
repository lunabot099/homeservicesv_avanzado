/// client_photo_onboarding_view.dart
/// Paso obligatorio de foto de perfil tras el registro del cliente.
/// El cliente NO puede ir al home sin completar este paso.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../state/session_controller.dart';

class ClientPhotoOnboardingView extends StatefulWidget {
  const ClientPhotoOnboardingView({super.key});

  @override
  State<ClientPhotoOnboardingView> createState() =>
      _ClientPhotoOnboardingViewState();
}

class _ClientPhotoOnboardingViewState
    extends State<ClientPhotoOnboardingView> {
  Uint8List? _fotoBytes;
  String _fotoMime = 'image/jpeg';
  bool _isUploading = false;
  String? _error;

  final _storage = StorageService();
  final _perfilesRepo = PerfilesRepository();

  Future<void> _elegirFoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoMime = picked.mimeType ?? 'image/jpeg';
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'No se pudo seleccionar la imagen.');
    }
  }

  Future<void> _guardar() async {
    if (_fotoBytes == null) {
      setState(() => _error = 'Debes seleccionar una foto para continuar.');
      return;
    }

    final session = context.read<SessionController>();
    final userId = session.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final url = await _storage.uploadFotoPerfilBytes(
        userId: userId,
        bytes: _fotoBytes!,
        contentType: _fotoMime,
      );
      await _perfilesRepo.updatePerfil(
        id: userId,
        fields: {'foto_perfil_url': url},
      );
      await session.refreshPerfil();

      if (mounted) context.go(RouteNames.clientHome);
    } catch (e) {
      setState(() {
        _error = 'No se pudo guardar la foto. Inténtalo de nuevo.';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // ── Ícono decorativo ─────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Casi listo!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega una foto de perfil para que los trabajadores te identifiquen fácilmente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Avatar / previsualización ─────────────────
              GestureDetector(
                onTap: _isUploading ? null : _elegirFoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 72,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: _fotoBytes != null
                          ? MemoryImage(_fotoBytes!)
                          : null,
                      child: _fotoBytes == null
                          ? const Icon(Icons.person_rounded,
                              size: 64, color: AppColors.primary)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _isUploading ? null : _elegirFoto,
                icon: const Icon(Icons.photo_library_rounded, size: 16),
                label: Text(
                    _fotoBytes == null ? 'Seleccionar foto' : 'Cambiar foto'),
              ),

              // ── Error ─────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13))),
                  ]),
                ),
              ],

              const Spacer(),

              // ── Botones ───────────────────────────────────
              PrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isUploading,
                onPressed: _guardar,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isUploading
                    ? null
                    : () => context.go(RouteNames.clientHome),
                child: Text(
                  'Omitir por ahora',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
