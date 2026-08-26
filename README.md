# HomeServiceSV

Aplicación multiplataforma desarrollada en Flutter para conectar clientes que
necesitan servicios para el hogar con trabajadores disponibles en El Salvador.

La aplicación utiliza Supabase para autenticación, base de datos, archivos y
comunicación en tiempo real. La versión publicada en GitHub Pages se usa como
demostración; el objetivo final es distribuir la aplicación en Google Play y
App Store.

> Antes de modificar la arquitectura, la base de datos o la publicación, lee
> [DOCUMENTACION_PROYECTO.md](DOCUMENTACION_PROYECTO.md).

## Funciones principales

### Cliente

- Registro, inicio de sesión y recuperación de contraseña.
- Perfil con fotografía.
- Publicación de solicitudes con descripción, presupuesto y ubicación.
- Imágenes adjuntas como evidencia del trabajo.
- Recepción y comparación de postulaciones.
- Selección y contratación de un trabajador.
- Chat y seguimiento del estado del servicio.
- Calificación del trabajador al finalizar.

### Trabajador

- Registro y envío de solicitud de aprobación.
- Carga de fotografía, DUI y antecedentes.
- Definición de especialidades, tarifa y zona de cobertura.
- Activación o desactivación de disponibilidad.
- Consulta de trabajos y envío de postulaciones.
- Chat y actualización del progreso del servicio.
- Calificación del cliente al finalizar.

## Tecnologías

- **Flutter y Dart:** interfaz y lógica compartida para Android, iOS y web.
- **Provider:** estado global y ViewModels.
- **GoRouter:** navegación.
- **Supabase Auth:** usuarios y sesiones.
- **Supabase PostgreSQL:** perfiles, solicitudes, chats y reseñas.
- **Supabase Storage:** fotografías y documentos.
- **Supabase Realtime:** actualización de mensajes.
- **flutter_map y OpenStreetMap:** mapas sin clave comercial.
- **GitHub Actions:** compilación y despliegue web en GitHub Pages.

## Estado actual

- El proyecto compila para Android en modo debug.
- `flutter analyze --no-fatal-infos` no presenta errores bloqueantes.
- Las pruebas automatizadas actuales terminan correctamente.
- La conexión local con Supabase utiliza una Publishable key válida.
- La versión web se publica mediante GitHub Actions.
- Android apunta a API 36.
- La firma Android de producción y la configuración final de iOS están pendientes.

Consulta la sección **Pendientes conocidos** antes de preparar una publicación.

## Requisitos de desarrollo

### General

- Git.
- Flutter estable compatible con Dart `>=3.5.4 <4.0.0`.
- Acceso autorizado al proyecto Supabase.

### Android

- Android Studio.
- Android SDK 36, Platform Tools y Build Tools.
- Java compatible con la versión de Gradle utilizada por Flutter.
- Emulador Android o teléfono con depuración USB.

Entorno verificado durante la última revisión:

```text
Flutter 3.47.1
Dart 3.13.1
Android SDK 36
Gradle 8.14
Android Gradle Plugin 8.11.1
Kotlin 2.2.20
```

### iOS

Para compilar, firmar o publicar iOS se necesita una Mac con Xcode y una cuenta
de Apple Developer. Windows permite editar el código Flutter, pero no generar
el archivo final firmado para App Store.

## Inicio rápido

1. Clona el repositorio oficial.
2. Abre una terminal en la carpeta que contiene `pubspec.yaml`.
3. Crea `.env` a partir de `.env.example`.
4. Completa únicamente la URL y clave pública del mismo proyecto Supabase.
5. Descarga dependencias y ejecuta las verificaciones.

```powershell
git clone https://github.com/lunabot099/homeservicesv_avanzado.git
cd homeservicesv_avanzado
Copy-Item .env.example .env
flutter doctor -v
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter devices
flutter run
```

En macOS o Linux, crea el archivo con:

```bash
cp .env.example .env
```

