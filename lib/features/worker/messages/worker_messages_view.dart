/// worker_messages_view.dart
/// Lista de chats del trabajador — cada ítem navega al chat con el cliente.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/route_names.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/chat_model.dart';
import '../../../state/session_controller.dart';
import 'worker_messages_viewmodel.dart';

class WorkerMessagesView extends StatelessWidget {
  const WorkerMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkerMessagesViewModel(
        sessionController: ctx.read<SessionController>(),
      )..loadChats(),
      child: const _WorkerMessagesContent(),
    );
  }
}

class _WorkerMessagesContent extends StatelessWidget {
  const _WorkerMessagesContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerMessagesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.transparent,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.loadChats,
              child: vm.chats.isEmpty
                  ? EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Sin mensajes',
                      subtitle:
                          'Tus conversaciones con clientes aparecerán aquí.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: vm.chats.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, i) {
                        final chat = vm.chats[i];
                        return _ChatListTile(
                          chat: chat,
                          onTap: () => context.push(
                            '${RouteNames.workerChat}/${chat.id}',
                            extra: {
                              'solicitudId': chat.solicitudId,
                              'clienteId': chat.clienteId,
                              'trabajadorId': chat.trabajadorId,
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// ── Widgets internos ────────────────────────────────────────────────────────

class _ChatListTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatListTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tiempoTexto = _formatTime(chat.creadoEn);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.person_rounded,
            color: AppColors.primary, size: 26),
      ),
      title: Text(
        'Cliente · Solicitud ${_shortenId(chat.solicitudId)}',
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          chat.ultimoMensaje ?? 'Chat activo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(tiempoTexto,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.grey400)),
          if ((chat.mensajesNoLeidos ?? 0) > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.workerRole,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '${chat.mensajesNoLeidos}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String _shortenId(String id) {
    if (id.length <= 6) return id;
    return '#${id.substring(0, 6)}';
  }
}
