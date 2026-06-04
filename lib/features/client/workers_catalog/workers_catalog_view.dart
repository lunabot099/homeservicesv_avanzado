/// workers_catalog_view.dart
/// Catálogo de trabajadores interesados en la solicitud.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/worker_card.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import 'workers_catalog_viewmodel.dart';

class WorkersCatalogView extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const WorkersCatalogView({super.key, this.solicitud});

  @override
  State<WorkersCatalogView> createState() => _WorkersCatalogViewState();
}

class _WorkersCatalogViewState extends State<WorkersCatalogView> {
  late final WorkersCatalogViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = WorkersCatalogViewModel();
    if (widget.solicitud != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _vm.loadWorkers(widget.solicitud!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<WorkersCatalogViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Trabajadores disponibles'),
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              // ── Filtros ─────────────────────────────────────
              _FilterBar(vm: vm),
              // ── Lista ───────────────────────────────────────
              Expanded(
                child: vm.isLoading
                    ? const LoadingView(message: 'Cargando trabajadores...')
                    : vm.workers.isEmpty
                        ? EmptyState(
                            icon: Icons.person_search_rounded,
                            title: 'No hay trabajadores disponibles',
                            subtitle:
                                'Aún no hay trabajadores interesados en tu solicitud.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppTheme.paddingLg),
                            itemCount: vm.workers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final worker = vm.workers[i];
                              return WorkerCard(
                                worker: worker,
                                onTap: () => context.push(
                                  '${RouteNames.clientWorkerProfile}/${worker.trabajadorId}',
                                  extra: worker,
                                ),
                                onSelect: () {
                                  vm.selectWorker(worker);
                                  context.push(
                                    RouteNames.clientBookingConfirmation,
                                    extra: {
                                      'solicitud': vm.solicitud,
                                      'trabajador': worker,
                                    },
                                  );
                                },
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
}

class _FilterBar extends StatelessWidget {
  final WorkersCatalogViewModel vm;

  const _FilterBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: CatalogFilter.values.map((f) {
          final isSelected = vm.filtro == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_labelForFilter(f)),
              selected: isSelected,
              onSelected: (_) => vm.setFiltro(f),
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelForFilter(CatalogFilter f) {
    switch (f) {
      case CatalogFilter.mejorCalificados:
        return '⭐ Mejor calificados';
      case CatalogFilter.masCercanos:
        return '📍 Más cercanos';
      case CatalogFilter.menorPrecio:
        return '💲 Menor precio';
      case CatalogFilter.mayorExperiencia:
        return '🏆 Mayor experiencia';
    }
  }
}
