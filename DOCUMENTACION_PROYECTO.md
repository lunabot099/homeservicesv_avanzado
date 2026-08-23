# Documentación técnica de HomeServiceSV

Este documento describe la arquitectura, configuración, flujos y estado técnico
de HomeServiceSV. Está dirigido a las personas que mantendrán o ampliarán el
proyecto.

Para instalar y ejecutar rápidamente la aplicación, empieza por
[README.md](README.md).

## 1. Objetivo del proyecto

HomeServiceSV conecta dos tipos de usuario:

- **Cliente:** publica una necesidad, recibe postulaciones, selecciona un
  trabajador, conversa, sigue el servicio y califica.
- **Trabajador:** completa un proceso de aprobación, configura su perfil,
  revisa trabajos, se postula, realiza el servicio y califica al cliente.

Flutter comparte la interfaz y lógica principal entre Android, iOS y web. La
versión de GitHub Pages es una demostración para el equipo; las versiones de
tienda necesitan configuración, firma y revisión específica por plataforma.

## 2. Estado técnico verificado

Durante la última revisión se comprobó:

- Flutter 3.47.1 y Dart 3.13.1.
- Android SDK 36.
- Gradle 8.14.
- Android Gradle Plugin 8.11.1.
- Kotlin 2.2.20.
- `flutter analyze --no-fatal-infos` sin errores bloqueantes.
- Prueba automatizada actual aprobada.
- APK debug generado correctamente.
- Conectividad de Supabase Auth y PostgREST con Publishable key.
- Despliegue web disponible mediante GitHub Pages.

El APK inspeccionado utiliza:

```text
applicationId = com.example.homeservicesv
minSdk        = 24
targetSdk     = 36
nombre        = homeservicesv
```

Estos valores sirven para desarrollo, pero el identificador y nombre todavía no
son definitivos para tienda.

## 3. Tecnologías y responsabilidades

| Tecnología | Responsabilidad |
|---|---|
| Flutter y Dart | Interfaz y lógica multiplataforma |
| Provider | Estado global y ViewModels |
| GoRouter | Navegación y rutas |
| Supabase Auth | Registro, login, sesión y recuperación |
| Supabase PostgreSQL | Datos de usuarios, servicios, chats y reseñas |
| Supabase Storage | Fotografías y documentos |
| Supabase Realtime | Actualización de mensajes |
| flutter_dotenv | Lectura de configuración desde `.env` |
| flutter_map / OpenStreetMap | Mapas sin clave comercial |
| Geolocator | Ubicación actual y zona de cobertura |
| Image Picker / File Picker | Selección de imágenes y documentos |
| Shared Preferences | Persistencia local de datos de sesión o preferencias |
| GitHub Actions | Compilación y despliegue web |

Las versiones exactas de paquetes Dart se encuentran en `pubspec.lock`. No se
deben actualizar dependencias en una tarea de funcionalidad sin revisar cambios
incompatibles y ejecutar las pruebas.

## 4. Arquitectura

El flujo recomendado es:

```text
Vista → ViewModel → Repository → Service → Supabase
```

### Vista

Archivo habitual: `*_view.dart`.

Responsabilidades:

- Renderizar información.
- Mostrar carga, vacío y error.
- Recoger acciones del usuario.
- Delegar operaciones al ViewModel.

No debería contener consultas directas a Supabase.

### ViewModel

Archivo habitual: `*_viewmodel.dart`.

Responsabilidades:

- Coordinar acciones de la pantalla.
- Mantener carga, datos y mensajes de error.
- Validar el flujo antes de llamar al repositorio.
- Notificar cambios mediante `ChangeNotifier`.

### Repository

Ubicación: `lib/data/repositories/`.

Responsabilidades:

- Representar operaciones de negocio.
- Combinar uno o varios servicios.
- Evitar que la interfaz dependa de detalles de Supabase.

### Service

Ubicación: `lib/data/services/`.

Responsabilidades:

- Ejecutar consultas concretas a Supabase.
- Seleccionar, insertar, actualizar o eliminar datos.
- Aplicar filtros y ordenamiento de PostgREST.
- Subir o eliminar archivos de Storage.

