/// client_profile_view.dart
/// Pantalla de perfil/cuenta del cliente.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../state/session_controller.dart';
import 'client_profile_viewmodel.dart';

class ClientProfileView extends StatefulWidget {
  const ClientProfileView({super.key});

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<ClientProfileView> {
  late final ClientProfileViewModel _vm;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _vm = ClientProfileViewModel(
      sessionController: context.read<SessionController>(),
    );
    _nombreCtrl = TextEditingController(text: _vm.perfil?.nombreCompleto ?? '');
    _telefonoCtrl = TextEditingController(text: _vm.perfil?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ClientProfileViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // ── Avatar tappable ──────────────────────────
                  GestureDetector(
                    onTap: vm.isUploadingPhoto
                        ? null
                        : () async {
                            await vm.elegirFotoPerfil();
                          },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: vm.fotoBytes != null
                              ? MemoryImage(vm.fotoBytes!)
                              : (vm.perfil?.fotoPerfilUrl != null &&
                                      vm.perfil!.fotoPerfilUrl!.isNotEmpty)
                                  ? NetworkImage(vm.perfil!.fotoPerfilUrl!)
                                  : null,
                          child: (vm.fotoBytes == null &&
                                  (vm.perfil?.fotoPerfilUrl == null ||
                                      vm.perfil!.fotoPerfilUrl!.isEmpty))
                              ? Text(
                                  vm.perfil?.nombreCompleto.isNotEmpty == true
                                      ? vm.perfil!.nombreCompleto[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary),
                                )
                              : null,
                        ),
                        // Indicador de subida
                        if (vm.isUploadingPhoto)
                          const Positioned.fill(
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Color(0x88000000),
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        // Botón cámara
                        if (!vm.isUploadingPhoto)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca la foto para cambiarla',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vm.perfil?.correo ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // ── Campos editables ──────────────────────────
                  CustomTextField(
                    label: 'Nombre completo',
                    hint: 'Tu nombre',
                    controller: _nombreCtrl,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: Validators.nombre,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Teléfono',
                    hint: '7000-0000',
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    maxLength: 9,
                  ),
                  const SizedBox(height: 24),
                  // ── Feedback ───────────────────────────────────
                  if (vm.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(vm.error!,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  if (vm.successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(vm.successMessage!,
                          style: const TextStyle(color: AppColors.success)),
                    ),
                  PrimaryButton(
                    label: 'Guardar cambios',
                    icon: Icons.save_rounded,
                    isLoading: vm.isSaving || vm.isUploadingPhoto,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await vm.updatePerfil(
                        nombreCompleto: _nombreCtrl.text.trim(),
                        telefono: _telefonoCtrl.text.trim().isEmpty
                            ? null
                            : _telefonoCtrl.text.trim(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  // ── Opciones adicionales ──────────────────────
                  _OptionTile(
                    icon: Icons.history_rounded,
                    label: 'Historial de servicios',
                    onTap: () =>
                        context.push(RouteNames.clientServiceHistory),
                  ),
                  _OptionTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Cambiar contraseña',
                    onTap: () =>
                        context.push(RouteNames.clientChangePassword),
                  ),
                  _OptionTile(
                    icon: Icons.location_on_outlined,
                    label: 'Direcciones guardadas',
                    onTap: () =>
                        context.push(RouteNames.clientSavedAddresses),
                  ),
                  _OptionTile(
                    icon: Icons.support_agent_rounded,
                    label: 'Soporte',
                    onTap: () => context.push(RouteNames.clientSupport),
                  ),
                  const Divider(),
                  _OptionTile(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    color: AppColors.error,
                    onTap: () async {
                      await vm.signOut();
                      if (context.mounted) context.go(RouteNames.roleSelector);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
