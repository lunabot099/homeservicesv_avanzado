/// chat_viewmodel.dart
/// ViewModel compartido para el chat cliente-trabajador.
/// Usado tanto por la vista cliente como por la del trabajador.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/mensaje_chat_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/chats_repository.dart';
import '../../../data/repositories/perfiles_repository.dart';
import '../../../data/repositories/solicitudes_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../state/session_controller.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatsRepository _chatsRepo;
  final StorageService _storageService;
  final SessionController _sessionController;
  final PerfilesRepository _perfilesRepo;
  final SolicitudesRepository _solicitudesRepo;

  ChatModel? _chat;
  List<MensajeChatModel> _mensajes = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String _tituloChat = 'Chat';
  String? _subtituloChat;
  Timer? _refreshTimer;
  StreamSubscription<List<MensajeChatModel>>? _mensajesSubscription;
  StreamSubscription<SolicitudServicioModel?>? _solicitudSubscription;

  ChatViewModel({
    ChatsRepository? chatsRepo,
    StorageService? storageService,
    PerfilesRepository? perfilesRepo,
    SolicitudesRepository? solicitudesRepo,
    required SessionController sessionController,
  })  : _chatsRepo = chatsRepo ?? ChatsRepository(),
        _storageService = storageService ?? StorageService(),
        _perfilesRepo = perfilesRepo ?? PerfilesRepository(),
        _solicitudesRepo = solicitudesRepo ?? SolicitudesRepository(),
        _sessionController = sessionController;

  ChatModel? get chat => _chat;
  List<MensajeChatModel> get mensajes => _mensajes;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String get tituloChat => _tituloChat;
  String? get subtituloChat => _subtituloChat;
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
      await _validarSolicitudActiva(solicitudId,
          clienteId: clienteId, trabajadorId: trabajadorId);
      _chat = await _chatsRepo.getOCrearChat(
        solicitudId: solicitudId,
        clienteId: clienteId,
        trabajadorId: trabajadorId,
      );
      await _cargarTituloParticipante();
      await _cargarMensajes(_chat!.id!);
      _suscribirSolicitud(solicitudId);
      _error = null;
      _suscribirMensajes(_chat!.id!);
    } catch (e) {
      _error =
          'No se pudo abrir el chat: ${e.toString().replaceFirst('Exception: ', '')}';
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
      _chat = await _chatsRepo.getChatById(chatId);
      if (_chat == null) {
        _error = 'No se encontró este chat.';
        return;
      }

      await _validarSolicitudActiva(_chat!.solicitudId,
          clienteId: _chat!.clienteId, trabajadorId: _chat!.trabajadorId);
      await _cargarTituloParticipante();
      await _cargarMensajes(chatId);
      _suscribirSolicitud(_chat!.solicitudId);
      _error = null;
      _suscribirMensajes(chatId);
      if (usuarioActualId != null) {
        await _chatsRepo.marcarLeidos(
            chatId: chatId, usuarioId: usuarioActualId!);
      }
    } catch (e) {
      _error =
          'Error al cargar el chat: ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _validarSolicitudActiva(
    String solicitudId, {
    required String clienteId,
    required String trabajadorId,
  }) async {
    final userId = usuarioActualId;
    if (userId == null || (userId != clienteId && userId != trabajadorId)) {
      throw Exception('No tienes acceso a este chat.');
    }

    final solicitud = await _solicitudesRepo.getSolicitudById(solicitudId);
    final estado = solicitud?.estado;
    final chatDisponible = estado == EstadoSolicitud.confirmada ||
        estado == EstadoSolicitud.en_camino ||
        estado == EstadoSolicitud.ha_llegado ||
        estado == EstadoSolicitud.en_proceso ||
        estado == EstadoSolicitud.finalizado_pendiente;

    if (!chatDisponible || solicitud?.trabajadorId != trabajadorId) {
      throw Exception(
          'El chat estará disponible cuando el servicio esté aceptado y activo.');
    }
  }

  Future<void> _cargarTituloParticipante() async {
    final userId = usuarioActualId;
    final chat = _chat;
    if (userId == null || chat == null) return;

    final otherId =
        userId == chat.clienteId ? chat.trabajadorId : chat.clienteId;
    final fallback = userId == chat.clienteId ? 'Trabajador' : 'Cliente';

    try {
      final perfil = await _perfilesRepo.getPerfilById(otherId);
      final nombre = perfil?.nombreCompleto.trim();
      _tituloChat = (nombre != null && nombre.isNotEmpty) ? nombre : fallback;
    } catch (_) {
      _tituloChat = fallback;
    }
    _subtituloChat = 'Solicitud #${_shortenId(chat.solicitudId)}';
  }

  Future<void> _cargarMensajes(String chatId) async {
    final msgs = await _chatsRepo.getMensajes(chatId, limit: 100);
    _mensajes = _ordenarMensajes(msgs);
  }

  List<MensajeChatModel> _ordenarMensajes(List<MensajeChatModel> msgs) {
    final ordered = [...msgs];
    ordered.sort((a, b) {
      final ad = a.creadoEn ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.creadoEn ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ad.compareTo(bd);
    });
    return ordered;
  }

  void _suscribirSolicitud(String solicitudId) {
    _solicitudSubscription?.cancel();
    _solicitudSubscription =
        _solicitudesRepo.streamSolicitud(solicitudId).listen((s) async {
      if (s == null ||
          s.estado == EstadoSolicitud.completada ||
          s.estado == EstadoSolicitud.cancelada ||
          s.estado == EstadoSolicitud.expirada) {
        _error = 'Este chat ya no está disponible porque el servicio finalizó.';
        _mensajesSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void _iniciarRefreshFallback(String chatId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        await _cargarMensajes(chatId);
        notifyListeners();
      } catch (_) {}
    });
  }

  void _suscribirMensajes(String chatId) {
    _mensajesSubscription?.cancel();
    _mensajesSubscription = _chatsRepo.streamMensajes(chatId).listen(
      (msgs) {
        _mensajes = _ordenarMensajes(msgs);
        notifyListeners();
      },
      onError: (_) {
        // Silencioso — mantener mensajes cargados
      },
    );
    _iniciarRefreshFallback(chatId);
  }

  String _shortenId(String id) => id.length > 6 ? id.substring(0, 6) : id;

  /// Envía un mensaje de texto.
  Future<void> enviarTexto(String texto) async {
    if (texto.trim().isEmpty || _chat == null || usuarioActualId == null) {
      return;
    }

    _isSending = true;
    notifyListeners();
    try {
      final enviado = await _chatsRepo.enviarTexto(
        chatId: _chat!.id!,
        remitenteId: usuarioActualId!,
        texto: texto.trim(),
      );
      if (enviado.id == null || !_mensajes.any((m) => m.id == enviado.id)) {
        _mensajes = [..._mensajes, enviado];
      }
      _error = null;
    } catch (e) {
      final message = e.toString().replaceFirst("Exception: ", "");
      _error = "No se pudo enviar el mensaje: $message";
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
    _refreshTimer?.cancel();
    _mensajesSubscription?.cancel();
    _solicitudSubscription?.cancel();
    super.dispose();
  }
}
