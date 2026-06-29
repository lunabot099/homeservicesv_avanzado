/// worker_messages_viewmodel.dart
/// ViewModel de la lista de chats del trabajador.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../state/session_controller.dart';

class WorkerMessagesViewModel extends ChangeNotifier {
  final ChatsRepository _chatsRepo;
  final SessionController _sessionController;
  final SolicitudesRepository _solicitudesRepo;

  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _error;

  WorkerMessagesViewModel({
    ChatsRepository? chatsRepo,
    SolicitudesRepository? solicitudesRepo,
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
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
      final rawChats = await _chatsRepo.getMisChats(userId);
      final activos = <ChatModel>[];
      for (final chat in rawChats) {
        final solicitud =
            await _solicitudesRepo.getSolicitudById(chat.solicitudId);
        if (_chatActivo(solicitud)) activos.add(chat);
      }
      _chats = activos;
    } catch (e) {
      _error = 'No se pudieron cargar los mensajes.';
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

bool _chatActivo(SolicitudServicioModel? solicitud) {
  final estado = solicitud?.estado;
  return estado == EstadoSolicitud.confirmada ||
      estado == EstadoSolicitud.en_camino ||
      estado == EstadoSolicitud.ha_llegado ||
      estado == EstadoSolicitud.en_proceso ||
      estado == EstadoSolicitud.finalizado_pendiente;
}
