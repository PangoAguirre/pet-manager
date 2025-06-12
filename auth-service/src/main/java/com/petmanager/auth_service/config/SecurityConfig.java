package com.petmanager.auth_service.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // ========================================
                        // SWAGGER ENDPOINTS - PÚBLICO
                        // ========================================
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/v3/api-docs/**",
                                "/v3/api-docs.yaml",
                                "/swagger-resources/**",
                                "/webjars/**"
                        ).permitAll()

                        // ========================================
                        // GRAPHQL ENDPOINTS - PÚBLICO
                        // ========================================
                        .requestMatchers("/graphql", "/graphql/**", "/graphiql").permitAll()

                        // ========================================
                        // AUTH ENDPOINTS - PÚBLICO
                        // ========================================
                        .requestMatchers("/api/users/register", "/api/users/email").permitAll()

                        // ========================================
                        // PASSWORD RESET ENDPOINTS
                        // ========================================
                        .requestMatchers(
                                "/password/**",
                                "/password/request-reset",
                                "/password/reset",
                                "/password/validate"
                        ).permitAll()

                        // ========================================
                        // EMAIL TEST ENDPOINTS - PÚBLICO
                        // ========================================
                        .requestMatchers("/test-email/**").permitAll()

                        // ========================================
                        // LOGOUT ENDPOINT - PÚBLICO
                        // ========================================
                        .requestMatchers("/auth/logout").permitAll()

                        // ========================================
                        // ACTUATOR ENDPOINTS - PÚBLICO (para health checks)
                        // ========================================
                        .requestMatchers("/actuator/health", "/actuator/info").permitAll()

                        // ========================================
                        // ENDPOINTS PROTEGIDOS
                        // ========================================
                        .requestMatchers("/api/users/hello").authenticated() // Requiere JWT
                        .requestMatchers("/api/users/me").authenticated()    // Requiere JWT

                        // ========================================
                        // CUALQUIER OTRA RUTA - PÚBLICO (EXISTENTE)
                        // ========================================
                        .anyRequest().permitAll()
                )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }
}