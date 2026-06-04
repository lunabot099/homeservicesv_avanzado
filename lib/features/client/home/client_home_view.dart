/// client_home_view.dart
/// Home principal del cliente — Fase 2: grid de categorías + BottomNav.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/category_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../state/session_controller.dart';
import 'client_home_viewmodel.dart';
import '../../../core/utils/icon_mapper.dart';

class ClientHomeView extends StatelessWidget {
  const ClientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientHomeViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _ClientHomeContent(),
    );
  }
}

class _ClientHomeContent extends StatefulWidget {
  const _ClientHomeContent();

  @override
  State<_ClientHomeContent> createState() => _ClientHomeContentState();
}

class _ClientHomeContentState extends State<_ClientHomeContent> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar solicitud activa en background para mostrar acceso rápido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientHomeViewModel>().cargarSolicitudActiva();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_repair_service_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('HomeServiceSV'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {}, // TODO: Fase 3
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, vm),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBody(BuildContext context, ClientHomeViewModel vm) {
    switch (_currentNavIndex) {
      case 0:
        return _HomeTab(vm: vm);
      case 1:
        return _buildPlaceholderTab(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Mensajes',
          subtitle: 'Tus conversaciones con trabajadores aparecerán aquí.',
          onTap: () => context.push(RouteNames.clientMessages),
        );
      case 2:
        return _buildPlaceholderTab(
          context,
          icon: Icons.star_outline_rounded,
          label: 'Mis Reseñas',
          subtitle: 'Lleva registro de tus calificaciones a trabajadores.',
          onTap: () => context.push(RouteNames.clientReviews),
        );
      case 3:
        return _buildPlaceholderTab(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Mi Perfil',
          subtitle: 'Gestiona tu información personal.',
          onTap: () => context.push(RouteNames.clientProfile),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentNavIndex,
      onDestinationSelected: (i) {
        // Para mensajes, reseñas y perfil navegamos directamente a la pantalla completa
        if (i == 1) {
          context.push(RouteNames.clientMessages);
          return;
        }
        if (i == 2) {
          context.push(RouteNames.clientReviews);
          return;
        }
        if (i == 3) {
          context.push(RouteNames.clientProfile);
          return;
        }
        setState(() => _currentNavIndex = i);
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
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Mensajes',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outline_rounded),
          selectedIcon: Icon(Icons.star_rounded),
          label: 'Reseñas',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            label: Text('Ir a $label'),
          ),
        ],
      ),
    );
  }
}

/// Tab principal — saludo + categorías
class _HomeTab extends StatelessWidget {
  final ClientHomeViewModel vm;

  const _HomeTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Saludo y calificación ─────────────────────────
          _buildGreetingCard(context),
          const SizedBox(height: 16),
          // ── Acceso rápido si hay solicitud activa ─────────
          if (vm.solicitudActiva != null)
            _SolicitudActivaCard(vm: vm),
          if (vm.solicitudActiva != null) const SizedBox(height: 16),
          // ── Guía de uso ───────────────────────────────────
          Text(
            'Selecciona el servicio que necesitas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Conectamos con trabajadores verificados en tu zona.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // ── Grid de categorías ────────────────────────────
          _buildCategoryGrid(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
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
            color: AppColors.primary.withValues(alpha: 0.3),
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
                Text(
                  vm.saludo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (vm.promedioCalificacion != null && vm.cantidadResenas != null)
                  Row(
                    children: [
                      RatingStars(
                          rating: vm.promedioCalificacion!, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${vm.promedioCalificacion!.toStringAsFixed(1)} (${vm.cantidadResenas} reseñas)',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  )
                else
                  const Text(
                    '¿Qué servicio necesitas hoy?',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: vm.categorias.length,
      itemBuilder: (context, index) {
        final cat = vm.categorias[index];
        return CategoryCard(
          id: cat.id,
          nombre: cat.nombre,
          icon: IconMapper.fromString(cat.iconoCodigo),
          color: _colorForIndex(index),
          onTap: () => context.push(
            '${RouteNames.clientServiceSelection}/${cat.id}',
          ),
        );
      },
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.workerRole,
      AppColors.info,
      AppColors.warning,
      AppColors.error,
      AppColors.primary,
      AppColors.accent,
      AppColors.workerRole,
    ];
    return colors[i % colors.length];
  }
}

// ── Widget de acceso rápido ─────────────────────────────────────────

/// Muestra accesos rápidos según el estado de la solicitud activa.
class _SolicitudActivaCard extends StatelessWidget {
  final ClientHomeViewModel vm;
  const _SolicitudActivaCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = vm.solicitudActiva!;
    final enBusqueda = vm.enBusqueda;
    final enServicio = vm.enServicio;
    final tieneChatActivo = vm.chatActivo != null;

    // Color y ícono según estado
    final Color headerColor =
        enBusqueda ? AppColors.warning : AppColors.primary;
    final IconData headerIcon = enBusqueda
        ? Icons.search_rounded
        : Icons.home_repair_service_rounded;
    final String headerLabel = enBusqueda
        ? 'Buscando trabajador'
        : s.estado.label;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: headerColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado de estado ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Icon(headerIcon, color: headerColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headerLabel,
                    style: TextStyle(
                      color: headerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Indicador de estado pulsante para en búsqueda
                if (enBusqueda)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: headerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          // ── Descripción del servicio ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              s.descripcion.isNotEmpty
                  ? s.descripcion
                  : s.categoriaId.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          // ── Botones de acción ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                // CTA principal según estado
                if (enBusqueda)
                  _QuickBtn(
                    label: 'Ver ofertas',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push(
                      RouteNames.clientWaitingWorkers,
                      extra: s,
                    ),
                  )
                else if (enServicio)
                  _QuickBtn(
                    label: 'Seguimiento',
                    icon: Icons.route_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push(
                      '${RouteNames.clientServiceTracking}/${s.id}',
                      extra: {'solicitud': s},
                    ),
                  ),
                // Chat — visible si ya hay chat confirmado
                if (tieneChatActivo && enServicio) ...[
                  const SizedBox(width: 8),
                  _QuickBtn(
                    label: 'Chat',
                    icon: Icons.chat_bubble_rounded,
                    color: AppColors.workerRole,
                    onTap: () {
                      final chat = vm.chatActivo!;
                      context.push(
                        '${RouteNames.clientChat}/${chat.id}',
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
      ),
    );
  }
}
