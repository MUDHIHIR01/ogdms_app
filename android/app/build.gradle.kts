plugins {
    // Apply Android application plugin for building Android apps
    id("com.android.application")
    // Apply Kotlin Android plugin for Kotlin support
    id("kotlin-android")
    // Apply Flutter Gradle plugin after Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Define the app's namespace (unique identifier for the app)
    namespace = "com.example.untitled1"
    // Use Flutter's recommended compileSdk version
    compileSdk = flutter.compileSdkVersion
    // Set NDK version to match requirements of app_links and url_launcher_android
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Set Java source and target compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // Configure Kotlin JVM target to Java 11
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Unique application ID for the app
        applicationId = "com.example.untitled1"
        // Use Flutter's recommended minSdk and targetSdk versions
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Version code and name for the app
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing config for now; update with proper signing config for production
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Specify the Flutter source directory
    source = "../.."
}