Modificar una columna usada aquí exige revisar su modelo, SQL y políticas RLS.

### Model

Ubicación: `lib/data/models/`.

Responsabilidades:

- Convertir mapas de Supabase a objetos Dart.
- Convertir objetos Dart a mapas para inserción o actualización.
- Normalizar nulls, números, arreglos y fechas.

Los nombres de columnas no deben traducirse ni cambiarse solo por estilo: deben
coincidir exactamente con PostgreSQL.

## 5. Estructura del repositorio

```text
.
├── README.md
├── DOCUMENTACION_PROYECTO.md
├── .env.example
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── config/
│   │   ├── router/
│   │   └── theme/
│   ├── core/
│   │   ├── constants/
│   │   ├── utils/
│   │   └── widgets/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── features/
│   │   ├── auth/
│   │   ├── client/
│   │   ├── worker/
│   │   └── shared/
│   └── state/
├── supabase/
├── android/
├── ios/
├── web/
├── test/
└── .github/workflows/
```

## 6. Regla para agregar o modificar una función

1. Crea o modifica la pantalla en
   `lib/features/<rol>/<funcion>/<funcion>_view.dart`.
2. Mantén estado y acciones en el `*_viewmodel.dart` correspondiente.
3. Agrega o ajusta el modelo en `lib/data/models/` si cambia la forma de datos.
4. Modifica la consulta en `lib/data/services/`.
5. Expón la operación desde `lib/data/repositories/`.
6. Declara rutas en `route_names.dart` y configúralas en `app_router.dart`.
7. Mueve componentes compartidos a `lib/core/widgets/`.
8. Centraliza colores y estilos en `lib/app/theme/`.
9. Guarda cambios de base de datos en un SQL nuevo dentro de `supabase/`.
10. Prueba el flujo completo y sus permisos, no solo la pantalla aislada.

No mezclar en una misma tarea una refactorización amplia, cambios de RLS y un
rediseño visual si pueden revisarse por separado.

## 7. Arranque de la aplicación

`lib/main.dart` realiza, en orden:

1. Inicialización de bindings de Flutter.
2. Carga de `.env` mediante `flutter_dotenv`.
3. Inicialización del cliente Supabase.
4. Ejecución del widget `App`.

`lib/app/app.dart` registra controladores globales y crea el router.

Si `.env` no existe o no está declarado como asset, la aplicación no termina de
crear su bundle. Si la URL o clave son inválidas, la interfaz puede iniciar, pero
las operaciones remotas fallarán.

## 8. Configuración de entorno

El archivo `.env` se crea localmente en la raíz:

```dotenv
SUPABASE_URL=https://TU-PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_PUBLISHABLE_KEY
BUCKET_PERFIL_FOTOS=perfil-fotos
BUCKET_DUI_DOCUMENTOS=dui-documentos
BUCKET_ANTECEDENTES_DOCUMENTOS=antecedentes-documentos
BUCKET_SOLICITUDES_IMAGENES=solicitudes-imagenes
BUCKET_CHAT_IMAGENES=chat-imagenes
```

### Reglas

- `SUPABASE_URL` debe ser base, sin `/rest/v1`.
- La URL y clave deben pertenecer al mismo proyecto.
- `SUPABASE_ANON_KEY` admite la Publishable key nueva de Supabase.
- No usar `service_role`, `sb_secret_` ni secretos de firma.
- `.env` es local y debe permanecer ignorado por Git.
- `.env.example` sí se sube porque no contiene credenciales.
- Los valores para GitHub Pages se guardan como Secrets del repositorio.

El acceso centralizado se encuentra en `lib/app/config/env.dart`. No se deben
hardcodear nombres de buckets o credenciales en vistas y servicios.

## 9. Flujos funcionales

### 9.1 Cliente

1. Selecciona el rol cliente.
2. Se registra o inicia sesión.
3. Completa su perfil y fotografía.
4. Elige categoría y subcategoría.
5. Describe el trabajo y puede adjuntar imágenes.
6. Define urgencia, presupuesto y forma de pago.
7. Indica dirección o ubicación GPS.
8. Publica la solicitud.
9. Revisa postulaciones y perfiles.
10. Selecciona un trabajador y confirma el servicio.
11. Conversa y consulta el seguimiento.
12. Finaliza y califica al trabajador.

