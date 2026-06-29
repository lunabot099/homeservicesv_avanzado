/// chat_view.dart
/// Vista compartida de chat en tiempo real — usada por cliente y trabajador.
/// Soporta mensajes de texto, imágenes y mensajes del sistema.
/// Limpieza programada 7 días después de finalizado el servicio.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/mensaje_chat_model.dart';
import '../../../state/session_controller.dart';
import 'chat_viewmodel.dart';

/// Parámetros necesarios para inicializar el chat.
class ChatArgs {
  final String solicitudId;
  final String clienteId;
  final String trabajadorId;

  const ChatArgs({
    required this.solicitudId,
    required this.clienteId,
    required this.trabajadorId,
  });

  static ChatArgs fromMap(Map<String, dynamic> m) => ChatArgs(
        solicitudId: m['solicitudId'] as String? ?? '',
        clienteId: m['clienteId'] as String? ?? '',
        trabajadorId: m['trabajadorId'] as String? ?? '',
      );

  bool get isValid =>
      solicitudId.isNotEmpty && clienteId.isNotEmpty && trabajadorId.isNotEmpty;
}

class ChatView extends StatefulWidget {
  /// Si se proveen los argumentos, se inicializa desde cero.
  final ChatArgs? args;

  /// Si ya se conoce el chatId (navegando desde lista de chats).
  final String? chatId;

  const ChatView({super.key, this.args, this.chatId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatViewModel _vm;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _vm = ChatViewModel(sessionController: context.read<SessionController>());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.chatId != null) {
        await _vm.initChatById(widget.chatId!);
      } else if (widget.args != null) {
        final a = widget.args!;
        if (!a.isValid) return;
        await _vm.initChat(
          solicitudId: a.solicitudId,
          clienteId: a.clienteId,
          trabajadorId: a.trabajadorId,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    await _vm.enviarImagen(File(picked.path));
    _scrollToEnd();
  }

  Future<void> _sendText() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await _vm.enviarTexto(text);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          // Scroll automático cuando llegan mensajes nuevos
          if (vm.mensajes.isNotEmpty) _scrollToEnd();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vm.tituloChat,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                    if (vm.subtituloChat != null)
                      Text(
                        vm.subtituloChat!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ]),
            ),
            body: Column(
              children: [
                // ── Lista de mensajes ────────────────────────────
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.mensajes.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay mensajes aún.\n¡Saluda a tu cliente!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: vm.mensajes.length,
                              itemBuilder: (context, i) {
                                final msg = vm.mensajes[i];
                                final showDate = i == 0 ||
                                    !_sameDay(msg.creadoEn,
                                        vm.mensajes[i - 1].creadoEn);
                                return Column(
                                  children: [
                                    if (showDate) _DateSeparator(msg.creadoEn),
                                    _MessageBubble(
                                      msg: msg,
                                      isMine: vm.esMio(msg),
                                    ),
                                  ],
                                );
                              },
                            ),
                ),

                // ── Error ────────────────────────────────────────
                if (vm.error != null)
                  Container(
                    color: AppColors.errorLight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      vm.error!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),

                // ── Campo de entrada ─────────────────────────────
                if (vm.error == null)
                  _ChatInputBar(
                    controller: _msgCtrl,
                    isSending: vm.isSending,
                    onSend: _sendText,
                    onPickImage: _pickAndSendImage,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ── Widgets internos ────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime? date;
  const _DateSeparator(this.date);

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();
    final diff = DateTime.now().difference(date!);
    String label;
    if (diff.inDays == 0) {
      label = 'Hoy';
    } else if (diff.inDays == 1) {
      label = 'Ayer';
    } else {
      label = '${date!.day}/${date!.month}/${date!.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MensajeChatModel msg;
  final bool isMine;

  const _MessageBubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    // ── Mensaje de sistema ─────────────────────────────────
    if (msg.tipo == TipoMensaje.sistema) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              msg.contenido ?? '',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    // ── Burbuja normal ─────────────────────────────────────
    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 64 : 16,
        right: isMine ? 16 : 64,
        top: 3,
        bottom: 3,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: msg.tipo == TipoMensaje.imagen
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? AppColors.primary.withValues(alpha: 0.9)
                  : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppTheme.radiusLg),
                topRight: const Radius.circular(AppTheme.radiusLg),
                bottomLeft: Radius.circular(isMine ? AppTheme.radiusLg : 4),
                bottomRight: Radius.circular(isMine ? 4 : AppTheme.radiusLg),
              ),
              border: isMine ? null : Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildContent(isMine),
          ),
          const SizedBox(height: 2),
          Text(
            _hora(msg.creadoEn),
            style: const TextStyle(fontSize: 10, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMine) {
    switch (msg.tipo) {
      case TipoMensaje.imagen:
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg - 2),
          child: msg.archivoUrl != null
              ? Image.network(
                  msg.archivoUrl!,
                  width: 200,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                )
              : const Icon(Icons.image_not_supported_rounded),
        );
      default:
        return Text(
          msg.contenido ?? '',
          style: TextStyle(
            color: isMine ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
          ),
        );
    }
  }

  String _hora(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón de imagen
          IconButton(
            onPressed: isSending ? null : onPickImage,
            icon: const Icon(Icons.image_rounded),
            color: AppColors.grey500,
          ),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de enviar
          isSending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton.filled(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    minimumSize: const Size(42, 42),
                  ),
                ),
        ],
      ),
    );
  }
}
