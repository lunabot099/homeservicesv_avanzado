// main.dart
// Punto de entrada de HomeServiceSV.
// Inicializa: flutter bindings, variables de entorno y Supabase.
// Luego delega todo a App() — sin lógica de negocio aquí.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/config/supabase_config.dart';

Future<void> main() async {
  // Garantiza que los bindings de Flutter estén listos antes de
  // llamar a código nativo (Supabase, plugins, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo .env
  await dotenv.load(fileName: '.env');

  // Inicializa Supabase con las credenciales del .env
  await SupabaseConfig.initialize();

  // Arranca la app — toda la lógica vive en App()
  runApp(const App());
}
