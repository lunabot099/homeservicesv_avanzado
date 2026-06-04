/// worker_profile_detail_view.dart
/// Perfil completo de un trabajador — visto desde el catálogo del cliente.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import 'worker_profile_detail_viewmodel.dart';

class WorkerProfileDetailView extends StatefulWidget {
  final WorkerCatalogItemModel worker;

  const WorkerProfileDetailView({super.key, required this.worker});

  @override
  State<WorkerProfileDetailView> createState() =>
      _WorkerProfileDetailViewState();
}

class _WorkerProfileDetailViewState extends State<WorkerProfileDetailView> {
  late final WorkerProfileDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WorkerProfileDetailViewModel();
    _vm.loadWorker(widget.worker);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WorkerProfileDetailViewModel>(
        builder: (context, vm, _) {
          final w = vm.worker ?? widget.worker;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                // ── SliverAppBar con foto ─────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        w.fotoUrl != null
                            ? Image.network(w.fotoUrl!, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.primaryDark,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (w.especialidad != null)
                                Text(
                                  w.especialidad!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Contenido ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calificación
                        Row(
                          children: [
                            RatingStars(rating: w.calificacion, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              '${w.calificacion.toStringAsFixed(1)} (${w.cantidadResenas} trabajos)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (w.verificado)
                              _StatusBadge(
                                label: '✓ DUI Verificado',
                                color: AppColors.workerRole,
                              ),
                            if (w.verificado)
                              _StatusBadge(
                                label: '✓ Perfil Aprobado',
                                color: AppColors.primary,
                              ),
                            if (w.disponible)
                              _StatusBadge(
                                label: '● Disponible',
                                color: AppColors.success,
                              )
                            else
                              _StatusBadge(
                                label: '● Ocupado',
                                color: AppColors.error,
                              ),
                            if (w.destacado)
                              _StatusBadge(label: '⭐ Destacado', color: AppColors.accent),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Sobre mí
                        _SectionTitle(title: 'Sobre mí'),
                        const SizedBox(height: 8),
                        Text(
                          'Trabajador profesional con amplia experiencia en ${w.especialidad ?? "servicios del hogar"}. '
                          'Comprometido con la calidad y puntualidad.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        // Tarifas
                        _SectionTitle(title: 'Tarifas aproximadas'),
                        const SizedBox(height: 8),
                        if (w.tarifa != null)
                          _InfoRow(
                            icon: Icons.attach_money_rounded,
                            label: 'Por día',
                            value: '\$${w.tarifa!.toStringAsFixed(0)}',
                          ),
                        const SizedBox(height: 8),
                        if (w.tiempoEstimadoLlegada != null)
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Tiempo de llegada',
                            value: '~${w.tiempoEstimadoLlegada} minutos',
                          ),
                        const SizedBox(height: 8),
                        if (w.distanciaKm != null)
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Distancia',
                            value: '${w.distanciaKm!.toStringAsFixed(1)} km',
                          ),
                        const SizedBox(height: 20),
                        // Reseñas
                        _SectionTitle(title: 'Comentarios de clientes'),
                        const SizedBox(height: 8),
                        if (vm.resenas.isEmpty)
                          Text(
                            'Aún no tiene reseñas.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        const SizedBox(height: 80), // espacio para botones
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ── Botones flotantes ─────────────────────────────
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navegar a chat con trabajador (Fase 3)
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Chatear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Seleccionar'),
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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
