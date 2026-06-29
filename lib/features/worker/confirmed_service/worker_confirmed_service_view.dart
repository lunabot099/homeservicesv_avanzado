/// worker_confirmed_service_view.dart
/// Vista del servicio confirmado — muestra los detalles del trabajo acordado
/// antes de que el trabajador marque que está en camino.
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
import 'worker_confirmed_service_viewmodel.dart';

class WorkerConfirmedServiceView extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const WorkerConfirmedServiceView({super.key, this.solicitud});

  @override
  State<WorkerConfirmedServiceView> createState() =>
      _WorkerConfirmedServiceViewState();
}

class _WorkerConfirmedServiceViewState
    extends State<WorkerConfirmedServiceView> {
  late final WorkerConfirmedServiceViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WorkerConfirmedServiceViewModel();
    if (widget.solicitud != null) {
      _vm.load(solicitud: widget.solicitud!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WorkerConfirmedServiceViewModel>(
        builder: (context, vm, _) {
          final s = vm.solicitud ?? widget.solicitud;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Servicio confirmado'),
              backgroundColor: Colors.transparent,
            ),
            body: s == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Banner de confirmación ───────────────────
                        _ConfirmedBanner(),
                        const SizedBox(height: 24),

                        // ── Detalle del servicio ─────────────────────
                        _SectionTitle(title: 'Detalles del servicio'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              icon: Icons.miscellaneous_services_rounded,
                              label: 'Categoría',
                              value: s.categoriaId.toUpperCase(),
                            ),
                            _InfoRow(
                              icon: Icons.description_outlined,
                              label: 'Descripción',
                              value: s.descripcion,
                            ),
                            _InfoRow(
                              icon: Icons.access_time_rounded,
                              label: 'Urgencia',
                              value: s.urgencia.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Dirección ───────────────────────────────
                        _SectionTitle(title: 'Dirección del servicio'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              icon: Icons.location_on_rounded,
                              label: 'Dirección',
                              value: vm.direccionCompleta.isNotEmpty
                                  ? vm.direccionCompleta
                                  : 'Dirección no especificada',
                              multiline: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Pago ─────────────────────────────────────
                        _SectionTitle(title: 'Información de pago'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              icon: Icons.payments_outlined,
                              label: 'Método de pago',
                              value: vm.metodoPago,
                            ),
                            _InfoRow(
                              icon: Icons.attach_money_rounded,
                              label: 'Monto acordado',
                              value: vm.montoAcordadoLabel,
                              valueStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.workerRole,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Botón: Ir a Chat ──────────────────────────
                        // Nota: el chat es 1:1 con la solicitud; usamos s.id
                        // como referencia hasta disponer de un chatId explícito.
                        OutlinedButton.icon(
                          onPressed: () {
                            final session = context.read<SessionController>();
                            final solicitudId = s.id;
                            final trabajadorId = session.currentUser?.id;
                            if (solicitudId == null || trabajadorId == null) {
                              return;
                            }
                            context.push(
                              '${RouteNames.workerChat}/$solicitudId',
                              extra: {
                                'solicitudId': solicitudId,
                                'clienteId': s.clienteId,
                                'trabajadorId': trabajadorId,
                              },
                            );
                          },
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text('Hablar con el cliente'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Botón: Iniciar servicio ──────────────────
                        PrimaryButton(
                          label: 'Marcar: Estoy en camino',
                          icon: Icons.directions_run_rounded,
                          onPressed: () {
                            final solicitudId = s.id;
                            if (solicitudId == null) return;
                            context.pushReplacement(
                              '${RouteNames.workerServiceTracking}/$solicitudId',
                              extra: s,
                            );
                          },
                          backgroundColor: AppColors.workerRole,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ── Widgets internos ───────────────────────────────────────────────────────

class _ConfirmedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.workerRole, Color(0xFF0A7A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.workerRole.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Servicio confirmado!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'El cliente te ha seleccionado. Revisa los detalles y comunícate cuando estés listo.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

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
        children: children
            .expand(
              (w) => [w, if (w != children.last) const Divider(height: 20)],
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.grey500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
