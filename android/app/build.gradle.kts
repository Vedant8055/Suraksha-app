import java.util.Properties

fun loadGoogleMapsApiKey(): String {
    val localProperties = Properties()
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use(localProperties::load)
    }
    return sequenceOf(
        localProperties.getProperty("GOOGLE_MAPS_API_KEY"),
        providers.gradleProperty("GOOGLE_MAPS_API_KEY").orNull,
        System.getenv("GOOGLE_MAPS_API_KEY"),
    ).mapNotNull { it?.trim() }.firstOrNull { it.isNotEmpty() } ?: ""
}

val googleMapsApiKey = loadGoogleMapsApiKey()
if (googleMapsApiKey.isEmpty()) {
    logger.warn(
        "GOOGLE_MAPS_API_KEY is empty. Safety Map tiles will be blank. " +
            "Add GOOGLE_MAPS_API_KEY to android/local.properties (see local.properties.example).",
    )
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}
val releaseRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (releaseRequested && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Release signing is not configured. Create android/key.properties or provide it in CI.",
    )
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

android {
    namespace = "com.suraksha.womensafety"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.suraksha.womensafety"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Apply Google Services only when Firebase config is present so local/CI
// builds without google-services.json still compile (FCM stays offline).
val googleServicesJson = file("google-services.json")
if (googleServicesJson.exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn(
        "google-services.json is missing under android/app/. " +
            "Remote FCM will stay disabled until the Firebase Android config is added.",
    )
}
