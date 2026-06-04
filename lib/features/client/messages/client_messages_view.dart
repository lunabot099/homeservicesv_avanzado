/// client_messages_view.dart
/// Pantalla de mensajes del cliente — lista de chats.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../state/session_controller.dart';
import 'client_messages_viewmodel.dart';

class ClientMessagesView extends StatefulWidget {
  const ClientMessagesView({super.key});

  @override
  State<ClientMessagesView> createState() => _ClientMessagesViewState();
}

class _ClientMessagesViewState extends State<ClientMessagesView> {
  late final ClientMessagesViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ClientMessagesViewModel(
      sessionController: context.read<SessionController>(),
    );
    _vm.loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ClientMessagesViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Mensajes'),
            backgroundColor: Colors.transparent,
          ),
          body: vm.isLoading
              ? const LoadingView(message: 'Cargando mensajes...')
              : vm.chats.isEmpty
                  ? EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Sin mensajes aún',
                      subtitle:
                          'Cuando contrates un trabajador podrás chatear con él aquí.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.paddingLg),
                      itemCount: vm.chats.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final chat = vm.chats[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: chat.fotoTrabajadorUrl != null
                                ? NetworkImage(chat.fotoTrabajadorUrl!)
                                : null,
                            child: chat.fotoTrabajadorUrl == null
                                ? Text(
                                    chat.nombreTrabajador[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700),
                                  )
                                : null,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat.nombreTrabajador,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                '${chat.fechaUltimoMensaje.hour}:${chat.fechaUltimoMensaje.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat.ultimoMensaje,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: chat.tieneMensajesNoLeidos
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: chat.tieneMensajesNoLeidos
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (chat.tieneMensajesNoLeidos)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            context.push(
                              '${RouteNames.clientChat}/${chat.chatId}',
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