Pantallas: `lib/features/client/`.

### 9.2 Trabajador

1. Selecciona el rol trabajador.
2. Se registra.
3. Completa el formulario con datos y documentos.
4. Espera aprobación administrativa.
5. Configura especialidades, tarifa y cobertura.
6. Activa su disponibilidad.
7. Consulta solicitudes disponibles.
8. Envía una postulación con mensaje y precio.
9. Si es seleccionado, accede al servicio confirmado.
10. Conversa y actualiza el progreso.
11. Finaliza y califica al cliente.

Pantallas: `lib/features/worker/`.

### 9.3 Chat

La interfaz compartida se encuentra en `lib/features/shared/chat/`.

Los archivos se guardan en Storage y la tabla `mensajes_chat` conserva su URL.
El stream Realtime filtra por `chat_id`.

Antes de ampliar mensajes automáticos debe resolverse el tipo de `emisor_id`:
la base visible lo presenta como UUID y el código utiliza el texto `system`.

## 10. Supabase

### 10.1 Tablas principales

| Tabla | Uso |
|---|---|
| `perfiles` | Datos comunes y rol de cada usuario |
| `worker_profiles` | Perfil profesional, aprobación y disponibilidad |
| `formulario_trabajador` | Solicitud y documentos del aspirante |
| `solicitudes_servicio` | Trabajos publicados por clientes |
| `postulaciones_solicitud` | Propuestas enviadas por trabajadores |
| `chats` | Relación entre solicitud, cliente y trabajador |
| `mensajes_chat` | Mensajes y referencias de archivos |
| `resenas` | Calificaciones en ambas direcciones |

### 10.2 Buckets

| Bucket | Contenido esperado |
|---|---|
| `perfil-fotos` | Fotografías públicas de perfil |
| `dui-documentos` | Documentos privados de identidad |
| `antecedentes-documentos` | Antecedentes privados |
| `solicitudes-imagenes` | Evidencia de solicitudes |
| `chat-imagenes` | Imágenes de conversaciones |

### 10.3 SQL disponible

- `app_schema_repair.sql`: esquema consolidado, índices, buckets y RLS.
- `approve_worker_by_email.sql`: aprobación administrativa por correo.
- `resenas_setup.sql`: configuración de reseñas.
- `repair_resenas_foreign_key.sql`: reparación de relaciones de reseñas.
- `solicitudes_imagenes_setup.sql`: imágenes de solicitudes.

Antes de ejecutar cualquier script:

1. Confirma el proyecto Supabase seleccionado.
2. Lee el script completo.
3. Respalda datos si altera o elimina información.
4. Ejecuta primero en un entorno de prueba si existe.
5. Comprueba RLS con un cliente y un trabajador diferentes.
6. Guarda en el repositorio el SQL realmente utilizado.

### 10.4 RLS

Nunca desactivar RLS como solución rápida. Cuando una operación sea rechazada:

1. Confirma que existe sesión válida.
2. Revisa `auth.uid()` y los UUID involucrados.
3. Identifica tabla, operación y política exacta.
4. Comprueba `using` y `with check`.
5. Verifica que el usuario sea propietario o participante del recurso.

### 10.5 Riesgos detectados

- Las políticas de `solicitudes-imagenes` y `chat-imagenes` permiten operaciones
  demasiado amplias para usuarios autenticados.
- `chat-imagenes` aparece como público; conviene revisar si debe ser privado.
- Las rutas de solicitudes deberían validar que el usuario sea su cliente.
- Las rutas de chat deberían validar participación en el chat.
- `mensajes_chat.emisor_id` debe ser compatible con mensajes del sistema.
- El esquema de `chats` conserva nombres de fecha que deben confirmarse.
- `formulario_trabajador.user_id` debe existir para las consultas actuales.
- `resenas` conserva columnas heredadas y nuevas; deben consolidarse con una
  migración planificada, no eliminando columnas directamente en producción.

## 11. Publicación web

