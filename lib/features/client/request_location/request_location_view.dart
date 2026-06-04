/// request_location_view.dart
/// Pantalla de selección de ubicación del servicio.
/// En esta pantalla se hace el INSERT real de la solicitud en Supabase
/// justo antes de navegar a "Buscando trabajadores".
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import 'request_location_viewmodel.dart';

class RequestLocationView extends StatelessWidget {
  final SolicitudServicioModel? solicitud;

  const RequestLocationView({super.key, this.solicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestLocationViewModel(),
      child: _RequestLocationContent(solicitud: solicitud),
    );
  }
}

class _RequestLocationContent extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const _RequestLocationContent({this.solicitud});

  @override
  State<_RequestLocationContent> createState() => _RequestLocationContentState();
}

class _RequestLocationContentState extends State<_RequestLocationContent> {
  final _coloniaCtrl = TextEditingController();
  final _calleCtrl = TextEditingController();
  final _casaCtrl = TextEditingController();
  final _referenciaCtrl = TextEditingController();

  /// Repositorio real — se usa al presionar "Buscar trabajadores"
  final _repository = SolicitudesRepository();

  bool _guardando = false;
  String? _errorGuardado;

  @override
  void dispose() {
    _coloniaCtrl.dispose();
    _calleCtrl.dispose();
    _casaCtrl.dispose();
    _referenciaCtrl.dispose();
    super.dispose();
  }

  /// Aplica ubicación al modelo, llama al repositorio real y navega.
  Future<void> _guardarYNavegar(
      BuildContext context, RequestLocationViewModel vm) async {
    // Defensa: necesitamos la solicitud base con clienteId y categoriaId
    if (widget.solicitud == null) {
      setState(() => _errorGuardado =
          'Error interno: no se recibieron los datos de la solicitud. Vuelve al inicio.');
      return;
    }

    setState(() {
      _guardando = true;
      _errorGuardado = null;
    });

    try {
      // 1. Completar el modelo con los datos de ubicación de esta pantalla
      final solicitudCompleta = vm.aplicarA(widget.solicitud!);

      // 2. INSERT real en Supabase — aquí se crea la fila en solicitudes_servicio
      final solicitudCreada = await _repository.createSolicitud(solicitudCompleta);

      // 3. Solo navegar si el insert fue exitoso (solicitudCreada tiene id real)
      if (!context.mounted) return;
      context.push(RouteNames.clientWaitingWorkers, extra: solicitudCreada);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorGuardado =
            'No se pudo crear la solicitud. Verifica tu conexión e intenta de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestLocationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('¿Dónde es el trabajo?'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: StepIndicator(totalSteps: 4, currentStep: 3),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paso 3: Ubicación del servicio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // ── Panel de ubicación GPS ────────────────
                  _UbicacionGpsPanel(vm: vm),
                  const SizedBox(height: 20),

                  // ── Departamento ──────────────────────────
                  _SectionLabel(label: 'Departamento *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city_rounded),
                    ),
                    hint: const Text('Selecciona departamento'),
                    value: vm.departamento,
                    items: vm.departamentos
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: _guardando ? null : vm.setDepartamento,
                  ),
                  const SizedBox(height: 16),

                  // ── Municipio ─────────────────────────────
                  _SectionLabel(label: 'Municipio *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    hint: const Text('Selecciona municipio'),
                    value: vm.municipio,
                    items: vm.municipios
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: _guardando ? null : vm.setMunicipio,
                  ),
                  const SizedBox(height: 16),

                  // ── Colonia ───────────────────────────────
                  _SectionLabel(label: 'Colonia / Barrio *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _coloniaCtrl,
                    onChanged: vm.setColonia,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Col. Escalón',
                      prefixIcon: Icon(Icons.holiday_village_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Calle ─────────────────────────────────
                  _SectionLabel(label: 'Calle / Avenida (opcional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _calleCtrl,
                    onChanged: vm.setCalle,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Calle Lomas de Altamira',
                      prefixIcon: Icon(Icons.signpost_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Número de casa ────────────────────────
                  _SectionLabel(label: 'No. de casa / edificio'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _casaCtrl,
                    onChanged: vm.setNumeroCasa,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      hintText: 'Ej: #25-B',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Punto de referencia ───────────────────
                  _SectionLabel(label: 'Punto de referencia (opcional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _referenciaCtrl,
                    onChanged: vm.setPuntoReferencia,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Frente al parque central',
                      prefixIcon: Icon(Icons.push_pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Error de guardado ─────────────────────
                  if (_errorGuardado != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorGuardado!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),

                  // ── Info de privacidad ────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'La dirección exacta solo se comparte con el trabajador confirmado.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Botón principal ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: _guardando
                ? _BotonCargando()
                : PrimaryButton(
                    label: 'Buscar trabajadores',
                    icon: Icons.search_rounded,
                    onPressed: vm.puedeAvanzar
                        ? () => _guardarYNavegar(context, vm)
                        : null,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Botón de carga mientras se inserta en Supabase.
class _BotonCargando extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Guardando solicitud...',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel de estado GPS — reemplaza el placeholder del mapa con UI funcional.
class _UbicacionGpsPanel extends StatelessWidget {
  final RequestLocationViewModel vm;

  const _UbicacionGpsPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    final tieneGps = vm.estaUsandoUbicacion;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: tieneGps
            ? AppColors.successLight
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: tieneGps ? AppColors.success : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Ícono de estado ─────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tieneGps
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tieneGps ? Icons.location_on_rounded : Icons.location_off_outlined,
              color: tieneGps ? AppColors.success : AppColors.grey500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // ── Texto de estado ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieneGps ? 'Ubicación GPS detectada' : 'Ubicación GPS no configurada',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tieneGps ? AppColors.success : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  tieneGps
                      ? 'Lat ${vm.latitud?.toStringAsFixed(4)}, Lon ${vm.longitud?.toStringAsFixed(4)}'
                      : 'Completa la dirección manualmente o pulsa "Mi ubicación".',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tieneGps ? AppColors.success : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Botón Mi ubicación / limpiar GPS ─────────────
          if (!tieneGps)
            ElevatedButton.icon(
              onPressed: vm.usarUbicacionActual,
              icon: const Icon(Icons.my_location_rounded, size: 16),
              label: const Text('Mi\nubicación', textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 48),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: vm.limpiarGps,
              child: Icon(
                Icons.close_rounded,
                color: AppColors.success.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
