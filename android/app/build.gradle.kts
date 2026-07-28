import java.net.URI
import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "pl.budowapro"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "pl.budowapro"
        minSdk = 28
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

}

val decodedDartDefines = (project.findProperty("dart-defines") as String?)
    .orEmpty()
    .split(',')
    .mapNotNull { encoded ->
        runCatching {
            String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
        }.getOrNull()
    }
    .mapNotNull { define ->
        val parts = define.split('=', limit = 2)
        if (parts.size == 2) parts[0] to parts[1] else null
    }
    .toMap()

val validateLegalReleaseConfig = tasks.register("validateLegalReleaseConfig") {
    group = "verification"
    description = "Validates publisher metadata required in release artifacts."
    doLast {
        val requiredLegalDefines = listOf(
            "BUDOWAPRO_PUBLISHER_NAME",
            "BUDOWAPRO_PRIVACY_CONTACT_EMAIL",
            "BUDOWAPRO_PRIVACY_POLICY_URL",
        )
        val missingLegalDefines = requiredLegalDefines.filter {
            decodedDartDefines[it].isNullOrBlank()
        }
        require(missingLegalDefines.isEmpty()) {
            "Missing release dart-defines: ${missingLegalDefines.joinToString()}"
        }
        val publisherName = decodedDartDefines.getValue(
            "BUDOWAPRO_PUBLISHER_NAME",
        ).trim()
        require(publisherName.length <= 160) {
            "BUDOWAPRO_PUBLISHER_NAME must not exceed 160 characters."
        }
        val privacyPolicyUrl = decodedDartDefines.getValue(
            "BUDOWAPRO_PRIVACY_POLICY_URL",
        )
        val privacyPolicyUri = runCatching { URI(privacyPolicyUrl) }.getOrNull()
        val privacyHost = privacyPolicyUri?.host.orEmpty().lowercase()
        val hasPublicHost =
            privacyHost.contains('.') &&
                privacyHost != "localhost" &&
                !privacyHost.endsWith(".localhost") &&
                !privacyHost.endsWith(".local") &&
                !privacyHost.endsWith(".internal") &&
                !Regex("^\\d{1,3}(?:\\.\\d{1,3}){3}\$").matches(privacyHost)
        require(
            privacyPolicyUri?.scheme == "https" &&
                hasPublicHost &&
                !privacyPolicyUri.path.orEmpty().endsWith(
                    ".pdf",
                    ignoreCase = true,
                ),
        ) {
            "BUDOWAPRO_PRIVACY_POLICY_URL must be a public HTTPS, non-PDF URL."
        }
        val privacyContactEmail = decodedDartDefines.getValue(
            "BUDOWAPRO_PRIVACY_CONTACT_EMAIL",
        )
        require(
            privacyContactEmail.length <= 254 &&
                Regex(
                    "^[A-Za-z0-9.!#\$%&'*+/=?^_`{|}~-]+@" +
                        "[A-Za-z0-9-]+(?:\\.[A-Za-z0-9-]+)+$",
                ).matches(privacyContactEmail),
        ) {
            "BUDOWAPRO_PRIVACY_CONTACT_EMAIL must be a valid email address."
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(validateLegalReleaseConfig)
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
