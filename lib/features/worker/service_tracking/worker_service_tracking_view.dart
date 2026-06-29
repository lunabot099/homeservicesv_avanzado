/// worker_service_tracking_view.dart
/// Pantalla de trabajo en curso — el trabajador avanza los estados del servicio
/// hasta marcarlo como finalizado. El cliente confirma el cierre desde su lado.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../state/session_controller.dart';
import 'worker_service_tracking_viewmodel.dart';

class WorkerServiceTrackingView extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const WorkerServiceTrackingView({super.key, this.solicitud});

  @override
  State<WorkerServiceTrackingView> createState() =>
      _WorkerServiceTrackingViewState();
}

class _WorkerServiceTrackingViewState extends State<WorkerServiceTrackingView> {
  late final WorkerServiceTrackingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WorkerServiceTrackingViewModel(
      sessionController: context.read<SessionController>(),
    );
    if (widget.solicitud != null) {
      _vm.loadSolicitud(widget.solicitud!);
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WorkerServiceTrackingViewModel>(
        builder: (context, vm, _) {
          final s = vm.solicitud ?? widget.solicitud;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Trabajo en curso'),
              backgroundColor: Colors.transparent,
              actions: [
                // El chat es 1:1 con la solicitud; mostramos el botón si hay solicitud cargada.
                if (s != null)
                  IconButton(
                    icon: const Icon(Icons.chat_rounded),
                    onPressed: () {
                      final session = context.read<SessionController>();
                      final solicitudId = s.id;
                      final trabajadorId = session.currentUser?.id;
                      if (solicitudId == null || trabajadorId == null) return;
                      context.push(
                        '${RouteNames.workerChat}/$solicitudId',
                        extra: {
                          'solicitudId': solicitudId,
                          'clienteId': s.clienteId,
                          'trabajadorId': trabajadorId,
                        },
                      );
                    },
                    tooltip: 'Chat con cliente',
                  ),
              ],
            ),
            body: s == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppTheme.paddingLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Estado actual ───────────────────────
                              _EstadoCard(vm: vm),
                              const SizedBox(height: 20),

                              // ── Timeline de progreso ────────────────
                              _ProgressTimeline(vm: vm),
                              const SizedBox(height: 20),

                              // ── Detalle del servicio ────────────────
                              _ServiceSummaryCard(solicitud: s),
                              const SizedBox(height: 20),

                              // ── Alerta si finalizado ────────────────
                              if (vm.trabajoFinalizado)
                                _WaitingConfirmationBanner(),
                            ],
                          ),
                        ),
                      ),

                      // ── Barra de acción ─────────────────────────────
                      _ActionBar(vm: vm, solicitud: s),
                    ],
                  ),
            // Error overlay
            bottomSheet: vm.error != null
                ? Container(
                    color: AppColors.errorLight,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

// ── Widgets internos ────────────────────────────────────────────────────────

class _EstadoCard extends StatelessWidget {
  final WorkerServiceTrackingViewModel vm;
  const _EstadoCard({required this.vm});

  Color get _estadoColor {
    switch (vm.estadoActual) {
      case EstadoSolicitud.confirmada:
        return AppColors.estadoConfirmado;
      case EstadoSolicitud.en_camino:
        return AppColors.estadoEnCamino;
      case EstadoSolicitud.ha_llegado:
        return AppColors.estadoHaLlegado;
      case EstadoSolicitud.en_proceso:
        return AppColors.estadoEnProceso;
      case EstadoSolicitud.finalizado_pendiente:
      case EstadoSolicitud.completada:
        return AppColors.estadoCompletado;
      default:
        return AppColors.grey500;
    }
  }

  IconData get _estadoIcon {
    switch (vm.estadoActual) {
      case EstadoSolicitud.en_camino:
        return Icons.directions_run_rounded;
      case EstadoSolicitud.ha_llegado:
        return Icons.location_on_rounded;
      case EstadoSolicitud.en_proceso:
        return Icons.handyman_rounded;
      case EstadoSolicitud.finalizado_pendiente:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: _estadoColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: _estadoColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _estadoColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_estadoIcon, color: _estadoColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado actual',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.estadoActual?.label ?? 'Cargando...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _estadoColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  final WorkerServiceTrackingViewModel vm;
  const _ProgressTimeline({required this.vm});

  static const _steps = [
    (EstadoSolicitud.confirmada, Icons.check_rounded, 'Confirmado'),
    (EstadoSolicitud.en_camino, Icons.directions_run_rounded, 'En camino'),
    (EstadoSolicitud.ha_llegado, Icons.location_on_rounded, 'Ha llegado'),
    (EstadoSolicitud.en_proceso, Icons.handyman_rounded, 'Trabajando'),
    (
      EstadoSolicitud.finalizado_pendiente,
      Icons.done_all_rounded,
      'Finalizado'
    ),
    (EstadoSolicitud.completada, Icons.star_rounded, 'Completado'),
  ];

  @override
  Widget build(BuildContext context) {
    final estadoOrden = EstadoSolicitud.values;
    final currentIdx =
        estadoOrden.indexOf(vm.estadoActual ?? EstadoSolicitud.confirmada);

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progreso del servicio',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final (estado, icon, label) = _steps[i];
            final stepIdx = estadoOrden.indexOf(estado);
            final isDone = stepIdx <= currentIdx;
            final isCurrent = stepIdx == currentIdx;
            final isLast = i == _steps.length - 1;

            // Color semántico por estado
            Color stepColor(EstadoSolicitud e) {
              switch (e) {
                case EstadoSolicitud.confirmada:
                  return AppColors.estadoConfirmado;
                case EstadoSolicitud.en_camino:
                  return AppColors.estadoEnCamino;
                case EstadoSolicitud.ha_llegado:
                  return AppColors.estadoHaLlegado;
                case EstadoSolicitud.en_proceso:
                  return AppColors.estadoEnProceso;
                case EstadoSolicitud.finalizado_pendiente:
                case EstadoSolicitud.completada:
                  return AppColors.estadoCompletado;
                default:
                  return AppColors.grey400;
              }
            }

            final color = isDone ? stepColor(estado) : AppColors.grey300;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? color : AppColors.grey200,
                        border: isCurrent
                            ? Border.all(color: color, width: 2)
                            : null,
                      ),
                      child: Icon(
                        isDone ? icon : Icons.circle_outlined,
                        size: 14,
                        color: isDone ? Colors.white : AppColors.grey400,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 24,
                        color: isDone ? color : AppColors.grey200,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isDone ? AppColors.textPrimary : AppColors.grey400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  final SolicitudServicioModel solicitud;
  const _ServiceSummaryCard({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del servicio',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.grey500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  [solicitud.colonia, solicitud.municipio]
                      .whereType<String>()
                      .join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 16, color: AppColors.grey500),
              const SizedBox(width: 8),
              Text(
                solicitud.montoAcordado != null
                    ? '\$${solicitud.montoAcordado!.toStringAsFixed(2)}'
                    : solicitud.tipoPago.label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaitingConfirmationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Esperando confirmación del cliente',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        )),
                Text(
                  'El cliente debe confirmar que el trabajo quedó completo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final WorkerServiceTrackingViewModel vm;
  final SolicitudServicioModel solicitud;

  const _ActionBar({required this.vm, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    final siguiente = vm.siguienteEstado;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.paddingLg, 12, AppTheme.paddingLg, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!vm.trabajoFinalizado && siguiente != null)
            PrimaryButton(
              label: vm.labelParaEstado(siguiente),
              icon: Icons.arrow_forward_rounded,
              isLoading: vm.isUpdating,
              backgroundColor: AppColors.workerRole,
              onPressed: () async {
                final ok = await vm.avanzarEstado();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No se pudo actualizar el estado.')),
                  );
                }
              },
            ),

          // Calificar al cliente (después de que el cliente confirme)
          if (vm.estadoActual == EstadoSolicitud.completada) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Calificar al cliente',
              icon: Icons.star_rounded,
              backgroundColor: Colors.amber.shade700,
              onPressed: () {
                context.push(
                  '${RouteNames.workerRateClient}/${solicitud.id}',
                  extra: {
                    'solicitudId': solicitud.id,
                    'clienteId': solicitud.clienteId,
                  },
                );
              },
            ),
          ],

          if (vm.trabajoFinalizado &&
              vm.estadoActual != EstadoSolicitud.completada)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Esperando que el cliente confirme la finalización',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
