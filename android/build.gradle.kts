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
    
    // Parche para librerías sin namespace (como isar_flutter_libs)
    // Usamos pluginManager.withPlugin para actuar inmediatamente cuando se aplica el plugin
    subproject.pluginManager.withPlugin("com.android.library") {
        subproject.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
            if (namespace == null) {
                namespace = "dev.isar.${subproject.name.replace("-", "_")}"
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
