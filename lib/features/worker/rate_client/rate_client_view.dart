/// rate_client_view.dart
/// Pantalla para que el trabajador califique al cliente tras completar el servicio.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../state/session_controller.dart';
import 'rate_client_viewmodel.dart';

class RateClientView extends StatefulWidget {
  final String? solicitudId;
  final String? clienteId;

  const RateClientView({
    super.key,
    this.solicitudId,
    this.clienteId,
  });

  @override
  State<RateClientView> createState() => _RateClientViewState();
}

class _RateClientViewState extends State<RateClientView> {
  late final RateClientViewModel _vm;
  final _comentarioCtrl = TextEditingController();

  static const _adjetivos = [
    'Puntual',
    'Comunicativo',
    'Respetuoso',
    'Buen trato',
    'Paga a tiempo',
    'Lo recomendaría',
  ];

  @override
  void initState() {
    super.initState();
    _vm = RateClientViewModel(
      sessionController: context.read<SessionController>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.load(
        solicitudId: widget.solicitudId ?? 'mock',
        clienteId: widget.clienteId ?? 'mock',
      );
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
      child: Consumer<RateClientViewModel>(
        builder: (context, vm, _) {
          // ── Pantalla de éxito ──────────────────────────────────
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
                        decoration: BoxDecoration(
                          color: AppColors.workerRole.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.workerRole, size: 56),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '¡Gracias por calificar!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu opinión ayuda a construir una comunidad de confianza en HomeServiceSV.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Ir al inicio',
                        onPressed: () => context.go(RouteNames.workerHome),
                        icon: Icons.home_rounded,
                        backgroundColor: AppColors.workerRole,
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
              title: const Text('Califica al cliente'),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                children: [
                  // ── Avatar del cliente ─────────────────────────
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cliente',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿Cómo fue trabajar con este cliente?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // ── Estrellas ──────────────────────────────────
                  RatingStarsSelector(
                    rating: vm.calificacion,
                    onRatingChanged: vm.setCalificacion,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _labelCalificacion(vm.calificacion),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.workerRole,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // ── Adjetivos rápidos ──────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selecciona lo que aplica',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _adjetivos.map((p) {
                      final selected = vm.preguntasRapidas.contains(p);
                      return FilterChip(
                        label: Text(p),
                        selected: selected,
                        onSelected: (_) => vm.togglePregunta(p),
                        selectedColor:
                            AppColors.workerRole.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.workerRole,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.workerRole
                              : AppColors.textPrimary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Comentario ─────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comentario (opcional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _comentarioCtrl,
                    onChanged: vm.setComentario,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '¿Algo que destacar del cliente?',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Error ──────────────────────────────────────
                  if (vm.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(vm.error!,
                          style:
                              const TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Botón enviar ───────────────────────────────
                  PrimaryButton(
                    label: 'Enviar calificación',
                    icon: Icons.send_rounded,
                    backgroundColor: AppColors.workerRole,
                    onPressed: vm.puedeEnviar
                        ? () async {
                            final ok = await vm.enviarCalificacion();
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      vm.error ?? 'Error al enviar.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        : null,
                    isLoading: vm.isLoading,
                  ),
                  const SizedBox(height: 12),

                  // ── Omitir ─────────────────────────────────────
                  TextButton(
                    onPressed: () => context.go(RouteNames.workerHome),
                    child: const Text('Omitir por ahora'),
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

  String _labelCalificacion(double r) {
    if (r == 0) return 'Toca las estrellas para calificar';
    if (r <= 1) return 'Muy difícil';
    if (r <= 2) return 'Poco colaborativo';
    if (r <= 3) return 'Regular';
    if (r <= 4) return 'Buen cliente';
    return 'Excelente cliente';
  }
}
