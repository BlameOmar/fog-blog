package dev.omarevans.blog.datastore

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "blog-database")
data class BlogDatabaseProperties(
    val host: String,
    val port: Int,
    val name: String,
    val user: String,
    val password: String,
    val enableSsl: Boolean,
)
