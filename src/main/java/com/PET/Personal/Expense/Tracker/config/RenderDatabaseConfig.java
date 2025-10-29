package com.PET.Personal.Expense.Tracker.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;
import java.net.URI;

@Configuration
@Profile("render")
public class RenderDatabaseConfig {

    @Bean
    @ConfigurationProperties("spring.datasource.hikari")
    public DataSource dataSource() {
        String databaseUrl = System.getenv("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Parse Render's DATABASE_URL format: postgresql://username:password@hostname:port/database
            try {
                URI uri = new URI(databaseUrl);
                
                String jdbcUrl = "jdbc:postgresql://" + uri.getHost() + ":" + uri.getPort() + uri.getPath() + "?sslmode=require";
                String username = uri.getUserInfo().split(":")[0];
                String password = uri.getUserInfo().split(":")[1];
                
                HikariDataSource dataSource = new HikariDataSource();
                dataSource.setJdbcUrl(jdbcUrl);
                dataSource.setUsername(username);
                dataSource.setPassword(password);
                dataSource.setDriverClassName("org.postgresql.Driver");
                
                // Connection pool settings optimized for Render free tier
                dataSource.setMaximumPoolSize(3);
                dataSource.setMinimumIdle(1);
                dataSource.setConnectionTimeout(20000);
                dataSource.setIdleTimeout(300000);
                dataSource.setMaxLifetime(1200000);
                dataSource.setLeakDetectionThreshold(60000);
                
                return dataSource;
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse DATABASE_URL: " + e.getMessage(), e);
            }
        }
        
        // Fallback to default configuration
        return new HikariDataSource();
    }
}