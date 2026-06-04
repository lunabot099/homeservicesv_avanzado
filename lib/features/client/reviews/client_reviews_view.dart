/// client_reviews_view.dart
/// Pantalla de historial de reseñas del cliente.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../state/session_controller.dart';
import 'client_reviews_viewmodel.dart';

class ClientReviewsView extends StatefulWidget {
  const ClientReviewsView({super.key});

  @override
  State<ClientReviewsView> createState() => _ClientReviewsViewState();
}

class _ClientReviewsViewState extends State<ClientReviewsView> {
  late final ClientReviewsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ClientReviewsViewModel(
      sessionController: context.read<SessionController>(),
    );
    _vm.loadResenas();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ClientReviewsViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Mis Reseñas'),
            backgroundColor: Colors.transparent,
          ),
          body: vm.isLoading
              ? const LoadingView(message: 'Cargando reseñas...')
              : Column(
                  children: [
                    // ── Header con promedio ─────────────────────
                    if (vm.resenas.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(AppTheme.paddingLg),
                        padding: const EdgeInsets.all(AppTheme.paddingLg),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.promedioCalificacion.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  RatingStars(
                                      rating: vm.promedioCalificacion,
                                      size: 18),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vm.resenas.length} reseñas enviadas',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.star_rounded,
                                color: Colors.white30, size: 80),
                          ],
                        ),
                      ),
                    // ── Lista de reseñas ───────────────────────
                    Expanded(
                      child: vm.resenas.isEmpty
                          ? EmptyState(
                              icon: Icons.star_outline_rounded,
                              title: 'Sin reseñas aún',
                              subtitle:
                                  'Califica a los trabajadores después de cada servicio.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppTheme.paddingLg),
                              itemCount: vm.resenas.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final r = vm.resenas[i];
                                return Container(
                                  padding: const EdgeInsets.all(AppTheme.paddingMd),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusMd),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          RatingStars(
                                              rating: r.calificacion, size: 16),
                                          const Spacer(),
                                          Text(
                                            r.fechaCreacion != null
                                                ? _dateLabel(r.fechaCreacion!)
                                                : '',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      if (r.comentario != null) ...[
                                        const SizedBox(height: 8),
                                        Text(r.comentario!,
                                            style: const TextStyle(fontSize: 13)),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
