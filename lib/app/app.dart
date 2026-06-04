/// app.dart
/// Widget raíz de la aplicación HomeServiceSV.
/// Configura MultiProvider, GoRouter y ThemeData.
/// main.dart solo inicializa y llama a runApp(App()).
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../state/session_controller.dart';
import '../state/role_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Controllers globales de estado ───────────────────
        ChangeNotifierProvider<SessionController>(
          create: (_) => SessionController(),
        ),
        ChangeNotifierProvider<RoleController>(create: (_) => RoleController()),
      ],
      child: const _AppRoot(),
    );
  }
}

/// Widget interno que construye MaterialApp.router una vez que
/// los providers ya están disponibles en el contexto.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final _router = AppRouter.createRouter(context);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeServiceSV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
