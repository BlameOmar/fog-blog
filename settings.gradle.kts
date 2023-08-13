rootProject.name = "fog-blog"

pluginManagement {
    val kotlinVersion: String by settings

    val jibPluginVersion: String by settings
    val springFrameworkBootPluginVersion: String by settings
    val springDependencyManagementPluginVersion: String by settings

    repositories {
        gradlePluginPortal()
    }

    plugins {
        id("com.google.cloud.tools.jib") version jibPluginVersion
        id("org.springframework.boot") version springFrameworkBootPluginVersion
        id("io.spring.dependency-management") version springDependencyManagementPluginVersion
        kotlin("jvm") version kotlinVersion
        kotlin("plugin.spring") version kotlinVersion
    }
}
