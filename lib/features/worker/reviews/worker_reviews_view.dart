/// worker_reviews_view.dart
/// Pantalla de reseñas recibidas por el trabajador.
/// Muestra promedio, total y lista individual de calificaciones de clientes.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/resena_model.dart';
import '../../../state/session_controller.dart';
import 'worker_reviews_viewmodel.dart';

class WorkerReviewsView extends StatelessWidget {
  const WorkerReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerReviewsViewModel(
        sessionController: ctx.read<SessionController>(),
      )..loadResenas(),
      child: const _WorkerReviewsContent(),
    );
  }
}

class _WorkerReviewsContent extends StatelessWidget {
  const _WorkerReviewsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerReviewsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis reseñas'),
        backgroundColor: Colors.transparent,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.loadResenas,
              child: CustomScrollView(
                slivers: [
                  // ── Resumen de calificación ────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingLg),
                      child: _RatingSummaryCard(vm: vm),
                    ),
                  ),

                  if (vm.resenas.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.star_border_rounded,
                        title: 'Sin reseñas todavía',
                        subtitle:
                            'Las calificaciones de tus clientes aparecerán aquí.',
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ResenaCard(resena: vm.resenas[i]),
                            );
                          },
                          childCount: vm.resenas.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            ),
    );
  }
}

// ── Widgets internos ────────────────────────────────────────────────────────

class _RatingSummaryCard extends StatelessWidget {
  final WorkerReviewsViewModel vm;
  const _RatingSummaryCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final promedio = vm.promedio;

    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calificación promedio',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      promedio.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ 5.0',
                        style: TextStyle(color: Colors.white60, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < promedio.floor()
                          ? Icons.star_rounded
                          : (i < promedio
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded),
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${vm.totalResenas}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const Text(
                'reseñas',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResenaCard extends StatelessWidget {
  final ResenaModel resena;
  const _ResenaCard({required this.resena});

  @override
  Widget build(BuildContext context) {
    final stars = resena.calificacion;

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
          Row(
            children: [
              // Avatar cliente
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    if (resena.fechaCreacion != null)
                      Text(
                        _formatFecha(resena.fechaCreacion!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
              // Estrellas
              Row(
                children: [
                  Text(
                    stars.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                ],
              ),
            ],
          ),

          // Comentario
          if (resena.comentario?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              '"${resena.comentario!}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
            ),
          ],

          // Etiquetas rápidas
          if (resena.preguntasRapidas?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: resena.preguntasRapidas!
                  .map((p) => Chip(
                        label: Text(p),
                        labelStyle: const TextStyle(fontSize: 11),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            AppColors.workerRole.withValues(alpha: 0.08),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFecha(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
