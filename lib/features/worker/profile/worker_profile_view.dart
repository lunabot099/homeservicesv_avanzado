/// worker_profile_view.dart
/// Pantalla de perfil editable del trabajador — foto, descripción,
/// disponibilidad, especialidades (multiselección) y zona de cobertura (mapa).
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../state/session_controller.dart';
import 'worker_profile_viewmodel.dart';

// ── Constante: San Salvador como fallback ────────────────────────────────────
const _kDefaultLat = 13.6929;
const _kDefaultLng = -89.2182;
const _kDefaultZoom = 13.0;

class WorkerProfileView extends StatelessWidget {
  const WorkerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerProfileViewModel(
        sessionController: ctx.read<SessionController>(),
      )..loadPerfil(),
      child: const _WorkerProfileContent(),
    );
  }
}

class _WorkerProfileContent extends StatefulWidget {
  const _WorkerProfileContent();

  @override
  State<_WorkerProfileContent> createState() => _WorkerProfileContentState();
}

class _WorkerProfileContentState extends State<_WorkerProfileContent> {
  final _descripcionCtrl = TextEditingController();
  final _tarifaCtrl = TextEditingController();
  final _mapController = MapController();
  bool _initialized = false;

  // Posición actual en el mapa (punto seleccionado)
  LatLng _mapCenter = const LatLng(_kDefaultLat, _kDefaultLng);
  bool _locationLoading = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _tarifaCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _syncControllers(WorkerProfileViewModel vm) {
    if (!_initialized) {
      _descripcionCtrl.text = vm.descripcion;
      if (vm.tarifaPorDia != null) {
        _tarifaCtrl.text = vm.tarifaPorDia!.toStringAsFixed(0);
      }
      // Si el perfil ya tiene coordenadas guardadas, usarlas
      if (vm.latitud != null && vm.longitud != null) {
        _mapCenter = LatLng(vm.latitud!, vm.longitud!);
      }
      _initialized = true;
    }
  }

