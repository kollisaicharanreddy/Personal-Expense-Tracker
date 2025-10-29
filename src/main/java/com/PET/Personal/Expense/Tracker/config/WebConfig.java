package com.PET.Personal.Expense.Tracker.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(@NonNull CorsRegistry registry) {
                registry.addMapping("/**")      // Apply to all endpoints
                        .allowedOrigins(
                            "http://localhost:3000",  // Local development
                            "https://*.vercel.app"    // Vercel deployment
                        )
                        .allowedMethods("GET","POST","PUT","DELETE")
                        .allowedHeaders("*");
            }
        };
    }
}