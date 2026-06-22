/// worker_application_view.dart
/// Pantalla del formulario de postulación de trabajador.
///
/// Solo accesible con sesión activa.
/// Nombre, correo y teléfono vienen de [SessionController.currentPerfil] —
/// no se vuelven a pedir, solo se muestran en una tarjeta de solo lectura.
///
/// Compatibilidad multiplataforma:
/// - Los pickers leen bytes (Uint8List) — funciona en web, móvil y escritorio.
/// - El preview usa Image.memory(bytes) — nunca Image.file (no soportado en web).
/// - La subida usa uploadBinary de Supabase Storage.
library;

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../state/session_controller.dart';
import 'worker_application_viewmodel.dart';

class WorkerApplicationView extends StatelessWidget {
  const WorkerApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkerApplicationViewModel(
        sessionController: context.read<SessionController>(),
      ),
      child: const _WorkerApplicationContent(),
    );
  }
}

// ── Contenido con estado ──────────────────────────────────────────

class _WorkerApplicationContent extends StatefulWidget {
  const _WorkerApplicationContent();

  @override
  State<_WorkerApplicationContent> createState() =>
      _WorkerApplicationContentState();
}

class _WorkerApplicationContentState extends State<_WorkerApplicationContent> {
  final _formKey = GlobalKey<FormState>();
  // Solo los campos que NO existen en el perfil base:
  final _duiCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _duiCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  // ── Pickers ────────────────────────────────────────────────────
  // Siempre se leen bytes con XFile.readAsBytes() — compatible con web.

  Future<void> _pickFotoPerfil() async {
    final vm = context.read<WorkerApplicationViewModel>();
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = _mimeFromPath(picked.path);
    vm.setFotoPerfilBytes(bytes, mime: mime);
  }

  Future<void> _pickFotoDui() async {
    final vm = context.read<WorkerApplicationViewModel>();
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = _mimeFromPath(picked.path);
    vm.setFotoDuiBytes(bytes, mime: mime);
  }

  Future<void> _pickAntecedentesPenales() async {
    final vm = context.read<WorkerApplicationViewModel>();

    // withData: true garantiza que PlatformFile.bytes esté disponible en web.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final pf = result.files.single;

    // En web, pf.bytes contiene los datos. En nativo, pf.bytes también
    // está disponible gracias a withData: true.
    final bytes = pf.bytes;
    if (bytes == null) return;

    final ext = (pf.extension ?? 'pdf').toLowerCase();
    final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';

    vm.setAntecedentesPenalesBytes(bytes, mime: mime);
  }

  Future<void> _pickAntecedentesPoliciales() async {
    final vm = context.read<WorkerApplicationViewModel>();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final pf = result.files.single;
    final bytes = pf.bytes;
    if (bytes == null) return;

    final ext = (pf.extension ?? 'pdf').toLowerCase();
    final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';

    vm.setAntecedentesPolicialesBytes(bytes, mime: mime);
  }

  /// Infiere el MIME type a partir de la extensión del path.
  String _mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  // ── Envío del formulario ───────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<WorkerApplicationViewModel>();
    final success = await vm.submitApplication(
      dui: _duiCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
    );
    if (success && mounted) {
      context.go(RouteNames.workerPending);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerApplicationViewModel>();

    // ── Estado de éxito: se redirige en _submit, este bloque es fallback ──
    if (vm.enviado) {
      // Navegar a pending por si la navegación en _submit no se ejecutó
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(RouteNames.workerPending),
      );
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Formulario ───────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aplica como Trabajador'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Tarjeta de perfil (solo lectura) ─────────────────
                _SectionTitle(title: 'Tus datos de registro'),
                const SizedBox(height: 12),
                const _ProfileReadOnlyCard(),
                const SizedBox(height: 24),

                // ── Sección: Datos de identificación ──────────────────
                _SectionTitle(title: 'Datos de identificación'),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Número de DUI',
                  hint: '00000000-0',
                  controller: _duiCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  validator: Validators.dui,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Dirección (opcional)',
                  hint: 'Col. Escalón, San Salvador',
                  controller: _direccionCtrl,
                  keyboardType: TextInputType.streetAddress,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                ),

                const SizedBox(height: 28),

