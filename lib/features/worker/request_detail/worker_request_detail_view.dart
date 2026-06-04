/// worker_request_detail_view.dart
/// Detalle completo de una solicitud disponible para que el trabajador decida postularse.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../state/session_controller.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import 'worker_request_detail_viewmodel.dart';

class WorkerRequestDetailView extends StatelessWidget {
  final SolicitudServicioModel solicitud;

  const WorkerRequestDetailView({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerRequestDetailViewModel(
        sessionController: ctx.read<SessionController>(),
      )..loadSolicitud(solicitud),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerRequestDetailViewModel>();
    final s = vm.solicitud;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de solicitud'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Urgencia badge ────────────────────────────────────
          _UrgenciaBadge(urgencia: s.urgencia),
          const SizedBox(height: 16),

          // ── Categoría ─────────────────────────────────────────
          _InfoSection(
            icon: Icons.build_circle_outlined,
            title: 'Tipo de servicio',
            value: s.categoriaId.toUpperCase(),
          ),
          const SizedBox(height: 12),

          // ── Descripción ───────────────────────────────────────
          _InfoSection(
            icon: Icons.description_outlined,
            title: 'Descripción del trabajo',
            value: s.descripcion,
          ),
          const SizedBox(height: 12),

          // ── Ubicación ─────────────────────────────────────────
          _InfoSection(
            icon: Icons.location_on_outlined,
            title: 'Ubicación aproximada',
            value: [s.colonia, s.municipio, s.departamento]
                .whereType<String>()
                .where((e) => e.isNotEmpty)
                .join(', '),
          ),
          if (s.puntoReferencia != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text('Referencia: ${s.puntoReferencia}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ),
          ],
          const SizedBox(height: 12),

          // ── Pago ──────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: _InfoSection(
                icon: Icons.payments_outlined,
                title: 'Tipo de pago',
                value: s.tipoPago.label,
              ),
            ),
            if (s.presupuestoEstimado != null)
              Expanded(
                child: _InfoSection(
                  icon: Icons.attach_money_rounded,
                  title: 'Presupuesto estimado',
                  value: '\$${s.presupuestoEstimado!.toStringAsFixed(0)}',
                ),
              ),
          ]),
          if (s.horarioPreferido != null) ...[
            const SizedBox(height: 12),
            _InfoSection(
              icon: Icons.schedule_outlined,
              title: 'Horario preferido',
              value: s.horarioPreferido!,
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),

          // ── Precio ofertado (opcional) ────────────────────────
          Text('Tu oferta (opcional)',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio que cobrarías (\$)',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
            onChanged: vm.setPrecio,
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mensaje inicial al cliente (opcional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.chat_outlined),
            ),
            onChanged: vm.setMensaje,
          ),

          const SizedBox(height: 28),

          // ── Mensaje de éxito si ya se postuló ─────────────────
          if (vm.postulado)
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: AppColors.workerRole.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.workerRole),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Postulación enviada! El cliente verá tu oferta.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.workerRole,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ]),
            ),

          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(vm.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),

          const SizedBox(height: 20),

          // ── Botones de acción ─────────────────────────────────
          if (!vm.yaPostulado) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final ok = await vm.postularse();
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('¡Postulación enviada!')),
                          );
                        }
                      },
                icon: vm.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: const Text('Postularme ahora'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workerRole),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
                label: const Text('No me interesa'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.workerApplications),
                icon: const Icon(Icons.assignment_rounded),
                label: const Text('Ver mis postulaciones'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workerRole),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _UrgenciaBadge extends StatelessWidget {
  final UrgenciaSolicitud urgencia;
  const _UrgenciaBadge({required this.urgencia});

  Color get color {
    switch (urgencia) {
      case UrgenciaSolicitud.urgente:
        return AppColors.error;
      case UrgenciaSolicitud.hoy:
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bolt_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(urgencia.label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: AppColors.grey500),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
    ]);
  }
}
