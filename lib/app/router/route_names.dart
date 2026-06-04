/// route_names.dart
/// Constantes de nombres de rutas de la app HomeServiceSV.
/// Centralizar aquí evita errores de typos al navegar.
library;

class RouteNames {
  RouteNames._();

  // ── Selector de rol ──────────────────────────────────────────
  static const String roleSelector = '/';

  // ── Auth Cliente ─────────────────────────────────────────────
  static const String clientLogin = '/client/login';
  static const String clientRegister = '/client/register';

  // ── Auth Trabajador ──────────────────────────────────────────
  static const String workerLogin = '/worker/login';
  static const String workerRegister = '/worker/register';
  static const String workerApplication = '/worker/apply';
  static const String workerPending = '/worker/pending';

  // ── Home Cliente ─────────────────────────────────────────────
  static const String clientHome = '/client/home';

  // ── Flujo de solicitud del cliente ───────────────────────────
  /// /client/services/:categoryId
  static const String clientServiceSelection = '/client/services';
  static const String clientRequestForm = '/client/request/form';
  static const String clientRequestLocation = '/client/request/location';
  static const String clientWaitingWorkers = '/client/request/waiting';
  static const String clientWorkersCatalog = '/client/workers';
  /// /client/worker/:workerId
  static const String clientWorkerProfile = '/client/worker';
  static const String clientBookingConfirmation = '/client/booking/confirm';
  /// /client/tracking/:solicitudId
  static const String clientServiceTracking = '/client/tracking';
  /// /client/rate/:solicitudId
  static const String clientRateWorker = '/client/rate';

  // ── Secciones del cliente ─────────────────────────────────────
  static const String clientReviews = '/client/reviews';
  static const String clientProfile = '/client/profile';
  static const String clientMessages = '/client/messages';
  /// /client/chat/:chatId
  static const String clientChat = '/client/chat';

  /// Onboarding de foto de perfil — obligatorio tras el registro
  static const String clientPhotoOnboarding = '/client/photo-onboarding';

  /// Historial de servicios contratados
  static const String clientServiceHistory = '/client/history';

  /// Cambio de contraseña
  static const String clientChangePassword = '/client/change-password';

  /// Direcciones guardadas
  static const String clientSavedAddresses = '/client/addresses';

  /// Soporte y ayuda
  static const String clientSupport = '/client/support';

  // ── Home Trabajador ──────────────────────────────────────────
  static const String workerHome = '/worker/home';

  // ── Flujo del trabajador ──────────────────────────────────────
  /// /worker/request/:solicitudId — Detalle de una solicitud disponible
  static const String workerRequestDetail = '/worker/request';

  /// Lista de solicitudes disponibles para postularse
  static const String workerRequests = '/worker/requests';

  /// Solicitudes donde el trabajador se postuló
  static const String workerApplications = '/worker/applications';

  /// /worker/chat/:chatId — Chat con cliente
  static const String workerChat = '/worker/chat';

  /// /worker/service/confirmed/:solicitudId — Servicio confirmado
  static const String workerConfirmedService = '/worker/service/confirmed';

  /// /worker/service/tracking/:solicitudId — Servicio en curso
  static const String workerServiceTracking = '/worker/service/tracking';

  /// /worker/rate/:solicitudId — Calificar al cliente
  static const String workerRateClient = '/worker/rate';

  // ── Secciones del trabajador ──────────────────────────────────
  static const String workerReviews = '/worker/reviews';
  static const String workerProfile = '/worker/profile';
  static const String workerMessages = '/worker/messages';
}
