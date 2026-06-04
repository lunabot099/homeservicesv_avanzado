/// client_change_password_view.dart
/// Pantalla para que el cliente cambie su contraseña.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ClientChangePasswordView extends StatefulWidget {
  const ClientChangePasswordView({super.key});

  @override
  State<ClientChangePasswordView> createState() =>
      _ClientChangePasswordViewState();
}

class _ClientChangePasswordViewState extends State<ClientChangePasswordView> {
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPassCtrl.text),
      );
      setState(() => _success = 'Contraseña actualizada correctamente.');
      _newPassCtrl.clear();
      _confirmCtrl.clear();
    } catch (e) {
      setState(() => _error = 'No se pudo actualizar la contraseña. Intenta de nuevo.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Nueva contraseña',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Elige una contraseña segura de al menos 6 caracteres.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Nueva contraseña',
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.length < 6)
                    ? 'Mínimo 6 caracteres'
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirmar contraseña',
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                textInputAction: TextInputAction.done,
                validator: (v) => v != _newPassCtrl.text
                    ? 'Las contraseñas no coinciden'
                    : null,
                onSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
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
                            style:
                                const TextStyle(color: AppColors.error, fontSize: 13))),
                  ]),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_success!,
                            style: const TextStyle(
                                color: AppColors.success, fontSize: 13))),
                  ]),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Actualizar contraseña',
                icon: Icons.lock_reset_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
