/// client_login_view.dart
/// Pantalla de login del cliente.
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
import 'client_login_viewmodel.dart';

class ClientLoginView extends StatelessWidget {
  const ClientLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientLoginViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _ClientLoginContent(),
    );
  }
}

class _ClientLoginContent extends StatefulWidget {
  const _ClientLoginContent();

  @override
  State<_ClientLoginContent> createState() => _ClientLoginContentState();
}

class _ClientLoginContentState extends State<_ClientLoginContent> {
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

    final vm = context.read<ClientLoginViewModel>();
    final success = await vm.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (success && mounted) {
      context.go(RouteNames.clientHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientLoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Acceso Cliente'),
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
                // ── Header ────────────────────────────────────
                Text(
                  'Bienvenido de vuelta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ingresa a tu cuenta de cliente',
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
                // ── Password ──────────────────────────────────
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
                const SizedBox(height: 8),
                // ── Error ─────────────────────────────────────
                if (vm.error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // ── Olvidé mi contraseña ──────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implementar reset de contraseña en Fase 2
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 24),
                // ── Botón de Login ────────────────────────────
                PrimaryButton(
                  label: 'Ingresar',
                  onPressed: _submit,
                  isLoading: vm.isLoading,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 24),
                // ── Link de registro ──────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.clientRegister),
                        child: Text(
                          'Regístrate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
