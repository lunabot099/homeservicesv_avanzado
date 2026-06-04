/// worker_pending_view.dart
/// Pantalla informativa que muestra el estado "en revisión" del trabajador.
///
/// Se muestra cuando el trabajador ya envió su formulario y está esperando
/// aprobación del equipo de HomeServiceSV.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../state/session_controller.dart';

class WorkerPendingView extends StatelessWidget {
  const WorkerPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final nombre = session.currentPerfil?.nombreCompleto ?? 'Trabajador';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Ícono de estado ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  size: 56,
                ),
              ),
              const SizedBox(height: 32),

              // ── Título ───────────────────────────────────────
              Text(
                '¡Solicitud recibida!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ── Saludo personalizado ──────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  children: [
                    const TextSpan(text: 'Hola, '),
                    TextSpan(
                      text: nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Tu solicitud está siendo revisada por nuestro equipo.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Card de estado ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.paddingLg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _StatusRow(
                      icon: Icons.assignment_turned_in_rounded,
                      label: 'Formulario enviado',
                      color: AppColors.success,
                    ),
                    const Divider(height: 24),
                    _StatusRow(
                      icon: Icons.manage_search_rounded,
                      label: 'En proceso de verificación',
                      color: AppColors.warning,
                      isActive: true,
                    ),
                    const Divider(height: 24),
                    _StatusRow(
                      icon: Icons.verified_rounded,
                      label: 'Cuenta activada',
                      color: AppColors.grey400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tiempo estimado ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.info, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'El proceso de revisión toma entre 2 y 5 días hábiles. '
                        'Te notificaremos al correo registrado.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Botón cerrar sesión ───────────────────────────
              PrimaryButton(
                label: 'Cerrar sesión',
                onPressed: () async {
                  final sc = context.read<SessionController>();
                  await sc.signOut();
                  if (context.mounted) context.go(RouteNames.roleSelector);
                },
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.grey700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de estado individual en la tarjeta de progreso.
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
          ),
        ),
        if (isActive)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'En curso',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}
