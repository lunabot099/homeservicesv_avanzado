plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe aplicarse después de los plugins de Android y
    // Kotlin; cambiar el orden puede impedir que Gradle configure el proyecto.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Identifica el espacio de nombres del código Android. Debe mantenerse
    // alineado con el paquete de MainActivity cuando se defina la identidad final.
    namespace = "com.example.homeservicesv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Identificador único usado por Android y Google Play. Debe reemplazarse
        // antes de publicar y no conviene cambiarlo después de la primera entrega.
        applicationId = "com.example.homeservicesv"
        // Flutter administra estos valores según su versión y pubspec.yaml.
        // Si se fijan manualmente, hay que comprobar compatibilidad con plugins y tienda.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Configuración temporal para pruebas. Antes de Google Play debe
            // sustituirse por una firma release cuya clave esté fuera del repositorio.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
