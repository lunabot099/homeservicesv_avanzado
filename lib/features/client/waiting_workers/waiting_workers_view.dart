/// waiting_workers_view.dart
/// Pantalla de espera — muestra postulaciones recibidas en tiempo real.
/// El cliente puede seleccionar al trabajador directamente desde aquí.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/service_tag.dart';
import '../../../data/models/perfil_model.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/postulaciones_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';
import 'waiting_workers_viewmodel.dart';

class WaitingWorkersView extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const WaitingWorkersView({super.key, this.solicitud});

  @override
  State<WaitingWorkersView> createState() => _WaitingWorkersViewState();
}

class _WaitingWorkersViewState extends State<WaitingWorkersView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final WaitingWorkersViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WaitingWorkersViewModel();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.solicitud != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _vm.recibirSolicitudCreada(widget.solicitud!);
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WaitingWorkersViewModel>(
        builder: (context, vm, _) {
          if (vm.cancelado || vm.expirada) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                if (vm.expirada) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tu solicitud expiró sin recibir aceptación.'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
                context.go(RouteNames.clientHome);
              }
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Buscando trabajadores'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Volver',
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go(RouteNames.clientHome),
              ),
              backgroundColor: Colors.transparent,
              actions: [
                // Botón refresh prominente
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child:
                      vm.isLoadingPostulaciones
                          ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : IconButton.filled(
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: AppColors.primary,
                            ),
                            tooltip: 'Actualizar ofertas',
                            onPressed: vm.refrescar,
                          ),
                ),
              ],
            ),
            body: Column(
              children: [
                // ── Sección de animación — tamaño fijo ─────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.paddingLg,
                    8,
                    AppTheme.paddingLg,
                    0,
                  ),
                  child: Column(
                    children: [
                      _PulseSearchAnimation(controller: _animController),
                      const SizedBox(height: 14),
                      Text(
                        'Notificando a trabajadores cercanos',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // Indicativo de actualización
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState:
                            vm.trabajadoresInteresados > 0
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        firstChild: Text(
                          '⟳ Actualización en tiempo real activa',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        secondChild: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${vm.trabajadoresInteresados} oferta(s) recibida(s)',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // ── Área scrollable: ofertas + resumen + acciones ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Ofertas recibidas ──────────────────────
                        if (vm.postulaciones.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ofertas recibidas',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          ...vm.postulaciones.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PostulacionCard(
                                postulacion: p,
                                solicitud: widget.solicitud,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ] else ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 48,
                                  color: AppColors.grey300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aún no hay ofertas.\nPulsa ↻ para actualizar.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── Resumen solicitud ──────────────────────
                        if (widget.solicitud != null) ...[
                          _RequestSummaryCard(solicitud: widget.solicitud!),
                          const SizedBox(height: 20),
                        ],

                        // ── Botón ver catálogo completo ────────────
                        if (vm.trabajadoresInteresados > 0) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  () => context.push(
                                    RouteNames.clientWorkersCatalog,
                                    extra: widget.solicitud,
                                  ),
                              icon: const Icon(Icons.people_outline_rounded),
                              label: const Text('Ver ofertas en detalle'),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── Cancelar solicitud ─────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                () => _mostrarDialogoCancelar(context, vm),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancelar solicitud'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarDialogoCancelar(
    BuildContext context,
    WaitingWorkersViewModel vm,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('¿Cancelar solicitud?'),
            content: const Text(
              'Se detendrá la búsqueda de trabajadores y la solicitud quedará cancelada.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No, continuar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );
    if (confirm == true) await vm.cancelarSolicitud();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de postulación — selección directa desde aquí
// ─────────────────────────────────────────────────────────────────────────────

class _PostulacionCard extends StatefulWidget {
  final PostulacionSolicitudModel postulacion;
  final SolicitudServicioModel? solicitud;

  const _PostulacionCard({required this.postulacion, this.solicitud});

  @override
  State<_PostulacionCard> createState() => _PostulacionCardState();
}

class _PostulacionCardState extends State<_PostulacionCard> {
  bool _seleccionando = false;
  PerfilModel? _perfil;
  bool _cargandoPerfil = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final repo = PerfilesRepository();
      final p = await repo.getPerfilById(widget.postulacion.trabajadorId);
      if (mounted) setState(() { _perfil = p; _cargandoPerfil = false; });
    } catch (_) {
      if (mounted) setState(() => _cargandoPerfil = false);
    }
  }

  Future<void> _seleccionarTrabajador() async {
    if (widget.solicitud?.id == null) return;
    setState(() => _seleccionando = true);

    try {
      final solicitudId = widget.solicitud!.id!;
      final postulacionId = widget.postulacion.id;

      // 1. Actualizar solicitud: estado=confirmada + trabajador_seleccionado_id
      final solicitudRepo = SolicitudesRepository();
      final solicitudActualizada = await solicitudRepo.updateEstado(
        id: solicitudId,
        estado: EstadoSolicitud.confirmada,
        trabajadorId: widget.postulacion.trabajadorId,
      );

      // 2. Aceptar postulación elegida + rechazar las demás
      if (postulacionId != null) {
        final postRepo = PostulacionesRepository();
        await postRepo.aceptarTrabajadorYRechazarOtros(
          postulacionId: postulacionId,
          solicitudId: solicitudId,
        );
      }

      // 3. Construir modelo de trabajador para el seguimiento
      final workerModel = WorkerCatalogItemModel(
        trabajadorId: widget.postulacion.trabajadorId,
        nombre: _perfil?.nombreCompleto ?? 'Trabajador',
        fotoUrl: _perfil?.fotoPerfilUrl,
        tarifa: widget.postulacion.precioEstimado,
      );

      if (mounted) {
        context.pushReplacement(
          '${RouteNames.clientServiceTracking}/${solicitudActualizada.id}',
          extra: {
            'solicitud': solicitudActualizada,
            'trabajador': workerModel,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al seleccionar: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _seleccionando = false);
    }
  }

  void _irAlChat() {
    final s = widget.solicitud;
    if (s == null) return;
    final session = context.read<SessionController>();
    context.push(
      '${RouteNames.clientChat}/${s.id ?? 'new'}',
      extra: {
        'solicitudId': s.id ?? 'mock',
        'clienteId': session.currentUser?.id ?? 'mock',
        'trabajadorId': widget.postulacion.trabajadorId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.postulacion;
    final tieneOferta = p.precioEstimado != null;
    final tieneMensaje =
        p.mensajeInicial != null && p.mensajeInicial!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado: avatar + info + estado ──────────────────
          Row(
            children: [
              _cargandoPerfil
                  ? Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.workerRoleLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.workerRoleLight,
                      backgroundImage: _perfil?.fotoPerfilUrl != null
                          ? NetworkImage(_perfil!.fotoPerfilUrl!)
                          : null,
                      child: _perfil?.fotoPerfilUrl == null
                          ? const Icon(
                              Icons.person_rounded,
                              color: AppColors.workerRole,
                              size: 24,
                            )
                          : null,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _perfil?.nombreCompleto ?? 'Trabajador interesado',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _StarRating(calificacion: 0.0, cantidad: 0),
                  ],
                ),
              ),
              _EstadoBadge(estado: p.estado),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Precio ───────────────────────────────────────────────
          if (tieneOferta)
            Row(
              children: [
                const Icon(
                  Icons.attach_money_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Precio estimado: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${p.precioEstimado!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

          // ── Mensaje ──────────────────────────────────────────────
          if (tieneMensaje) ...[
            if (tieneOferta) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.mensajeInicial!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (!tieneOferta && !tieneMensaje) ...[
            Text(
              'El trabajador no incluyó precio ni mensaje.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Botones de acción ────────────────────────────────────
          Row(
            children: [
              // Chat
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _irAlChat,
                  icon: const Icon(Icons.chat_rounded, size: 16),
                  label: const Text('Chatear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Seleccionar
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _seleccionando ? null : _seleccionarTrabajador,
                  icon:
                      _seleccionando
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.check_circle_rounded, size: 16),
                  label: Text(
                    _seleccionando ? 'Seleccionando...' : 'Seleccionar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.estadoConfirmado,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tiempo relativo
          const SizedBox(height: 6),
          Text(
            _fechaRelativa(p.fechaCreacion),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  String _fechaRelativa(DateTime? fecha) {
    if (fecha == null) return 'Hace un momento';
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} día(s)';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double calificacion;
  final int cantidad;

  const _StarRating({required this.calificacion, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final full = i < calificacion.floor();
          final half =
              !full && (calificacion - i) >= 0.5 && (calificacion - i) < 1;
          return Icon(
            full
                ? Icons.star_rounded
                : half
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: 14,
            color: AppColors.estadoConfirmado,
          );
        }),
        const SizedBox(width: 4),
        Text(
          cantidad == 0
              ? '0.0 (0 trabajos)'
              : '${calificacion.toStringAsFixed(1)} ($cantidad trabajos)',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final EstadoPostulacion estado;

  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (estado) {
      case EstadoPostulacion.pendiente:
        color = AppColors.info;
        label = 'Pendiente';
      case EstadoPostulacion.aceptada:
        color = AppColors.success;
        label = 'Aceptada';
      case EstadoPostulacion.rechazada:
        color = AppColors.error;
        label = 'Rechazada';
      case EstadoPostulacion.cancelada:
        color = AppColors.grey500;
        label = 'Cancelada';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animación de pulso
// ─────────────────────────────────────────────────────────────────────────────

class _PulseSearchAnimation extends StatelessWidget {
  final AnimationController controller;

  const _PulseSearchAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ...List.generate(3, (i) {
                final delay = i * 0.33;
                final t = ((controller.value + delay) % 1.0);
                return Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Container(
                    width: 44 + t * 56,
                    height: 44 + t * 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.4 * (1 - t),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumen de solicitud
// ─────────────────────────────────────────────────────────────────────────────

class _RequestSummaryCard extends StatelessWidget {
  final SolicitudServicioModel solicitud;

  const _RequestSummaryCard({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de tu solicitud',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _Row(
            icon: Icons.build_outlined,
            label: 'Servicio',
            value: solicitud.categoriaId,
          ),
          const SizedBox(height: 8),
          _Row(
            icon: Icons.location_on_outlined,
            label: 'Ubicación',
            value: [
              solicitud.colonia,
              solicitud.municipio,
              solicitud.departamento,
            ].whereType<String>().join(', '),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Urgencia: ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              ServiceTag.urgencia(solicitud.urgencia),
            ],
          ),
          const SizedBox(height: 8),
          _Row(
            icon: Icons.payments_outlined,
            label: 'Pago',
            value: solicitud.tipoPago.label,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
