/// service_selection_view.dart
/// Pantalla de selección de subcategoría de servicio.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../state/session_controller.dart';
import 'service_selection_viewmodel.dart';

class ServiceSelectionView extends StatelessWidget {
  final String categoryId;

  const ServiceSelectionView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceSelectionViewModel()..loadCategoria(categoryId),
      child: const _ServiceSelectionContent(),
    );
  }
}

class _ServiceSelectionContent extends StatelessWidget {
  const _ServiceSelectionContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceSelectionViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(vm.categoria?.nombre ?? 'Seleccionar servicio'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Indicador de pasos ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: StepIndicator(totalSteps: 4, currentStep: 1),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Paso 1: ¿Qué tipo de servicio necesitas?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Lista de subcategorías ────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: vm.subcategorias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final sub = vm.subcategorias[i];
                final isSelected = vm.subcategoriaSeleccionada?.id == sub.id;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => vm.selectSubcategoria(sub),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sub.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ── Campo "Otro" personalizado ──────────────────
          if (vm.mostrarCampoPersonalizado)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: TextField(
                onChanged: vm.setDescripcionPersonalizada,
                decoration: const InputDecoration(
                  labelText: '¿Qué necesitas específicamente?',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                maxLines: 2,
                autofocus: true,
              ),
            ),
          // ── Botón continuar ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: PrimaryButton(
              label: 'Continuar',
              icon: Icons.arrow_forward_rounded,
              onPressed: vm.puedeAvanzar
                  ? () {
                      final session = context.read<SessionController>();
                      vm.prepararSolicitud(session.currentUser!.id);
                      context.push(
                        RouteNames.clientRequestForm,
                        extra: vm.solicitudEnConstruccion,
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
