/// worker_register_view.dart
/// Pantalla de registro de cuenta para trabajadores.
///
/// Después de un registro exitoso, navega automáticamente a workerApplication
/// para que el trabajador complete su formulario de postulación.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../state/session_controller.dart';
import 'worker_register_viewmodel.dart';

class WorkerRegisterView extends StatelessWidget {
  const WorkerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkerRegisterViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _WorkerRegisterContent(),
    );
  }
}

class _WorkerRegisterContent extends StatefulWidget {
  const _WorkerRegisterContent();

  @override
  State<_WorkerRegisterContent> createState() => _WorkerRegisterContentState();
}

class _WorkerRegisterContentState extends State<_WorkerRegisterContent> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<WorkerRegisterViewModel>();
    final success = await vm.register(
      nombreCompleto: _nombreCtrl.text.trim(),
      correo: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      telefono: _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
    );

    if (!success || !mounted) return;

    if (vm.requiresEmailConfirmation) {
      return;
    }

    // Registro exitoso → ir directo al formulario de postulación
    context.go(RouteNames.workerApplication);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerRegisterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Trabajador'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Ícono de rol ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.workerRole.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: AppColors.workerRole,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Crea tu cuenta de trabajador',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Luego completarás tu perfil profesional',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // ── Nombre ────────────────────────────────────
                CustomTextField(
                  label: 'Nombre completo',
                  hint: 'Juan Pérez García',
                  controller: _nombreCtrl,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: Validators.nombre,
                ),
                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────────
                CustomTextField(
                  label: 'Correo electrónico',
                  hint: 'correo@ejemplo.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // ── Teléfono (opcional) ───────────────────────
                CustomTextField(
                  label: 'Teléfono (opcional)',
                  hint: '7000-0000',
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  textInputAction: TextInputAction.next,
                  maxLength: 9,
                ),
                const SizedBox(height: 16),

                // ── Contraseña ────────────────────────────────
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirmar contraseña ───────────────────────
                CustomTextField(
                  label: 'Confirmar contraseña',
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      Validators.confirmPassword(value, _passwordCtrl.text),
                  onSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),

                if (vm.requiresEmailConfirmation) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.mark_email_read_outlined,
                            color: AppColors.info, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cuenta creada. Confirma tu correo y luego inicia sesión.',
                            style: TextStyle(color: AppColors.info, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Error ─────────────────────────────────────
                if (vm.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── Botón crear cuenta ────────────────────────
                PrimaryButton(
                  label: 'Crear cuenta',
                  onPressed: _submit,
                  isLoading: vm.isLoading,
                  icon: Icons.handyman_rounded,
                  backgroundColor: AppColors.workerRole,
                ),
                const SizedBox(height: 24),

                // ── Link a login ──────────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Inicia sesión',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.workerRole,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
