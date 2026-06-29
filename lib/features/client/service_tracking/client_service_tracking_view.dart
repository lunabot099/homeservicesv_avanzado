/// client_service_tracking_view.dart
/// Seguimiento en tiempo real del servicio en curso.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/service_tag.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/reporte_servicio_model.dart';
import 'client_service_tracking_viewmodel.dart';

class ClientServiceTrackingView extends StatefulWidget {
  final String? solicitudId;
  final SolicitudServicioModel? solicitud;
  final WorkerCatalogItemModel? trabajador;

  const ClientServiceTrackingView({
    super.key,
    this.solicitudId,
    this.solicitud,
    this.trabajador,
  });

  @override
  State<ClientServiceTrackingView> createState() =>
      _ClientServiceTrackingViewState();
}

class _ClientServiceTrackingViewState extends State<ClientServiceTrackingView> {
  late final ClientServiceTrackingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ClientServiceTrackingViewModel();
    if (widget.solicitud != null) {
      _vm.load(solicitud: widget.solicitud!, trabajador: widget.trabajador);
    } else if (widget.solicitudId != null) {
      _vm.loadById(widget.solicitudId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ClientServiceTrackingViewModel>(
        builder: (context, vm, _) {
          final s = vm.solicitud ?? widget.solicitud;
          final w = vm.trabajador ?? widget.trabajador;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) context.go(RouteNames.clientHome);
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go(RouteNames.clientHome),
                ),
                title: const Text('Seguimiento del servicio'),
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.support_agent_rounded),
                    onPressed: () {}, // TODO: Soporte Fase 3
                    tooltip: 'Ayuda/Soporte',
                  ),
                ],
              ),
              body: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                      ? _TrackingError(message: vm.error!)
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.all(AppTheme.paddingLg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (s != null)
                                      _StatusCard(
                                        estado: s.estado,
                                        onUpdate: (estado) =>
                                            vm.updateEstado(estado),
                                      ),
                                    const SizedBox(height: 20),
                                    if (w != null) _WorkerInfoCard(worker: w),
                                    const SizedBox(height: 20),
                                    if (s?.estado ==
                                        EstadoSolicitud
                                            .finalizado_pendiente) ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            await vm.finalizarTrabajo();
                                            if (context.mounted) {
                                              context.push(
                                                '${RouteNames.clientRateWorker}/${s!.id ?? "mock"}',
                                                extra: {
                                                  'trabajador': w,
                                                  'solicitudId': s.id ?? 'mock',
                                                },
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.check_circle_rounded),
                                          label: const Text(
                                              'Confirmar finalización'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            minimumSize:
                                                const Size.fromHeight(52),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    OutlinedButton.icon(
                                      onPressed: () => vm.toggleReportSheet(),
                                      icon: const Icon(
                                        Icons.flag_outlined,
                                        color: AppColors.error,
                                      ),
                                      label: const Text(
                                        'Reportar problema',
                                        style:
                                            TextStyle(color: AppColors.error),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
              bottomSheet: vm.showReportSheet
                  ? _ReportSheet(vm: vm, solicitudId: s?.id)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _TrackingError extends StatelessWidget {
  final String message;

  const _TrackingError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.clientHome),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final EstadoSolicitud estado;
  final void Function(EstadoSolicitud) onUpdate;

  const _StatusCard({required this.estado, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado actual',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ServiceTag.estado(estado),
          const SizedBox(height: 16),
          // Progress visual de estados
          _StatusTimeline(currentEstado: estado),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final EstadoSolicitud currentEstado;

  const _StatusTimeline({required this.currentEstado});

  static const _steps = [
    (EstadoSolicitud.confirmada, 'Confirmado'),
    (EstadoSolicitud.en_camino, 'En camino'),
    (EstadoSolicitud.ha_llegado, 'Ha llegado'),
    (EstadoSolicitud.en_proceso, 'En proceso'),
    (EstadoSolicitud.completada, 'Completado'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexWhere((s) => s.$1 == currentEstado);

    return Column(
      children: List.generate(_steps.length, (i) {
        final (_, label) = _steps[i];
        final isDone = i <= currentIdx;
        final isCurrent = i == currentIdx;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : AppColors.grey300,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                if (i < _steps.length - 1)
                  Container(
                      width: 2,
                      height: 24,
                      color: isDone ? AppColors.primary : AppColors.grey300),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isDone ? AppColors.primary : AppColors.grey500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _WorkerInfoCard extends StatelessWidget {
  final WorkerCatalogItemModel worker;

  const _WorkerInfoCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            backgroundImage:
                worker.fotoUrl != null ? NetworkImage(worker.fotoUrl!) : null,
            child: worker.fotoUrl == null
                ? Text(
                    worker.nombre.isNotEmpty
                        ? worker.nombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (worker.tiempoEstimadoLlegada != null)
                  Text('Llega en ~${worker.tiempoEstimadoLlegada} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // TODO: Chat directo Fase 3
            icon: const Icon(Icons.chat_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  final ClientServiceTrackingViewModel vm;
  final String? solicitudId;

  const _ReportSheet({required this.vm, this.solicitudId});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  MotivoReporte? _motivo;
  final _descripcionCtrl = TextEditingController();

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reportar problema',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: widget.vm.hideReportSheet,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RadioGroup<MotivoReporte>(
            groupValue: _motivo,
            onChanged: (v) => setState(() => _motivo = v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MotivoReporte.values
                  .map((m) => RadioListTile<MotivoReporte>(
                        title: Text(
                          m.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: m,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descripcionCtrl,
            decoration: const InputDecoration(
              hintText: 'Descripción adicional (opcional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _motivo == null
                  ? null
                  : () async {
                      await widget.vm.enviarReporte(
                        motivo: _motivo!.name,
                        descripcion: _descripcionCtrl.text.isEmpty
                            ? null
                            : _descripcionCtrl.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Enviar reporte'),
            ),
          ),
        ],
      ),
    );
  }
}