Workflow: `.github/workflows/deploy-pages.yml`.

Proceso:

1. Checkout de `main`.
2. Instalación de Flutter estable.
3. Creación temporal de `.env` desde GitHub Secrets.
4. Descarga de dependencias.
5. Análisis estático.
6. Compilación web con el `base-href` del repositorio.
7. Publicación de `build/web` en `gh-pages`.

Secrets requeridos:

- `SUPABASE_URL`.
- `SUPABASE_ANON_KEY` con la Publishable key.

Si cambia el nombre del repositorio, actualizar `--base-href`. La web publicada
no demuestra que el `.env` local sea igual: son configuraciones independientes.

## 12. Android y Google Play

### Configuración actual

- Identificador y namespace: `com.example.homeservicesv`.
- Nombre visible: `homeservicesv`.
- `minSdk`: 24.
- `targetSdk`: 36.
- Release usa la firma debug.
- Existen permisos de ubicación.
- El permiso de Internet solo está en manifiestos debug/profile.

### Pendientes

1. Definir identificador definitivo antes de publicar.
2. Cambiar `applicationId`, `namespace`, paquete y ruta de `MainActivity`.
3. Cambiar nombre visible.
4. Agregar `android.permission.INTERNET` al manifiesto principal.
5. Planificar la actualización de AGP 8.11.1 a 9.0.1 o superior y Kotlin
   2.2.20 a 2.3.20 o superior; Flutter 3.47.1 los marca como próximos a dejar
   de ser compatibles. Hacerlo en una tarea separada y verificar plugins.
6. Sustituir íconos predeterminados.
7. Crear keystore y upload key fuera del repositorio.
8. Crear `android/key.properties` e ignorarlo.
9. Configurar `signingConfigs.release`.
10. Incrementar `version` en cada entrega.
11. Generar AAB release.
12. Probarlo en una pista interna de Google Play.
13. Completar política de privacidad, Data Safety y ficha de tienda.

No cambiar el identificador después de crear la aplicación definitiva en Play
Console sin revisar las consecuencias: identifica a la app instalada.

## 13. iOS y App Store

### Configuración actual

- Bundle Identifier: `com.example.homeservicesv`.
- Nombre visible: `Homeservicesv`.
- Deployment target: iOS 12.0.
- No hay equipo de desarrollo configurado.
- Existe descripción para ubicación.
- Faltan descripciones de cámara y fototeca.
- No hay URL schemes o Associated Domains para deep links.
- Íconos y pantalla de inicio deben revisarse como recursos de producción.

### Pendientes

1. Usar una Mac con Xcode y Apple Developer.
2. Definir Bundle Identifier definitivo.
3. Registrar App ID y aplicación en App Store Connect.
4. Configurar equipo, certificados y firma.
5. Agregar permisos de cámara y fototeca en `Info.plist`.
6. Mantener solo los permisos de ubicación realmente necesarios.
7. Configurar deep links para Auth.
8. Sustituir íconos y launch screen.
9. Compilar con el SDK exigido por App Store en la fecha de entrega.
10. Probar en un iPhone real y mediante TestFlight.
11. Completar App Privacy, clasificación, capturas y datos de revisión.

No es posible generar ni firmar la entrega final de iOS desde Windows.

## 14. Deep links y Supabase Auth

Actualmente la recuperación utiliza `resetPasswordForEmail` sin una redirección
móvil explícita y no se encontraron intent filters o URL schemes.

Para producción:

1. Definir un esquema o dominio universal de la app.
2. Configurarlo en Android y iOS.
3. Registrar las URLs permitidas en Supabase Auth.
4. Pasar la URL correspondiente al envío de recuperación o confirmación.
5. Probar instalación limpia, correo, navegador y retorno a la app.

No asumir que el flujo web funcionará automáticamente en móvil.

## 15. Comandos de calidad y compilación

```powershell
# Dependencias
flutter pub get

# Formato
dart format lib test

# Análisis
flutter analyze --no-fatal-infos

# Pruebas
flutter test

# APK debug
flutter build apk --debug

# AAB debug
flutter build appbundle --debug

# Web
flutter build web --release
```

