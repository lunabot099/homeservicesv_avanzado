/// worker_card.dart
/// Tarjeta de trabajador para el catálogo de postulantes.
library;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/postulacion_solicitud_model.dart';
import 'rating_stars.dart';

class WorkerCard extends StatelessWidget {
  final WorkerCatalogItemModel worker;
  final VoidCallback onTap;
  final VoidCallback? onSelect;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: worker.fotoUrl != null
                          ? NetworkImage(worker.fotoUrl!)
                          : null,
                      child: worker.fotoUrl == null
                          ? Text(
                              worker.nombre.isNotEmpty
                                  ? worker.nombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Nombre y especialidad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.nombre,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (worker.especialidad != null)
                            Text(
                              worker.especialidad!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    // Etiquetas Verificado/Destacado
                    if (worker.verificado || worker.destacado)
                      Column(
                        children: [
                          if (worker.destacado)
                            _Badge(label: 'Destacado', color: AppColors.accent),
                          if (worker.verificado)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _Badge(
                                  label: 'Verificado',
                                  color: AppColors.workerRole),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Estrellas ─────────────────────────────────
                Row(
                  children: [
                    RatingStars(rating: worker.calificacion, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${worker.calificacion.toStringAsFixed(1)} (${worker.cantidadResenas})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Info (distancia, tiempo, tarifa) ──────────
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: worker.distanciaKm != null
                          ? '${worker.distanciaKm!.toStringAsFixed(1)} km'
                          : '—',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: worker.tiempoEstimadoLlegada != null
                          ? '~${worker.tiempoEstimadoLlegada} min'
                          : '—',
                    ),
                    const Spacer(),
                    if (worker.tarifa != null)
                      Text(
                        '\$${worker.tarifa!.toStringAsFixed(0)}/día',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                  ],
                ),
                if (onSelect != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Text('Seleccionar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
