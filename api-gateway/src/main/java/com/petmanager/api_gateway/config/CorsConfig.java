package com.petmanager.api_gateway.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@Slf4j
public class CorsConfig {

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();

        log.info("🌐 Configurando CORS para API Gateway (PRODUCTION MODE)...");

        // ========================================
        // PERMITIR DOMINIOS ESPECÍFICOS + DESARROLLO
        // ========================================
        corsConfiguration.setAllowedOriginPatterns(Arrays.asList(
                "http://localhost:*",
                "https://*.vercel.app",
                "https://*.netlify.app",
                "https://*.render.com",
                "https://petstore-feat2-front.vercel.app",
                "https://www.google.com",
                "https://google.com",
                "file://*",
                "null"
        ));

        // ========================================
        // MÉTODOS HTTP PERMITIDOS
        // ========================================
        corsConfiguration.setAllowedMethods(Arrays.asList(
                "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"
        ));

        // ========================================
        // HEADERS PERMITIDOS
        // ========================================
        corsConfiguration.setAllowedHeaders(Arrays.asList("*"));

        // ========================================
        // HEADERS EXPUESTOS
        // ========================================
        corsConfiguration.setExposedHeaders(Arrays.asList(
                "Content-Type",
                "Authorization",
                "Access-Control-Allow-Origin",
                "Access-Control-Allow-Credentials"
        ));

        // ========================================
        // CONFIGURACIONES ADICIONALES
        // ========================================
        corsConfiguration.setAllowCredentials(false);  // ← CAMBIADO: Más permisivo
        corsConfiguration.setMaxAge(3600L);

        // ========================================
        // APLICAR CONFIGURACIÓN
        // ========================================
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);

        log.info("✅ CORS configurado en PRODUCTION MODE:");
        log.info("   🌍 Orígenes: Localhost + Vercel + Netlify + Render + Google");
        log.info("   🔧 Métodos: GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD");
        log.info("   🔑 Credenciales: Deshabilitadas");
        log.info("   ⏰ Max Age: 3600 segundos");

        return new CorsWebFilter(source);
    }
}