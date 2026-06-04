/// worker_messages_viewmodel.dart
/// ViewModel de la lista de chats del trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../state/session_controller.dart';

class WorkerMessagesViewModel extends ChangeNotifier {
  final ChatsRepository _chatsRepo;
  final SessionController _sessionController;

  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _error;

  WorkerMessagesViewModel({
    ChatsRepository? chatsRepo,
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _sessionController = sessionController;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChats() async {
    final userId = _sessionController.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await _chatsRepo.getMisChats(userId);
    } catch (e) {
      _error = 'No se pudieron cargar los mensajes.';
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
