rootProject.name = "fog-blog"

pluginManagement {
    val kotlinVersion: String by settings

    val springFrameworkBootPluginVersion: String by settings
    val springDependencyManagementPluginVersion: String by settings

    repositories {
        gradlePluginPortal()
    }

    plugins {
        id("org.springframework.boot") version springFrameworkBootPluginVersion
        id("io.spring.dependency-management") version springDependencyManagementPluginVersion
        kotlin("jvm") version kotlinVersion
        kotlin("plugin.spring") version kotlinVersion
    }
}