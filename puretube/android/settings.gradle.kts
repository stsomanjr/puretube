pluginManagement {
    val flutterSdkPath =
        run {
            // Prefer local.properties (written by the flutter tool on a dev machine),
            // fall back to FLUTTER_ROOT (set by flutter-action on CI runners).
            val properties = java.util.Properties()
            val localProps = file("local.properties")
            val fromProps =
                if (localProps.exists()) {
                    localProps.inputStream().use { properties.load(it) }
                    properties.getProperty("flutter.sdk")?.takeIf { file(it).exists() }
                } else null
            fromProps
                ?: System.getenv("FLUTTER_ROOT")?.takeIf { file(it).exists() }
                ?: error("flutter.sdk not set in local.properties and FLUTTER_ROOT is not set")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
