import java.util.Locale

pluginManagement {
    repositories {
        gradlePluginPortal()
        maven("https://repo.papermc.io/repository/maven-public/")
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.8.0"
}

if (!file(".git").exists()) {
    val errorText = """
        
        =====================[ ERROR ]=====================
         The PebbleMC project directory is not a properly cloned Git repository.
         
         In order to build PebbleMC from source you must clone
         the PebbleMC repository using Git, not download a code
         zip from GitHub.
         
         Built PebbleMC jars are available for download at
         https://example.org/downloads
         
         See https://github.com/xhayper/PebbleMC/blob/HEAD/CONTRIBUTING.md
         for further information on building and modifying PebbleMC.
        ===================================================
    """.trimIndent()
    error(errorText)
}

rootProject.name = "pebblemc"
for (name in listOf("PebbleMC-API", "PebbleMC-Server", "paper-api-generator")) {
    val projName = name.lowercase(Locale.ENGLISH)
    include(projName)
    findProject(":$projName")!!.projectDir = file(name)
}