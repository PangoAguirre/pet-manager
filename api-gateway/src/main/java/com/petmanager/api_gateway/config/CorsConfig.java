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

        log.info("🌐 Configurando CORS para API Gateway (TESTING MODE)...");

        // ========================================
        // PERMITIR TODOS LOS ORÍGENES (para testing)
        // ========================================
        corsConfiguration.addAllowedOriginPattern("*");

        // ========================================
        // MÉTODOS HTTP PERMITIDOS
        // ========================================
        corsConfiguration.setAllowedMethods(Arrays.asList(
                "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));

        // ========================================
        // HEADERS PERMITIDOS
        // ========================================
        corsConfiguration.addAllowedHeader("*");

        // ========================================
        // CONFIGURACIONES ADICIONALES
        // ========================================
        corsConfiguration.setAllowCredentials(false); // Cambié a false para evitar conflictos con *
        corsConfiguration.setMaxAge(3600L);

        // ========================================
        // APLICAR CONFIGURACIÓN
        // ========================================
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);

        log.info("✅ CORS configurado en TESTING MODE:");
        log.info("   🌍 Orígenes: TODOS permitidos (*)");
        log.info("   🔧 Métodos: GET, POST, PUT, DELETE, OPTIONS, PATCH");
        log.info("   🔑 Credenciales: Deshabilitadas (testing)");
        log.info("   ⏰ Max Age: 3600 segundos");

        return new CorsWebFilter(source);
    }
}