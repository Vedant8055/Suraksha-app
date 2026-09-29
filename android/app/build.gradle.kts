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
var releaseKeystoreFile: java.io.File? = null
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
    val storeFileProp = keystoreProperties["storeFile"]?.toString()?.trim().orEmpty()
    if (storeFileProp.isNotEmpty()) {
        val candidate = file(storeFileProp)
        if (candidate.isFile) {
            releaseKeystoreFile = candidate
        } else {
            logger.warn(
                "Release keystore missing at ${candidate.absolutePath}. " +
                    "Release builds will fall back to debug signing so the APK still builds.",
            )
        }
    }
} else {
    logger.warn(
        "android/key.properties not found. Release builds will use debug signing. " +
            "See android/key.properties.example when you need a store-signed release.",
    )
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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
        if (releaseKeystoreFile != null) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = releaseKeystoreFile
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Prefer upload keystore when present; otherwise debug-sign so local/client demos still build.
            val releaseSigning = signingConfigs.findByName("release")
            signingConfig = releaseSigning ?: signingConfigs.getByName("debug")
            // Skip R8 when falling back to debug signing — avoids long/failing minify on demo builds.
            val storeSigned = releaseSigning != null
            isMinifyEnabled = storeSigned
            isShrinkResources = storeSigned
            if (storeSigned) {
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro",
                )
            }
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
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
