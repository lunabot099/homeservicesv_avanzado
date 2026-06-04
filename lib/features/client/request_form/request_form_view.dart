/// request_form_view.dart
/// Pantalla del formulario de descripción del trabajo.
library;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import 'request_form_viewmodel.dart';

class RequestFormView extends StatelessWidget {
  final SolicitudServicioModel? solicitud;

  const RequestFormView({super.key, this.solicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestFormViewModel(),
      child: _RequestFormContent(solicitud: solicitud),
    );
  }
}

class _RequestFormContent extends StatefulWidget {
  final SolicitudServicioModel? solicitud;

  const _RequestFormContent({this.solicitud});

  @override
  State<_RequestFormContent> createState() => _RequestFormContentState();
}

class _RequestFormContentState extends State<_RequestFormContent> {
  final _descripcionCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  final _presupuestoCtrl = TextEditingController();

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _horarioCtrl.dispose();
    _presupuestoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestFormViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Describe el trabajo'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: StepIndicator(totalSteps: 4, currentStep: 2),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paso 2: Detalles del trabajo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // ── Descripción ────────────────────────────
                  _SectionLabel(label: 'Descripción del problema *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionCtrl,
                    onChanged: vm.setDescripcion,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe con detalle qué necesitas que se repare o haga...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 56),
                        child: Icon(Icons.description_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Urgencia ───────────────────────────────
                  _SectionLabel(label: 'Urgencia'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UrgenciaSolicitud.values.map((u) {
                      final selected = vm.urgencia == u;
                      return ChoiceChip(
                        label: Text(u.label),
                        selected: selected,
                        onSelected: (_) => vm.setUrgencia(u),
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // ── Tipo de pago ───────────────────────────
                  _SectionLabel(label: 'Tipo de pago preferido'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TipoPago.values.map((t) {
                      final selected = vm.tipoPago == t;
                      return ChoiceChip(
                        label: Text(t.label),
                        selected: selected,
                        onSelected: (_) => vm.setTipoPago(t),
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // ── Horario ────────────────────────────────
                  _SectionLabel(label: 'Horario preferido (opcional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horarioCtrl,
                    onChanged: vm.setHorario,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Mañanas, después de las 3pm, fin de semana...',
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Presupuesto ────────────────────────────
                  _SectionLabel(label: 'Presupuesto estimado (opcional, en \$)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _presupuestoCtrl,
                    onChanged: vm.setPresupuesto,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Ej: 50',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Imágenes ───────────────────────────────
                  _SectionLabel(label: 'Fotos (opcional, máx. 3)'),
                  const SizedBox(height: 8),
                  _ImagePickerRow(vm: vm),
                  const SizedBox(height: 8),
                  // Mensaje de error del picker
                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        vm.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  Text(
                    'Las fotos ayudan al trabajador a entender mejor el trabajo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // ── Botón continuar ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: PrimaryButton(
              label: 'Continuar',
              icon: Icons.arrow_forward_rounded,
              onPressed: vm.puedeAvanzar
                  ? () {
                      final solicitudActualizada =
                          widget.solicitud != null ? vm.aplicarA(widget.solicitud!) : null;
                      context.push(
                        RouteNames.clientRequestLocation,
                        extra: solicitudActualizada,
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

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
    );
  }
}

/// Fila de imágenes seleccionadas + botón para agregar nueva.
class _ImagePickerRow extends StatelessWidget {
  final RequestFormViewModel vm;

  const _ImagePickerRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Thumbnails de imágenes seleccionadas ──────────────
        ...List.generate(vm.imagenesCount, (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                _ImageThumb(bytes: vm.imagenesBytes[i]),
                Positioned(
                  right: 2,
                  top: 2,
                  child: GestureDetector(
                    onTap: () => vm.removeImagen(i),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        // ── Botón agregar imagen ──────────────────────────────
        if (vm.imagenesCount < 3)
          GestureDetector(
            onTap: vm.pickImagen,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.primary.withValues(alpha: 0.7),
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vm.imagenesCount}/3',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Thumbnail de imagen seleccionada con preview real (Image.memory).
class _ImageThumb extends StatelessWidget {
  final Uint8List bytes;

  const _ImageThumb({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
