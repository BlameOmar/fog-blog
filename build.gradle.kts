import com.google.cloud.tools.jib.gradle.BuildDockerTask
import com.google.cloud.tools.jib.gradle.BuildImageTask
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.google.cloud.tools.jib")
    id("org.springframework.boot")
    id("io.spring.dependency-management")
    `jvm-test-suite`
    kotlin("jvm")
    kotlin("plugin.spring")
}

group = "dev.omarevans"
version = "0.0.1-SNAPSHOT"

val jvmVersion: String by project

java {
    sourceCompatibility = JavaVersion.toVersion(jvmVersion)
}

repositories {
    mavenCentral()
}

jib {
    from {
        val jvmVersion: String by project
        val baseImage = "eclipse-temurin:${jvmVersion}-jdk"
        image = baseImage
    }

    to {
        val containerImageRepo: String by project
        image = "${containerImageRepo}/${project.name}"
    }
}

tasks.withType<BuildImageTask>().configureEach {
    jib {
        from {
            platforms {
                platform {
                    os = "linux"
                    architecture = "amd64"
                }
                platform {
                    os = "linux"
                    architecture = "arm64"
                }
            }
        }
    }
}

tasks.withType<BuildDockerTask>().configureEach {
    jib {
        from {
            platforms {
                platform {
                    architecture = when (System.getProperty("os.arch")) {
                        "aarch64" -> "arm64"
                        else -> "amd64"
                    }
                    os = "linux"
                }
            }
        }
    }
}

dependencies {
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    implementation("org.liquibase:liquibase-core")
    implementation("org.springframework:spring-jdbc")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-data-r2dbc")
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.postgresql:postgresql")
    implementation("org.postgresql:r2dbc-postgresql")
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs += "-Xjsr305=strict"
        jvmTarget = jvmVersion
    }
}

testing {
    suites {
        val test by getting(JvmTestSuite::class) {
            useJUnitJupiter()

            dependencies {
                implementation("io.projectreactor:reactor-test")
                implementation("org.junit.jupiter:junit-jupiter")
                implementation("org.springframework.boot:spring-boot-starter-test")
                runtimeOnly("org.junit.platform:junit-platform-launcher")
            }
        }
    }
}
