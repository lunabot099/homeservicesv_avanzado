/// worker_home_view.dart
/// Home principal del trabajador — Fase 3.
/// Grid/lista de solicitudes disponibles + saludo + toggle disponibilidad + BottomNavBar.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../state/session_controller.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import 'worker_home_viewmodel.dart';

class WorkerHomeView extends StatelessWidget {
  const WorkerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerHomeViewModel(
        sessionController: ctx.read<SessionController>(),
      )..iniciarActualizacionAutomatica(),
      child: const _WorkerHomeContent(),
    );
  }
}

class _WorkerHomeContent extends StatefulWidget {
  const _WorkerHomeContent();
  @override
  State<_WorkerHomeContent> createState() => _WorkerHomeContentState();
}

class _WorkerHomeContentState extends State<_WorkerHomeContent> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.workerRole.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.handyman_rounded,
                color: AppColors.workerRole, size: 20),
          ),
          const SizedBox(width: 8),
          const Text('HomeServiceSV'),
        ]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<SessionController>().signOut();
              if (context.mounted) context.go(RouteNames.roleSelector);
            },
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, vm),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBody(BuildContext context, WorkerHomeViewModel vm) {
    switch (_navIndex) {
      case 0:
        return _HomeTab(vm: vm);
      case 1:
        return _navTab(context,
            icon: Icons.assignment_rounded,
            label: 'Mis Solicitudes',
            route: RouteNames.workerApplications);
      case 2:
        return _navTab(context,
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Mensajes',
            route: RouteNames.workerMessages);
      case 3:
        return _navTab(context,
            icon: Icons.person_outline_rounded,
            label: 'Mi Perfil',
            route: RouteNames.workerProfile);
      default:
        return const SizedBox();
    }
  }

  Widget _navTab(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 56, color: AppColors.grey300),
        const SizedBox(height: 16),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push(route),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text('Ir a $label'),
        ),
      ]),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _navIndex,
      onDestinationSelected: (i) {
        if (i == 1) {
          context.push(RouteNames.workerApplications);
          return;
        }
        if (i == 2) {
          context.push(RouteNames.workerMessages);
          return;
        }
        if (i == 3) {
          context.push(RouteNames.workerProfile);
          return;
        }
        setState(() => _navIndex = i);
      },
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryLight,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Solicitudes',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Mensajes',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  final WorkerHomeViewModel vm;
  const _HomeTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: vm.loadSolicitudesDisponibles,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingCard(vm: vm),
                  const SizedBox(height: 20),
                  _DisponibilidadToggle(vm: vm),
                  const SizedBox(height: 20),
                  Text(
                    'Solicitudes disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se actualizan automáticamente cuando entra una solicitud.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (vm.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vm.solicitudesDisponibles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppColors.grey300),
                  const SizedBox(height: 12),
                  Text('No hay solicitudes disponibles ahora',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                ]),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final s = vm.solicitudesDisponibles[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingLg, vertical: 6),
                    child: _SolicitudDisponibleCard(
                      solicitud: s,
                      onTap: () => context.push(
                        '${RouteNames.workerRequestDetail}/${s.id ?? 'mock'}',
                        extra: s,
                      ),
                    ),
                  );
                },
                childCount: vm.solicitudesDisponibles.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final WorkerHomeViewModel vm;
  const _GreetingCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
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
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vm.saludo,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            if (vm.promedioCalificacion != null)
              Row(children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${vm.promedioCalificacion!.toStringAsFixed(1)} (${vm.cantidadResenas ?? 0} reseñas)',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ])
            else
              const Text('Listo para trabajar',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
        ),
      ]),
    );
  }
}

class _DisponibilidadToggle extends StatelessWidget {
  final WorkerHomeViewModel vm;
  const _DisponibilidadToggle({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: vm.disponible ? AppColors.workerRole : AppColors.grey300,
          width: 1.5,
        ),
      ),
      child: Row(children: [
        Icon(
          vm.disponible ? Icons.check_circle_rounded : Icons.cancel_outlined,
          color: vm.disponible ? AppColors.workerRole : AppColors.grey400,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              vm.disponible ? 'Disponible para trabajar' : 'No disponible',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: vm.disponible
                        ? AppColors.workerRole
                        : AppColors.grey600,
                  ),
            ),
            Text(
              vm.disponible
                  ? 'Los clientes pueden verte y contactarte.'
                  : 'No recibirás nuevas solicitudes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ]),
        ),
        Switch(
          value: vm.disponible,
          onChanged: (_) => vm.toggleDisponibilidad(),
          activeThumbColor: AppColors.workerRole,
        ),
      ]),
    );
  }
}

class _SolicitudDisponibleCard extends StatelessWidget {
  final SolicitudServicioModel solicitud;
  final VoidCallback onTap;

  const _SolicitudDisponibleCard({
    required this.solicitud,
    required this.onTap,
  });

  Color get _urgenciaColor {
    switch (solicitud.urgencia) {
      case UrgenciaSolicitud.urgente:
        return AppColors.error;
      case UrgenciaSolicitud.hoy:
        return AppColors.warning;
      case UrgenciaSolicitud.manana:
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      solicitud.categoriaId.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _urgenciaColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                          color: _urgenciaColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      solicitud.urgencia.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _urgenciaColor),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  solicitud.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    [solicitud.colonia, solicitud.municipio]
                        .whereType<String>()
                        .join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.payments_outlined,
                      size: 14, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    solicitud.presupuestoEstimado != null
                        ? '\$${solicitud.presupuestoEstimado!.toStringAsFixed(0)}'
                        : solicitud.tipoPago.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Ver detalle',
                      style: TextStyle(
                          color: AppColors.workerRole,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppColors.workerRole),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
