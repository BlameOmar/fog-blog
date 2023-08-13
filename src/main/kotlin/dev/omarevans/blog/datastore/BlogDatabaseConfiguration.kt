package dev.omarevans.blog.datastore

import io.r2dbc.postgresql.PostgresqlConnectionFactory
import io.r2dbc.postgresql.PostgresqlConnectionFactoryProvider
import io.r2dbc.spi.ConnectionFactoryOptions
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties(BlogDatabaseProperties::class)
class BlogDatabaseConfiguration(
    private val properties: BlogDatabaseProperties
) {
    @Bean
    fun connectionFactory(): PostgresqlConnectionFactory =
        PostgresqlConnectionFactoryProvider().create(
            ConnectionFactoryOptions.builder()
                .option(ConnectionFactoryOptions.HOST, properties.host)
                .option(ConnectionFactoryOptions.PORT, properties.port)
                .option(ConnectionFactoryOptions.DATABASE, properties.name)
                .option(ConnectionFactoryOptions.USER, properties.user)
                .option(ConnectionFactoryOptions.PASSWORD, properties.password)
                .option(ConnectionFactoryOptions.SSL, properties.enableSsl)
                .build()
        )
}