Cuando la firma Android esté lista:

```powershell
flutter clean
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build appbundle --release
```

Resultado esperado:

```text
build/app/outputs/bundle/release/app-release.aab
```

La compilación iOS y el archive para App Store deben ejecutarse en macOS.

## 16. Lista de verificación por cambio

- [ ] La pantalla muestra carga, vacío, contenido y error.
- [ ] La navegación hacia adelante y atrás funciona.
- [ ] La operación persiste en Supabase.
- [ ] RLS impide leer o modificar recursos ajenos.
- [ ] Los archivos se guardan en el bucket y ruta correctos.
- [ ] Se probó cliente y trabajador cuando corresponde.
- [ ] La función funciona en web y en la plataforma móvil afectada.
- [ ] Los permisos solicitados son necesarios y están explicados.
- [ ] `dart format lib test` termina correctamente.
- [ ] `flutter analyze --no-fatal-infos` no tiene errores bloqueantes.
- [ ] `flutter test` termina correctamente.
- [ ] El diff no contiene `.env`, secretos ni documentos reales.
- [ ] La documentación se actualizó si cambió arquitectura o configuración.

## 17. Cómo colaborar

Antes de empezar:

```powershell
git pull
git status
flutter pub get
```

Crea una rama específica:

```powershell
git switch -c feature/nombre-corto
```

Antes de entregar:

```powershell
dart format lib test
flutter analyze --no-fatal-infos
flutter test
git diff
```

Buenas prácticas:

- Commits pequeños y descriptivos.
- No incluir secretos.
- No reescribir migraciones ya aplicadas; crear una nueva.
- No modificar nombres de columnas sin actualizar modelo, servicio, SQL y RLS.
- No agregar dependencias sin justificar la necesidad y revisar plataformas.
- Explicar decisiones no obvias en comentarios, no narrar cada línea.

## 18. Solución de problemas

### Falta `.env`

Cópialo desde `.env.example`, completa URL y Publishable key, y confirma que
`pubspec.yaml` lo incluye en assets.

### `Invalid API key`

- Confirma que la URL y clave son del mismo proyecto.
- Usa la Publishable key, no la Secret key.
- Guarda el archivo correcto en la raíz.
- Reinicia la aplicación; los assets se empaquetan al compilar.

### Permiso denegado en Supabase

Revisa sesión, UUID, operación y política RLS. No uses `service_role` como atajo.

### No sube un archivo

Revisa autenticación, bucket, ruta, tamaño, MIME y políticas de
`storage.objects`.

### Android debug funciona pero release no tiene red

Confirma que `android.permission.INTERNET` esté en el manifiesto principal, no
solo en debug/profile.

### Recuperación de contraseña vuelve a una página web

Configura deep links móviles y URLs permitidas en Supabase Auth.

### GitHub Pages falla

Revisa Actions, Secrets y `--base-href`. No copies `.env` al repositorio.

### iOS no compila en Windows

Es una limitación del toolchain de Apple. Usa una Mac con Xcode.

## 19. Prioridades recomendadas

1. Probar todos los flujos con cuentas separadas de cliente y trabajador.
2. Corregir inconsistencias de esquema y mensajes del sistema.
3. Endurecer RLS y Storage.
4. Configurar deep links.
5. Definir nombre, identificador e imagen final.
6. Preparar Android release y prueba interna.
7. Preparar iOS en una Mac y distribuir con TestFlight.
8. Crear política de privacidad y declaraciones de tienda.
9. Publicar únicamente después de probar builds release.

## 20. Referencias oficiales

- Flutter: https://docs.flutter.dev/
- Supabase Flutter: https://supabase.com/docs/reference/dart/introduction
- Requisitos de API de Google Play:
  https://developer.android.com/google/play/requirements/target-sdk
- Firma Android:
  https://developer.android.com/studio/publish/app-signing
- Envío a App Store:
  https://developer.apple.com/ios/submit/
- Image Picker para Flutter: https://pub.dev/packages/image_picker

Este documento debe actualizarse cuando cambien la arquitectura, el esquema de
Supabase, las variables, los permisos, el flujo principal o el proceso de
publicación.