  // ── Obtener ubicación actual ──────────────────────────────────────────────
  Future<void> _obtenerUbicacionActual(WorkerProfileViewModel vm) async {
    setState(() => _locationLoading = true);

    try {
      // Verificar si el servicio de ubicación está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarSnack('El servicio de ubicación está desactivado.');
        return;
      }

      // Verificar/pedir permisos
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarSnack(
              'Permiso de ubicación denegado. Selecciona manualmente en el mapa.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _mostrarSnack(
            'Permiso bloqueado permanentemente. Habilítalo en configuración.');
        return;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final nueva = LatLng(position.latitude, position.longitude);
      setState(() => _mapCenter = nueva);
      _mapController.move(nueva, _kDefaultZoom);
      vm.setUbicacionCobertura(position.latitude, position.longitude);
      _mostrarSnack('Ubicación detectada correctamente.', isError: false);
    } catch (e) {
      _mostrarSnack('No se pudo obtener la ubicación. Selecciona manualmente.');
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _mostrarSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.warning : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerProfileViewModel>();
    final session = context.read<SessionController>();
    _syncControllers(vm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<SessionController>().signOut();
              if (context.mounted) context.go(RouteNames.roleSelector);
            },
            child:
                const Text('Salir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar y nombre ─────────────────────────────
                  _ProfileHeader(session: session, vm: vm),
                  const SizedBox(height: 28),

                  // ── Disponibilidad ──────────────────────────────
                  _SectionLabel('Disponibilidad'),
                  const SizedBox(height: 8),
                  _DisponibilidadTile(vm: vm),
                  const SizedBox(height: 24),

                  // ── Descripción ─────────────────────────────────
                  _SectionLabel('Descripción sobre ti'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionCtrl,
                    onChanged: vm.setDescripcion,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Cuéntale a tus clientes sobre tu experiencia...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Especialidades (multiselección) ─────────────
                  _SectionLabel('Especialidades'),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona todas las que apliquen.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _EspecialidadesSelector(vm: vm),
                  const SizedBox(height: 20),

                  // ── Tarifa por día ───────────────────────────────
                  _SectionLabel('Tarifa por día (USD)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tarifaCtrl,
                    onChanged: vm.setTarifa,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 50',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Zona de cobertura (mapa) ─────────────────────
                  _SectionLabel('Zona de cobertura'),
                  const SizedBox(height: 4),
                  Text(
                    'Toca el mapa para indicar el centro de tu zona. Radio: 6 km.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _MapaCobertura(
                    vm: vm,
                    mapController: _mapController,
                    mapCenter: _mapCenter,
                    locationLoading: _locationLoading,
                    onMapTap: (point) {
                      setState(() => _mapCenter = point);
                      vm.setUbicacionCobertura(point.latitude, point.longitude);
                    },
                    onDetectarUbicacion: () => _obtenerUbicacionActual(vm),
                  ),
                  const SizedBox(height: 32),

                  // ── Feedback ─────────────────────────────────────
                  if (vm.successMessage != null)
                    _FeedbackBanner(
                      message: vm.successMessage!,
                      isError: false,
                    ),
                  if (vm.error != null)
                    _FeedbackBanner(
                      message: vm.error!,
                      isError: true,
                    ),
                  const SizedBox(height: 12),

                  // ── Guardar ─────────────────────────────────────
                  PrimaryButton(
                    label: 'Guardar cambios',
                    icon: Icons.save_rounded,
                    backgroundColor: AppColors.workerRole,
                    isLoading: vm.isSaving,
                    onPressed: () async {
                      final ok = await vm.guardarPerfil();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? '¡Perfil actualizado!'
                                : (vm.error ?? 'Error al guardar')),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ── Widget: Selector de especialidades ──────────────────────────────────────

class _EspecialidadesSelector extends StatelessWidget {
  final WorkerProfileViewModel vm;
  const _EspecialidadesSelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips de opciones disponibles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kEspecialidadesDisponibles.map((esp) {
              final selected = vm.isEspecialidadSeleccionada(esp);
              return _EspecialidadChip(
                label: esp,
                selected: selected,
                onTap: () => vm.toggleEspecialidad(esp),
              );
            }).toList(),
          ),

          // Contador de seleccionadas
          if (vm.especialidades.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              '${vm.especialidades.length} especialidad${vm.especialidades.length == 1 ? '' : 'es'} seleccionada${vm.especialidades.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.workerRole,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EspecialidadChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EspecialidadChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.workerRole.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.workerRole : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: AppColors.workerRole,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.workerRole : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Mapa de cobertura ────────────────────────────────────────────────

class _MapaCobertura extends StatelessWidget {
  final WorkerProfileViewModel vm;
  final MapController mapController;
  final LatLng mapCenter;
  final bool locationLoading;
  final ValueChanged<LatLng> onMapTap;
  final VoidCallback onDetectarUbicacion;

  const _MapaCobertura({
    required this.vm,
    required this.mapController,
    required this.mapCenter,
    required this.locationLoading,
    required this.onMapTap,
    required this.onDetectarUbicacion,
  });

  @override
  Widget build(BuildContext context) {
    // Punto seleccionado: si el VM ya tiene lat/lng los usa, si no usa mapCenter
    final punto = (vm.latitud != null && vm.longitud != null)
        ? LatLng(vm.latitud!, vm.longitud!)
        : null;

    return Column(
      children: [
        // Botón de ubicación actual
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: locationLoading ? null : onDetectarUbicacion,
            icon: locationLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(locationLoading
                ? 'Detectando ubicación...'
                : 'Usar mi ubicación actual'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.workerRole,
              side: const BorderSide(color: AppColors.workerRole),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Mapa interactivo
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: _kDefaultZoom,
                onTap: (_, point) => onMapTap(point),
              ),
              children: [
                // Capa de tiles OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.homeservicesv.app',
                ),

                // Capa de círculo de cobertura
                if (punto != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: punto,
                        radius: 6000, // 6 km en metros
                        useRadiusInMeter: true,
                        color: AppColors.workerRole.withValues(alpha: 0.15),
                        borderColor:
                            AppColors.workerRole.withValues(alpha: 0.6),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),

                // Marcador del punto seleccionado
                if (punto != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: punto,
                        width: 40,
                        height: 40,
                        child: const _MapPin(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Coordenadas actuales o indicación de acción
        const SizedBox(height: 8),
        Center(
          child: Text(
            punto != null
                ? 'Lat: ${punto.latitude.toStringAsFixed(5)}  •  '
                    'Lng: ${punto.longitude.toStringAsFixed(5)}  •  Radio: 6 km'
                : 'Toca el mapa o usa tu ubicación para establecer la zona',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: punto != null
                      ? AppColors.workerRole
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.workerRole,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.home_repair_service_rounded,
              color: Colors.white, size: 14),
        ),
        CustomPaint(
          size: const Size(12, 6),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.workerRole;
    // Usamos ui.Path explícitamente para evitar colisión con flutter_map's Path<LatLng>
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Widgets internos reutilizados ────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final SessionController session;
  final WorkerProfileViewModel vm;

  const _ProfileHeader({required this.session, required this.vm});

  @override
  Widget build(BuildContext context) {
    final perfil = vm.perfil ?? session.currentPerfil;
    final nombre = perfil?.nombreCompleto ?? session.currentUser?.email ?? '—';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    // Fuente de imagen: bytes locales (previsualización) → URL guardada → fallback
    final ImageProvider? imageProvider = vm.fotoBytes != null
        ? MemoryImage(vm.fotoBytes!)
        : (perfil?.fotoPerfilUrl != null && perfil!.fotoPerfilUrl!.isNotEmpty)
            ? NetworkImage(perfil.fotoPerfilUrl!)
            : null;

    return Row(
      children: [
        GestureDetector(
          onTap: vm.isUploadingPhoto
              ? null
              : () async {
                  await vm.elegirFotoPerfil();
                },
          child: Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.workerRole.withValues(alpha: 0.15),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        inicial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.workerRole,
                        ),
                      )
                    : null,
              ),
              // Indicador de subida
              if (vm.isUploadingPhoto)
                const Positioned.fill(
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Color(0x88000000),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              // Botón de cámara
              if (!vm.isUploadingPhoto)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.workerRole,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              Text(session.currentUser?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      )),
              const SizedBox(height: 4),
              Text(
                'Toca la foto para cambiarla',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.workerRole,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisponibilidadTile extends StatelessWidget {
  final WorkerProfileViewModel vm;
  const _DisponibilidadTile({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: vm.disponible ? AppColors.workerRole : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            vm.disponible
                ? Icons.check_circle_rounded
                : Icons.pause_circle_rounded,
            color: vm.disponible ? AppColors.workerRole : AppColors.grey400,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.disponible ? 'Disponible' : 'No disponible',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: vm.disponible
                            ? AppColors.workerRole
                            : AppColors.grey600,
                      ),
                ),
                Text(
                  vm.disponible
                      ? 'Los clientes pueden ver tu perfil y contratarte.'
                      : 'No recibirás nuevas solicitudes.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: vm.disponible,
            onChanged: (_) => vm.toggleDisponible(),
            activeThumbColor: AppColors.workerRole,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _FeedbackBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: isError ? AppColors.error : AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.error : AppColors.success,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
