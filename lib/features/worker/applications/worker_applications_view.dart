/// worker_applications_view.dart
/// Pantalla de solicitudes donde el trabajador se ha postulado.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../state/session_controller.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import 'worker_applications_viewmodel.dart';

class WorkerApplicationsView extends StatelessWidget {
  const WorkerApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerApplicationsViewModel(
        sessionController: ctx.read<SessionController>(),
      )..loadPostulaciones(),
      child: const _ApplicationsContent(),
    );
  }
}

class _ApplicationsContent extends StatelessWidget {
  const _ApplicationsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerApplicationsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Postulaciones'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(children: [
        // ── Filtros ───────────────────────────────────────────
        _FilterChips(vm: vm),
        // ── Lista ─────────────────────────────────────────────
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.items.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_outlined,
                                size: 64, color: AppColors.grey300),
                            const SizedBox(height: 16),
                            Text('No tienes postulaciones aún',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.textSecondary)),
                          ]),
                    )
                  : RefreshIndicator(
                      onRefresh: vm.loadPostulaciones,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.paddingLg),
                        itemCount: vm.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = vm.items[i];
                          return _ApplicationCard(
                            item: item,
                            onTap: () {
                              if (item.solicitud != null) {
                                context.push(
                                  '${RouteNames.workerRequestDetail}/${item.solicitud!.id ?? 'mock'}',
                                  extra: item.solicitud,
                                );
                              }
                            },
                            onChat: () {
                              if (item.solicitud == null) return;
                              context.push(
                                '${RouteNames.workerChat}/new',
                                extra: {
                                  'solicitudId': item.postulacion.solicitudId,
                                  'clienteId': item.solicitud!.clienteId,
                                  'trabajadorId':
                                      item.postulacion.trabajadorId,
                                },
                              );
                            },
                            onTracking: () {
                              if (item.solicitud != null) {
                                context.push(
                                  '${RouteNames.workerServiceTracking}/${item.solicitud!.id ?? 'mock'}',
                                  extra: item.solicitud,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final WorkerApplicationsViewModel vm;
  const _FilterChips({required this.vm});

  @override
  Widget build(BuildContext context) {
    final filtros = <(String, EstadoPostulacion?)>[
      ('Todas', null),
      ('Pendiente', EstadoPostulacion.pendiente),
      ('Aceptadas', EstadoPostulacion.aceptada),
      ('Rechazadas', EstadoPostulacion.rechazada),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((f) {
            final (label, estado) = f;
            final selected = vm.filtroEstado == estado;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => vm.setFiltro(estado),
                selectedColor: AppColors.workerRole.withValues(alpha: 0.15),
                checkmarkColor: AppColors.workerRole,
                labelStyle: TextStyle(
                  color: selected ? AppColors.workerRole : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationItem item;
  final VoidCallback onTap;
  final VoidCallback onChat;
  final VoidCallback onTracking;

  const _ApplicationCard({
    required this.item,
    required this.onTap,
    required this.onChat,
    required this.onTracking,
  });

  Color get _estadoColor {
    switch (item.postulacion.estado) {
      case EstadoPostulacion.aceptada:
        return AppColors.workerRole;
      case EstadoPostulacion.rechazada:
        return AppColors.error;
      case EstadoPostulacion.cancelada:
        return AppColors.grey500;
      default:
        return AppColors.warning;
    }
  }

  String get _estadoLabel {
    switch (item.postulacion.estado) {
      case EstadoPostulacion.aceptada:
        return 'Seleccionado ✓';
      case EstadoPostulacion.rechazada:
        return 'Rechazado';
      case EstadoPostulacion.cancelada:
        return 'Cancelado';
      default:
        return 'En espera';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = item.solicitud;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: [
        // ── Header ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.workerRole.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.assignment_rounded,
                  color: AppColors.workerRole, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s?.categoriaId.toUpperCase() ?? 'Solicitud',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (s != null)
                      Text(
                        s.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _estadoColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusFull),
                border:
                    Border.all(color: _estadoColor.withValues(alpha: 0.4)),
              ),
              child: Text(_estadoLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _estadoColor)),
            ),
          ]),
        ),
        const Divider(height: 1),
        // ── Acciones ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            _ActionBtn(
                icon: Icons.visibility_outlined,
                label: 'Ver',
                onTap: onTap),
            const SizedBox(width: 8),
            _ActionBtn(
                icon: Icons.chat_outlined,
                label: 'Chat',
                onTap: onChat),
            const SizedBox(width: 8),
            if (item.postulacion.estado == EstadoPostulacion.aceptada)
              _ActionBtn(
                  icon: Icons.route_rounded,
                  label: 'Seguimiento',
                  primary: true,
                  onTap: onTracking),
          ]),
        ),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.workerRole,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
