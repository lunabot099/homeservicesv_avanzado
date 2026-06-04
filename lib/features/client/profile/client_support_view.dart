/// client_support_view.dart
/// Pantalla de soporte del cliente con acceso directo a WhatsApp.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

class ClientSupportView extends StatelessWidget {
  const ClientSupportView({super.key});

  static const String _whatsappNumber = '77362990';
  static const String _whatsappUrl =
      'https://wa.me/50377362990?text=Hola%2C%20necesito%20ayuda%20con%20HomeServiceSV';

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final uri = Uri.parse(_whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Soporte'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // ── Encabezado ───────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              '¿Necesitas ayuda?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos disponibles para ayudarte con cualquier duda o problema.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ── WhatsApp ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F9ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF25D366),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '+503 $_whatsappNumber',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Si necesitas ayuda, escríbenos al WhatsApp y te atenderemos a la brevedad.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirWhatsApp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 20),
                      label: const Text(
                        'Escribirnos al WhatsApp',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Info adicional ───────────────────────────────
            _InfoTile(
              icon: Icons.schedule_rounded,
              titulo: 'Horario de atención',
              subtitulo: 'Lunes a Viernes, 8:00 AM – 6:00 PM',
            ),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.info_outline_rounded,
              titulo: 'Versión de la app',
              subtitulo: '1.0.0 — HomeServiceSV',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;

  const _InfoTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitulo,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ]),
    );
  }
}