## Repositorio y flujo de ramas

Repositorio oficial: <https://github.com/lunabot099/homeservicesv_avanzado>

- `main`: código estable de producción y base de publicación web.
- `develop`: integración del sprint actual antes de promover cambios a `main`.
- Ramas de trabajo:
  - `feature/nombre-tarea` para nuevas funcionalidades.
  - `fix/nombre-bug` para correcciones.
  - `chore/tarea-mantenimiento` para mantenimiento, configuración o documentación.

Las ramas `main` y `develop` están pensadas para recibir cambios únicamente por
Pull Request. Cada PR debe tener al menos una aprobación de revisión antes de
fusionarse. Los colaboradores del equipo deben trabajar en ramas cortas,
mantener su rama actualizada con `develop` y ejecutar las verificaciones locales
antes de solicitar revisión.

Para añadir desarrolladores, el propietario del repositorio debe invitarlos desde
**Settings → Collaborators and teams** con permiso **Write** o superior, según su
responsabilidad en el proyecto.

## Configuración de Supabase

El `.env` local debe estar en la raíz, junto a `pubspec.yaml`:

```dotenv
SUPABASE_URL=https://TU-PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_PUBLISHABLE_KEY
BUCKET_PERFIL_FOTOS=perfil-fotos
BUCKET_DUI_DOCUMENTOS=dui-documentos
BUCKET_ANTECEDENTES_DOCUMENTOS=antecedentes-documentos
BUCKET_SOLICITUDES_IMAGENES=solicitudes-imagenes
BUCKET_CHAT_IMAGENES=chat-imagenes
```

Reglas de seguridad:

- La URL debe ser base, sin `/rest/v1`.
- La URL y la Publishable key deben pertenecer al mismo proyecto.
- La Publishable key puede guardarse en `SUPABASE_ANON_KEY`; ese es el nombre
  que lee el código actual.
- Nunca colocar `service_role`, `sb_secret_` ni contraseñas dentro de Flutter.
- Nunca subir `.env` a GitHub.
- Si cambia un bucket, actualizar Supabase, `.env.example` y el workflow web.

## Estructura del proyecto

```text
.
├── README.md                     Guía inicial para colaboradores
├── DOCUMENTACION_PROYECTO.md     Referencia técnica detallada
├── .env.example                  Plantilla sin credenciales
├── pubspec.yaml                  Dependencias, versión y recursos
├── lib/
│   ├── main.dart                 Carga configuración e inicia la aplicación
│   ├── app/                      Router, tema y configuración global
│   ├── core/                     Utilidades y widgets reutilizables
│   ├── data/
│   │   ├── models/               Mapeo de datos de Supabase
│   │   ├── repositories/         Operaciones de cada caso de uso
│   │   └── services/             Consultas directas a Supabase
│   ├── features/
│   │   ├── auth/                 Registro, login y selección de rol
│   │   ├── client/               Funciones del cliente
│   │   ├── worker/               Funciones del trabajador
│   │   └── shared/               Funciones compartidas, como chat
│   └── state/                    Sesión y rol global
├── supabase/                     Esquema, reparaciones y políticas SQL
├── android/                      Configuración nativa Android
├── ios/                          Configuración nativa iOS
├── web/                          Contenedor de la versión web
├── test/                         Pruebas automatizadas
└── .github/workflows/            Automatización de GitHub Pages
```

El flujo recomendado es:

```text
Vista → ViewModel → Repository → Service → Supabase
```

## Dónde modificar cada cosa

