/// worker_login_view.dart
/// Pantalla de acceso del trabajador.
///
/// Ofrece dos caminos claros:
///   • Ingresar (login) — para quienes ya tienen cuenta
///   • Registrarse como trabajador — para quienes no tienen cuenta
///
/// Después de un login exitoso, navega según [WorkerLoginResult]:
///   goHome        → /worker/home
///   goApplication → /worker/apply
///   goPending     → /worker/pending
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
import 'worker_login_viewmodel.dart';

class WorkerLoginView extends StatelessWidget {
  const WorkerLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkerLoginViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _WorkerLoginContent(),
    );
  }
}

class _WorkerLoginContent extends StatefulWidget {
  const _WorkerLoginContent();

  @override
  State<_WorkerLoginContent> createState() => _WorkerLoginContentState();
}

class _WorkerLoginContentState extends State<_WorkerLoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<WorkerLoginViewModel>();
    final result = await vm.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted || result == null) return;

    switch (result) {
      case WorkerLoginResult.goHome:
        context.go(RouteNames.workerHome);
      case WorkerLoginResult.goApplication:
        context.go(RouteNames.workerApplication);
      case WorkerLoginResult.goPending:
        context.go(RouteNames.workerPending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerLoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Acceso Trabajador'),
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
                const SizedBox(height: 16),

                // ── Ícono de rol ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.workerRole.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: AppColors.workerRole,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Acceso para trabajadores',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ingresa con tus credenciales',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 40),

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

                // ── Contraseña ────────────────────────────────
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onSubmitted: (_) => _submit(),
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

                // ── Botón principal: Ingresar ──────────────────
                PrimaryButton(
                  label: 'Ingresar',
                  onPressed: _submit,
                  isLoading: vm.isLoading,
                  icon: Icons.login_rounded,
                  backgroundColor: AppColors.workerRole,
                ),
                const SizedBox(height: 16),

                // ── Divisor ───────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Botón secundario: Registrarse ─────────────
                OutlinedButton.icon(
                  onPressed: () => context.push(RouteNames.workerRegister),
                  icon: const Icon(Icons.person_add_rounded,
                      color: AppColors.workerRole),
                  label: const Text(
                    'Registrarse como trabajador',
                    style: TextStyle(
                      color: AppColors.workerRole,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.workerRole),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
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
