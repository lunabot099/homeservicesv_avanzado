/// chat_viewmodel.dart
/// ViewModel compartido para el chat cliente-trabajador.
/// Usado tanto por la vista cliente como por la del trabajador.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/mensaje_chat_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../state/session_controller.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatsRepository _chatsRepo;
  final StorageService _storageService;
  final SessionController _sessionController;

  ChatModel? _chat;
  List<MensajeChatModel> _mensajes = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  StreamSubscription<List<MensajeChatModel>>? _mensajesSubscription;

  ChatViewModel({
    ChatsRepository? chatsRepo,
    StorageService? storageService,
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _storageService = storageService ?? StorageService(),
        _sessionController = sessionController;

  ChatModel? get chat => _chat;
  List<MensajeChatModel> get mensajes => _mensajes;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get usuarioActualId => _sessionController.currentUser?.id;

  bool esMio(MensajeChatModel m) => m.remitenteId == usuarioActualId;

  /// Inicializa el chat: obtiene o crea el chat y suscribe al stream Realtime.
  Future<void> initChat({
    required String solicitudId,
    required String clienteId,
    required String trabajadorId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _chat = await _chatsRepo.getOCrearChat(
        solicitudId: solicitudId,
        clienteId: clienteId,
        trabajadorId: trabajadorId,
      );
      _suscribirMensajes(_chat!.id!);
    } catch (e) {
      _error = 'No se pudo abrir el chat: ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicializa el chat por ID (navegando desde lista de chats).
  Future<void> initChatById(String chatId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _suscribirMensajes(chatId);
      if (usuarioActualId != null) {
        await _chatsRepo.marcarLeidos(
            chatId: chatId, usuarioId: usuarioActualId!);
      }
    } catch (e) {
      _error = 'Error al cargar el chat: ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _suscribirMensajes(String chatId) {
    _mensajesSubscription?.cancel();
    _mensajesSubscription = _chatsRepo.streamMensajes(chatId).listen(
      (msgs) {
        _mensajes = msgs;
        notifyListeners();
      },
      onError: (_) {
        // Silencioso — mantener mensajes cargados
      },
    );
  }

  /// Envía un mensaje de texto.
  Future<void> enviarTexto(String texto) async {
    if (texto.trim().isEmpty || _chat == null || usuarioActualId == null) return;

    _isSending = true;
    notifyListeners();
    try {
      await _chatsRepo.enviarTexto(
        chatId: _chat!.id!,
        remitenteId: usuarioActualId!,
        texto: texto.trim(),
      );
    } catch (_) {
      // Optimistic UI — el mensaje ya se muestra vía Realtime
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Envía una imagen: primero la sube a Storage, luego envía la URL.
  Future<void> enviarImagen(File imageFile) async {
    if (_chat == null || usuarioActualId == null) return;

    _isSending = true;
    notifyListeners();
    try {
      final url = await _storageService.uploadChatImage(
        chatId: _chat!.id!,
        userId: usuarioActualId!,
        file: imageFile,
      );
      await _chatsRepo.enviarImagen(
        chatId: _chat!.id!,
        remitenteId: usuarioActualId!,
        archivoUrl: url,
      );
    } catch (e) {
      _error = 'No se pudo enviar la imagen.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mensajesSubscription?.cancel();
    super.dispose();
  }
}