| Necesidad | Ubicación principal |
|---|---|
| Agregar o cambiar una pantalla | `lib/features/<rol>/<funcion>/` |
| Cambiar estado o acciones de pantalla | Archivo `*_viewmodel.dart` de la función |
| Agregar una ruta | `lib/app/router/route_names.dart` y `app_router.dart` |
| Cambiar colores o tipografía | `lib/app/theme/` |
| Crear un widget reutilizable | `lib/core/widgets/` |
| Cambiar el mapeo de una tabla | `lib/data/models/` |
| Cambiar consultas a Supabase | `lib/data/services/` |
| Cambiar lógica de un caso de uso | `lib/data/repositories/` y ViewModel |
| Cambiar variables de entorno | `.env.example` y `lib/app/config/env.dart` |
| Cambiar tablas, índices o RLS | Crear/revisar un SQL en `supabase/` |
| Configurar Android | `android/` |
| Configurar iOS | `ios/` |
| Cambiar despliegue web | `.github/workflows/deploy-pages.yml` |

## Comandos habituales

```powershell
# Formatear código Dart
dart format lib test

# Análisis estático
flutter analyze --no-fatal-infos

# Pruebas
flutter test

# Ejecutar en un dispositivo seleccionado
flutter run

# APK de prueba
flutter build apk --debug

# AAB de prueba
flutter build appbundle --debug

# Versión web
flutter build web --release
```

## Publicación web

El workflow `.github/workflows/deploy-pages.yml` compila la rama `main` y
publica `build/web` en `gh-pages`.

El repositorio debe tener estos Secrets de GitHub Actions:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` con la Publishable key

Si cambia el nombre del repositorio, también debe cambiar el `--base-href` del
workflow.

## Pendientes conocidos

### Funcionales y de seguridad

- Revisar `mensajes_chat.emisor_id`: la base lo presenta como UUID y el código
  utiliza `system` para mensajes automáticos.
- Confirmar si la fecha de creación de `chats` es `creado_en` o
  `fecha_creacion` en la base vigente.
- Confirmar que `formulario_trabajador` tenga `user_id` y los campos nuevos.
- Restringir las políticas de escritura y eliminación de imágenes compartidas.
- Revisar si `chat-imagenes` debe ser privado y utilizar URLs firmadas.
- Configurar deep links para confirmación de correo y recuperación de contraseña.

### Google Play

- Definir el identificador final; actualmente es `com.example.homeservicesv`.
- Cambiar el nombre visible e íconos de producción.
- Agregar el permiso `INTERNET` al manifiesto principal de Android.
- Actualizar en una tarea separada AGP a 9.0.1 o superior y Kotlin a 2.3.20
  o superior; Flutter advierte que pronto retirará soporte a las versiones actuales.
- Crear keystore y firma release; actualmente release usa firma debug.
- Generar y probar el AAB en una pista interna.
- Preparar política de privacidad, Data Safety y ficha de tienda.

### App Store

- Definir Bundle Identifier y nombre comercial.
- Configurar Apple Developer, equipo y firma en Xcode.
- Agregar permisos de cámara y fototeca en `Info.plist`.
- Revisar si se necesita únicamente ubicación mientras la app está en uso.
- Sustituir íconos y pantalla de lanzamiento predeterminados.
- Probar la aplicación mediante TestFlight.
- Completar App Privacy en App Store Connect.

## Cómo colaborar sin romper el proyecto

1. Actualiza tu rama y revisa el estado del repositorio.
2. Crea una rama por tarea.
3. No mezcles documentación, base de datos y diseño en un único cambio grande.
4. No modifiques producción manualmente sin guardar el SQL correspondiente.
5. Ejecuta formato, análisis y pruebas antes de solicitar revisión.
6. Comprueba que el diff no contenga secretos ni documentos de usuarios.

```powershell
git pull
git switch -c feature/nombre-corto
flutter pub get

# Después de trabajar
dart format lib test
flutter analyze --no-fatal-infos
flutter test
git diff
```

## Documentación completa

Consulta [DOCUMENTACION_PROYECTO.md](DOCUMENTACION_PROYECTO.md) para conocer:

- Arquitectura y responsabilidades por capa.
- Flujos completos de cliente y trabajador.
- Tablas, buckets y políticas de Supabase.
- Configuración web, Android e iOS.
- Riesgos conocidos y proceso de publicación.
- Solución de problemas y lista de verificación por cambio.
