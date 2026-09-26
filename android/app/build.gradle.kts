import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Architectures demandées à Flutter (`flutter build apk --target-platform …`,
// ou celle de l'appareil pour `flutter run`). Flutter n'en tient compte que pour
// son propre moteur : sans ce filtre, les bibliothèques natives des plugins
// (ML Kit, scanner, SQLite) restent embarquées pour toutes les architectures.
val flutterAbis = mapOf(
    "android-arm" to "armeabi-v7a",
    "android-arm64" to "arm64-v8a",
    "android-x64" to "x86_64",
    "android-x86" to "x86",
)
val targetAbis = (findProperty("target-platform") as String?)
    ?.split(",")
    ?.mapNotNull { flutterAbis[it.trim()] }
    ?.takeIf { it.isNotEmpty() && !hasProperty("split-per-abi") }

android {
    namespace = "com.example.ilwyrm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "fr.attadeurtia.ilwyrm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            if (keystoreProperties["storeFile"] != null) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            // R8 (réduction du code et des ressources) reste actif, comme par
            // défaut avec Flutter : les classes ML Kit optionnelles absentes sont
            // déclarées dans proguard-rules.pro.
        }
        if (targetAbis != null) {
            all {
                ndk {
                    abiFilters.clear()
                    abiFilters.addAll(targetAbis)
                }
            }
        }
    }
}

flutter {
    source = "../.."
}
