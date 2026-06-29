/// rate_worker_view.dart
/// Pantalla de calificación al trabajador tras completar el servicio.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../state/session_controller.dart';
import 'rate_worker_viewmodel.dart';

class RateWorkerView extends StatefulWidget {
  final WorkerCatalogItemModel? trabajador;
  final String? solicitudId;

  const RateWorkerView({super.key, this.trabajador, this.solicitudId});

  @override
  State<RateWorkerView> createState() => _RateWorkerViewState();
}

class _RateWorkerViewState extends State<RateWorkerView> {
  late final RateWorkerViewModel _vm;
  final _comentarioCtrl = TextEditingController();

  static const _preguntasRapidas = [
    'Fue puntual',
    'Trabajo limpio',
    'Precio justo',
    'Buen trato',
    'Lo recomendaría',
  ];

  @override
  void initState() {
    super.initState();
    _vm = RateWorkerViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trabajador != null) {
        final session = context.read<SessionController>();
        final solicitudId = widget.solicitudId;
        final clienteId = session.currentUser?.id;
        if (solicitudId == null || clienteId == null) return;

        _vm.load(
          trabajador: widget.trabajador!,
          solicitudId: solicitudId,
          clienteId: clienteId,
        );
      }
    });
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<RateWorkerViewModel>(
        builder: (context, vm, _) {
          if (vm.enviado) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.success, size: 56),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '¡Gracias por tu reseña!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu opinión ayuda a mejorar la comunidad de HomeServiceSV.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Volver al inicio',
                        onPressed: () => context.go(RouteNames.clientHome),
                        icon: Icons.home_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Califica al trabajador'),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                children: [
                  // ── Foto y nombre ──────────────────────────
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      widget.trabajador?.nombre.isNotEmpty == true
                          ? widget.trabajador!.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.trabajador?.nombre ?? 'Trabajador',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿Cómo fue tu experiencia?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // ── Estrellas ──────────────────────────────
                  RatingStarsSelector(
                    rating: vm.calificacion,
                    onRatingChanged: vm.setCalificacion,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _labelCalificacion(vm.calificacion),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // ── Preguntas rápidas ──────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selecciona lo que aplica',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _preguntasRapidas.map((p) {
                      final selected = vm.preguntasRapidas.contains(p);
                      return FilterChip(
                        label: Text(p),
                        selected: selected,
                        onSelected: (_) => vm.togglePreguntaRapida(p),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // ── Comentario ────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Comentario (opcional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _comentarioCtrl,
                    onChanged: vm.setComentario,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '¿Qué te pareció el trabajo?',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Guardar favorito ──────────────────────
                  CheckboxListTile(
                    value: vm.guardarFavorito,
                    onChanged: (_) => vm.toggleGuardarFavorito(),
                    title: const Text('Guardar como trabajador favorito'),
                    subtitle: const Text(
                        'Podrás contratarlo fácilmente en el futuro'),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  // ── Error ─────────────────────────────────
                  if (vm.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(vm.error!,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // ── Botón enviar ──────────────────────────
                  PrimaryButton(
                    label: 'Enviar calificación',
                    icon: Icons.send_rounded,
                    onPressed: vm.puedeEnviar ? vm.enviarCalificacion : null,
                    isLoading: vm.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _labelCalificacion(double r) {
    if (r == 0) return 'Toca las estrellas para calificar';
    if (r <= 1) return 'Muy malo';
    if (r <= 2) return 'Malo';
    if (r <= 3) return 'Regular';
    if (r <= 4) return 'Bueno';
    return 'Excelente';
  }
}