                // ── Sección: Documentos ─────────────────────────
                _SectionTitle(title: 'Documentos obligatorios'),
                const SizedBox(height: 8),
                Text(
                  'Estos documentos son necesarios para revisar y autorizar tu cuenta de trabajador.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                // Foto de perfil
                _DocumentPickerTile(
                  label: 'Foto de perfil',
                  description: 'Obligatoria: imagen clara de tu rostro',
                  icon: Icons.person_rounded,
                  isLoading: vm.uploadingFotoPerfil,
                  isSelected: vm.hayFotoPerfil,
                  onTap: _pickFotoPerfil,
                  previewBytes: vm.fotoPerfilBytes,
                ),
                const SizedBox(height: 12),

                // Foto del DUI
                _DocumentPickerTile(
                  label: 'Foto del DUI',
                  description: 'Obligatoria: foto legible del frente de tu DUI',
                  icon: Icons.badge_rounded,
                  isLoading: vm.uploadingDui,
                  isSelected: vm.hayFotoDui,
                  onTap: _pickFotoDui,
                  previewBytes: vm.fotoDuiBytes,
                ),
                const SizedBox(height: 12),

                // Antecedentes penales
                _DocumentPickerTile(
                  label: 'Antecedentes penales',
                  description: 'Obligatorio: PDF o imagen del certificado',
                  icon: Icons.description_rounded,
                  isLoading: vm.uploadingAntecedentesPenales,
                  isSelected: vm.hayAntecedentesPenales,
                  onTap: _pickAntecedentesPenales,
                  // PDF no tiene preview de imagen
                  previewBytes: vm.antecedentesPenalesMime == 'application/pdf'
                      ? null
                      : vm.antecedentesPenalesBytes,
                  isPdf: vm.antecedentesPenalesMime == 'application/pdf',
                ),
                const SizedBox(height: 12),

                // Antecedentes policiales
                _DocumentPickerTile(
                  label: 'Antecedentes policiales',
                  description: 'Obligatorio: PDF o imagen del certificado',
                  icon: Icons.policy_rounded,
                  isLoading: vm.uploadingAntecedentesPoliciales,
                  isSelected: vm.hayAntecedentesPoliciales,
                  onTap: _pickAntecedentesPoliciales,
                  previewBytes:
                      vm.antecedentesPolicialesMime == 'application/pdf'
                          ? null
                          : vm.antecedentesPolicialesBytes,
                  isPdf: vm.antecedentesPolicialesMime == 'application/pdf',
                ),

                // ── Error ───────────────────────────────────────
                if (vm.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBox(message: vm.error!),
                ],

                const SizedBox(height: 32),

                // ── Botón de envío ──────────────────────────────
                PrimaryButton(
                  label: vm.isLoading ? 'Enviando...' : 'Enviar Solicitud',
                  onPressed: vm.isLoading ? null : _submit,
                  isLoading: vm.isLoading,
                  icon: Icons.send_rounded,
                  backgroundColor: AppColors.workerRole,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
    );
  }
}

/// Tarjeta de solo lectura que muestra los datos ya registrados del perfil.
/// Lee directamente de [SessionController] — no duplica datos.
class _ProfileReadOnlyCard extends StatelessWidget {
  const _ProfileReadOnlyCard();

  @override
  Widget build(BuildContext context) {
    final perfil = context.read<SessionController>().currentPerfil;
    final nombre = perfil?.nombreCompleto ?? '—';
    final correo = perfil?.correo ?? '—';
    final telefono = perfil?.telefono ?? 'Sin teléfono registrado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.workerRole.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.workerRole.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadOnlyRow(
            icon: Icons.person_outline_rounded,
            label: 'Nombre',
            value: nombre,
          ),
          const Divider(height: 20),
          _ReadOnlyRow(
            icon: Icons.email_outlined,
            label: 'Correo',
            value: correo,
          ),
          const Divider(height: 20),
          _ReadOnlyRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: telefono,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.workerRole),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: AppColors.grey400,
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta para seleccionar y previsualizar un documento o imagen.
///
/// Usa [Image.memory] para previsualizar — compatible con web, móvil y escritorio.
/// NO usa [Image.file] (no soportado en Flutter Web).
class _DocumentPickerTile extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback onTap;

  /// Bytes de la imagen para previsualizar (Uint8List).
  /// Null si es PDF o si aún no se seleccionó archivo.
  final Uint8List? previewBytes;

  /// True si el archivo es un PDF (no tiene preview de imagen).
  final bool isPdf;

  const _DocumentPickerTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.isLoading,
    required this.isSelected,
    required this.onTap,
    this.previewBytes,
    this.isPdf = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.workerRole : AppColors.textSecondary;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.workerRole.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.workerRole.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Preview o ícono
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildPreview(),
            ),
            const SizedBox(width: 14),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelected
                        ? (isPdf
                            ? 'Archivo seleccionado ✓'
                            : 'Imagen seleccionada ✓')
                        : description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppColors.workerRole
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            // Estado / acción
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.upload_rounded,
                color: color,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  /// Construye el widget de preview.
  ///
  /// Prioridad:
  ///   1. [previewBytes] non-null y no es PDF → Image.memory (cross-platform ✓)
  ///   2. PDF o sin archivo → ícono
  ///
  /// NOTA: No se usa Image.file aquí porque no es compatible con Flutter Web.
  Widget _buildPreview() {
    final iconWidget = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.workerRole.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: AppColors.workerRole.withValues(alpha: 0.8),
        size: 26,
      ),
    );

    // PDF o sin archivo → ícono
    if (!isSelected || previewBytes == null || isPdf) return iconWidget;

    // Imagen seleccionada → Image.memory (funciona en web y nativo)
    return Image.memory(
      previewBytes!,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => iconWidget,
    );
  }
}
