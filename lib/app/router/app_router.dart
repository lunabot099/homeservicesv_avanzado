/// app_router.dart
/// Router central de HomeServiceSV usando GoRouter.
/// Incluye todas las rutas del flujo cliente (Fase 2).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/session_controller.dart';
import '../../features/auth/role_selector/role_selector_view.dart';
import '../../features/auth/client_login/client_login_view.dart';
import '../../features/auth/client_register/client_register_view.dart';
import '../../features/auth/worker_login/worker_login_view.dart';
import '../../features/auth/worker_register/worker_register_view.dart';
import '../../features/auth/worker_application/worker_application_view.dart';
import '../../features/auth/worker_pending/worker_pending_view.dart';
import '../../features/client/home/client_home_view.dart';
import '../../features/auth/client_register/client_photo_onboarding_view.dart';
import '../../features/client/profile/client_service_history_view.dart';
import '../../features/client/profile/client_change_password_view.dart';
import '../../features/client/profile/client_saved_addresses_view.dart';
import '../../features/client/profile/client_support_view.dart';
import '../../features/client/service_selection/service_selection_view.dart';
import '../../features/client/request_form/request_form_view.dart';
import '../../features/client/request_location/request_location_view.dart';
import '../../features/client/waiting_workers/waiting_workers_view.dart';
import '../../features/client/workers_catalog/workers_catalog_view.dart';
import '../../features/client/worker_profile_detail/worker_profile_detail_view.dart';
import '../../features/client/booking_confirmation/booking_confirmation_view.dart';
import '../../features/client/service_tracking/client_service_tracking_view.dart';
import '../../features/client/rate_worker/rate_worker_view.dart';
import '../../features/client/reviews/client_reviews_view.dart';
import '../../features/client/profile/client_profile_view.dart';
import '../../features/client/messages/client_messages_view.dart';
import '../../features/worker/home/worker_home_view.dart';
import '../../features/worker/applications/worker_applications_view.dart';
import '../../features/worker/request_detail/worker_request_detail_view.dart';
import '../../features/worker/confirmed_service/worker_confirmed_service_view.dart';
import '../../features/worker/service_tracking/worker_service_tracking_view.dart';
import '../../features/worker/rate_client/rate_client_view.dart';
import '../../features/worker/reviews/worker_reviews_view.dart';
import '../../features/worker/profile/worker_profile_view.dart';
import '../../features/worker/messages/worker_messages_view.dart';
import '../../features/shared/chat/chat_view.dart';
import '../../data/models/solicitud_servicio_model.dart';
import '../../data/models/postulacion_solicitud_model.dart';
import '../../data/models/perfil_model.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Map<String, dynamic>? _extraMap(Object? extra) {
    return extra is Map<String, dynamic> ? extra : null;
  }

  static T? _extra<T>(Object? extra) {
    return extra is T ? extra : null;
  }

  static T? _extraValue<T>(Map<String, dynamic>? extra, String key) {
    final value = extra?[key];
    return value is T ? value : null;
  }

  static Widget _missingRouteData(String message) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }

  static GoRouter createRouter(BuildContext context) {
    final sessionController = context.read<SessionController>();

    return GoRouter(
      initialLocation: RouteNames.roleSelector,
      refreshListenable: sessionController,
      redirect: (BuildContext context, GoRouterState state) {
        final session = context.read<SessionController>();
        final isAuthenticated = session.isAuthenticated;
        final currentPath = state.matchedLocation;

        // Rutas accesibles sin autenticación
        const publicRoutes = [
          RouteNames.roleSelector,
          RouteNames.clientLogin,
          RouteNames.clientRegister,
          RouteNames.clientPhotoOnboarding,
          RouteNames.workerLogin,
          RouteNames.workerRegister,
          // workerApplication y workerPending requieren sesión activa
        ];

        final isPublicRoute = publicRoutes.contains(currentPath);
        final isWorkerRoute = currentPath.startsWith('/worker');
        final isWorkerOnboardingRoute =
            currentPath == RouteNames.workerApplication ||
                currentPath == RouteNames.workerPending;
        final isWorkerPublicRoute = currentPath == RouteNames.workerLogin ||
            currentPath == RouteNames.workerRegister;
        final isProtectedWorkerRoute =
            isWorkerRoute && !isWorkerPublicRoute && !isWorkerOnboardingRoute;

        // Redirigir al selector de rol si no hay sesión y la ruta no es pública
        if (!isAuthenticated && !isPublicRoute) {
          return RouteNames.roleSelector;
        }

        if (isAuthenticated && isProtectedWorkerRoute) {
          if (!session.isWorker) {
            return RouteNames.clientHome;
          }

          if (!session.hasApprovedWorkerAccess) {
            return session.currentWorkerApplication == null
                ? RouteNames.workerApplication
                : RouteNames.workerPending;
          }
        }

        if (isAuthenticated && isWorkerOnboardingRoute) {
          if (!session.isWorker) {
            return RouteNames.clientHome;
          }

          if (session.hasApprovedWorkerAccess) {
            return RouteNames.workerHome;
          }

          final applicationStatus = session.currentWorkerApplication?.estado;
          if (currentPath == RouteNames.workerApplication &&
              applicationStatus != null) {
            return RouteNames.workerPending;
          }
          if (currentPath == RouteNames.workerPending &&
              applicationStatus == null) {
            return RouteNames.workerApplication;
          }
        }

        if (isAuthenticated && publicRoutes.contains(currentPath)) {
          final role = session.currentRole;
          if (role != null) {
            if (role == UserRole.trabajador) {
              final isApproved = session.hasApprovedWorkerAccess;
              if (isApproved) return RouteNames.workerHome;

              final applicationStatus =
                  session.currentWorkerApplication?.estado;
              return applicationStatus == null
                  ? RouteNames.workerApplication
                  : RouteNames.workerPending;
            }
            return RouteNames.clientHome;
          }
        }

        return null;
      },
      routes: [
        // ── Auth ──────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.roleSelector,
          name: 'roleSelector',
          builder: (context, state) => const RoleSelectorView(),
        ),
        GoRoute(
          path: RouteNames.clientLogin,
          name: 'clientLogin',
          builder: (context, state) => const ClientLoginView(),
        ),
        GoRoute(
          path: RouteNames.clientRegister,
          name: 'clientRegister',
          builder: (context, state) => const ClientRegisterView(),
        ),
        GoRoute(
          path: RouteNames.workerLogin,
          name: 'workerLogin',
          builder: (context, state) => const WorkerLoginView(),
        ),
        GoRoute(
          path: RouteNames.workerRegister,
          name: 'workerRegister',
          builder: (context, state) => const WorkerRegisterView(),
        ),
        GoRoute(
          path: RouteNames.workerApplication,
          name: 'workerApplication',
          builder: (context, state) => const WorkerApplicationView(),
        ),
        GoRoute(
          path: RouteNames.workerPending,
          name: 'workerPending',
          builder: (context, state) => const WorkerPendingView(),
        ),

        // ── Home Cliente ───────────────────────────────────────────
        GoRoute(
          path: RouteNames.clientHome,
          name: 'clientHome',
          builder: (context, state) => const ClientHomeView(),
        ),

        // ── Flujo de solicitud ────────────────────────────────────
        GoRoute(
          path: '${RouteNames.clientServiceSelection}/:categoryId',
          name: 'clientServiceSelection',
          builder: (context, state) => ServiceSelectionView(
            categoryId: state.pathParameters['categoryId'] ?? '',
          ),
        ),
        GoRoute(
          path: RouteNames.clientRequestForm,
          name: 'clientRequestForm',
          builder: (context, state) => RequestFormView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),
        GoRoute(
          path: RouteNames.clientRequestLocation,
          name: 'clientRequestLocation',
          builder: (context, state) => RequestLocationView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),
        GoRoute(
          path: RouteNames.clientWaitingWorkers,
          name: 'clientWaitingWorkers',
          builder: (context, state) => WaitingWorkersView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),
        GoRoute(
          path: RouteNames.clientWorkersCatalog,
          name: 'clientWorkersCatalog',
          builder: (context, state) => WorkersCatalogView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),
        GoRoute(
          path: '${RouteNames.clientWorkerProfile}/:workerId',
          name: 'clientWorkerProfile',
          builder: (context, state) {
            final worker = _extra<WorkerCatalogItemModel>(state.extra);
            if (worker == null) {
              return _missingRouteData(
                  'No se encontró el perfil del trabajador.');
            }
            return WorkerProfileDetailView(worker: worker);
          },
        ),
        GoRoute(
          path: RouteNames.clientBookingConfirmation,
          name: 'clientBookingConfirmation',
          builder: (context, state) {
            final extra = _extraMap(state.extra);
            return BookingConfirmationView(
              solicitud:
                  _extraValue<SolicitudServicioModel>(extra, 'solicitud'),
              trabajador:
                  _extraValue<WorkerCatalogItemModel>(extra, 'trabajador'),
            );
          },
        ),
        GoRoute(
          path: '${RouteNames.clientServiceTracking}/:solicitudId',
          name: 'clientServiceTracking',
          builder: (context, state) {
            final extra = _extraMap(state.extra);
            return ClientServiceTrackingView(
              solicitudId: state.pathParameters['solicitudId'],
              solicitud:
                  _extraValue<SolicitudServicioModel>(extra, 'solicitud'),
              trabajador:
                  _extraValue<WorkerCatalogItemModel>(extra, 'trabajador'),
            );
          },
        ),
        GoRoute(
          path: '${RouteNames.clientRateWorker}/:solicitudId',
          name: 'clientRateWorker',
          builder: (context, state) {
            final extra = _extraMap(state.extra);
            return RateWorkerView(
              trabajador:
                  _extraValue<WorkerCatalogItemModel>(extra, 'trabajador'),
              solicitudId: state.pathParameters['solicitudId'],
            );
          },
        ),

        // ── Secciones del cliente ─────────────────────────────────
        GoRoute(
          path: RouteNames.clientReviews,
          name: 'clientReviews',
          builder: (context, state) => const ClientReviewsView(),
        ),
        GoRoute(
          path: RouteNames.clientProfile,
          name: 'clientProfile',
          builder: (context, state) => const ClientProfileView(),
        ),
        GoRoute(
          path: RouteNames.clientMessages,
          name: 'clientMessages',
          builder: (context, state) => const ClientMessagesView(),
        ),
        GoRoute(
          path: RouteNames.clientPhotoOnboarding,
          name: 'clientPhotoOnboarding',
          builder: (context, state) => const ClientPhotoOnboardingView(),
        ),
        GoRoute(
          path: RouteNames.clientServiceHistory,
          name: 'clientServiceHistory',
          builder: (context, state) => const ClientServiceHistoryView(),
        ),
        GoRoute(
          path: RouteNames.clientChangePassword,
          name: 'clientChangePassword',
          builder: (context, state) => const ClientChangePasswordView(),
        ),
        GoRoute(
          path: RouteNames.clientSavedAddresses,
          name: 'clientSavedAddresses',
          builder: (context, state) => const ClientSavedAddressesView(),
        ),
        GoRoute(
          path: RouteNames.clientSupport,
          name: 'clientSupport',
          builder: (context, state) => const ClientSupportView(),
        ),

        // ── Home Trabajador ───────────────────────────────────────
        GoRoute(
          path: RouteNames.workerHome,
          name: 'workerHome',
          builder: (context, state) => const WorkerHomeView(),
        ),

        // ── Flujo del trabajador ──────────────────────────────────

        /// Detalle de una solicitud disponible para postularse
        GoRoute(
          path: '${RouteNames.workerRequestDetail}/:solicitudId',
          name: 'workerRequestDetail',
          builder: (context, state) {
            final solicitud = _extra<SolicitudServicioModel>(state.extra);
            if (solicitud == null) {
              return _missingRouteData('No se encontró la solicitud.');
            }
            return WorkerRequestDetailView(solicitud: solicitud);
          },
        ),

        /// Lista de postulaciones del trabajador
        GoRoute(
          path: RouteNames.workerApplications,
          name: 'workerApplications',
          builder: (context, state) => const WorkerApplicationsView(),
        ),

        /// Servicio confirmado — antes de marcar en camino
        GoRoute(
          path: '${RouteNames.workerConfirmedService}/:solicitudId',
          name: 'workerConfirmedService',
          builder: (context, state) => WorkerConfirmedServiceView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),

        /// Trabajo en curso — tracking de estados
        GoRoute(
          path: '${RouteNames.workerServiceTracking}/:solicitudId',
          name: 'workerServiceTracking',
          builder: (context, state) => WorkerServiceTrackingView(
            solicitud: _extra<SolicitudServicioModel>(state.extra),
          ),
        ),

        /// Calificar al cliente tras completar el servicio
        GoRoute(
          path: '${RouteNames.workerRateClient}/:solicitudId',
          name: 'workerRateClient',
          builder: (context, state) {
            final extra = _extraMap(state.extra);
            return RateClientView(
              solicitudId: _extraValue<String>(extra, 'solicitudId') ??
                  state.pathParameters['solicitudId'],
              clienteId: _extraValue<String>(extra, 'clienteId'),
            );
          },
        ),

        // ── Secciones del trabajador ──────────────────────────────
        GoRoute(
          path: RouteNames.workerReviews,
          name: 'workerReviews',
          builder: (context, state) => const WorkerReviewsView(),
        ),
        GoRoute(
          path: RouteNames.workerProfile,
          name: 'workerProfile',
          builder: (context, state) => const WorkerProfileView(),
        ),
        GoRoute(
          path: RouteNames.workerMessages,
          name: 'workerMessages',
          builder: (context, state) => const WorkerMessagesView(),
        ),

        // ── Chat compartido (cliente y trabajador) ────────────────
        /// /worker/chat/:chatId — navegando desde lista de chats
        GoRoute(
          path: '${RouteNames.workerChat}/:chatId',
          name: 'workerChat',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            final extra = _extraMap(state.extra);
            // Si viene una solicitud, abrir/crear el chat asociado a esa solicitud.
            // Algunas pantallas antiguas envian solicitudId en la URL en lugar de chatId.
            if (extra != null && extra.containsKey('solicitudId')) {
              return ChatView(
                args: ChatArgs.fromMap(extra),
              );
            }
            return ChatView(
                chatId: chatId == 'new' ? null : chatId,
                args: extra != null ? ChatArgs.fromMap(extra) : null);
          },
        ),

        /// /client/chat/:chatId
        GoRoute(
          path: '${RouteNames.clientChat}/:chatId',
          name: 'clientChat',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            final extra = _extraMap(state.extra);
            if (extra != null && extra.containsKey('solicitudId')) {
              return ChatView(
                args: ChatArgs.fromMap(extra),
              );
            }
            return ChatView(
                chatId: chatId == 'new' ? null : chatId,
                args: extra != null ? ChatArgs.fromMap(extra) : null);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Página no encontrada',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(RouteNames.roleSelector),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
