allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val subproject = project
    val newSubprojectBuildDir: Directory = newBuildDir.dir(subproject.name)
    subproject.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Forzado de SDK en todas las librerías
    subproject.afterEvaluate {
        if (subproject.hasProperty("android")) {
            val android = subproject.extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                compileSdkVersion(34)
                if (namespace == null) {
                    namespace = "dev.isar.${subproject.name.replace("-", "_")}"
                }
            }
        }
    }

    // Forzar resolución de dependencias a nivel global
    subproject.configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.12.0")
            force("androidx.core:core-ktx:1.12.0")
            force("androidx.annotation:annotation-experimental:1.3.0")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
