/// booking_confirmation_view.dart
/// Pantalla de confirmación del servicio.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/service_tag.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import 'booking_confirmation_viewmodel.dart';

class BookingConfirmationView extends StatefulWidget {
  final SolicitudServicioModel? solicitud;
  final WorkerCatalogItemModel? trabajador;

  const BookingConfirmationView({
    super.key,
    this.solicitud,
    this.trabajador,
  });

  @override
  State<BookingConfirmationView> createState() => _BookingConfirmationViewState();
}

class _BookingConfirmationViewState extends State<BookingConfirmationView> {
  late final BookingConfirmationViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = BookingConfirmationViewModel();
    if (widget.solicitud != null && widget.trabajador != null) {
      _vm.load(
        solicitud: widget.solicitud!,
        trabajador: widget.trabajador!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<BookingConfirmationViewModel>(
        builder: (context, vm, _) {
          final s = vm.solicitud ?? widget.solicitud;
          final w = vm.trabajador ?? widget.trabajador;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Confirmar servicio'),
              backgroundColor: Colors.transparent,
            ),
            body: s == null || w == null
                ? const Center(child: Text('Sin datos de confirmación'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Card del trabajador ───────────────
                        Container(
                          padding: const EdgeInsets.all(AppTheme.paddingMd),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  w.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(w.nombre,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700)),
                                    if (w.especialidad != null)
                                      Text(w.especialidad!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    if (w.tarifa != null)
                                      Text(
                                        '\$${w.tarifa!.toStringAsFixed(0)}/día',
                                        style:
                                            const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (w.verificado)
                                const Icon(Icons.verified_rounded,
                                    color: AppColors.workerRole, size: 24),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ── Detalles del servicio ─────────────
                        Text('Detalles del servicio',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        _DetailRow(
                            icon: Icons.build_outlined,
                            label: 'Servicio',
                            value: s.categoriaId),
                        const SizedBox(height: 8),
                        _DetailRow(
                            icon: Icons.description_outlined,
                            label: 'Descripción',
                            value: s.descripcion),
                        const SizedBox(height: 8),
                        _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Dirección',
                            value: [s.colonia, s.municipio, s.departamento]
                                .whereType<String>()
                                .join(', ')),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            const Text('Urgencia: ',
                                style: TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13)),
                            ServiceTag.urgencia(s.urgencia),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                            icon: Icons.payments_outlined,
                            label: 'Tipo de pago',
                            value: s.tipoPago.label),
                        const SizedBox(height: 24),
                        // ── Estado ─────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(AppTheme.paddingMd),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estado: Confirmado',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const Text(
                                      'El trabajador ha sido notificado.',
                                      style: TextStyle(
                                          color: AppColors.success, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ── Botones ────────────────────────────
                        PrimaryButton(
                          label: 'Ver seguimiento',
                          icon: Icons.track_changes_rounded,
                          onPressed: () => context.push(
                            '${RouteNames.clientServiceTracking}/${s.id ?? "mock"}',
                            extra: {'solicitud': s, 'trabajador': w},
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {}, // TODO: Chat Fase 3
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Ver chat'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {}, // TODO: Cancelar antes de iniciar
                            icon: const Icon(Icons.cancel_outlined,
                                color: AppColors.error),
                            label: const Text('Cancelar antes de iniciar',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
