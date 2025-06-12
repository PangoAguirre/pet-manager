package com.petmanager.auth_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI authServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("🔐 PetManager Auth Service API")
                        .version("1.0")
                        .description("""
                            **Microservicio de Autenticación y Autorización**
                            
                            Funcionalidades principales:
                            - 👤 Registro y gestión de usuarios
                            - 🔑 Autenticación con JWT
                            - 👥 Gestión de roles (ADMIN, USER)
                            - 📧 Recuperación de contraseñas
                            - 🛡️ Seguridad con tokens
                            
                            **Endpoints disponibles:**
                            - REST API: `/api/users/*`, `/password/*`, `/auth/*`
                            - GraphQL: `/graphql` (documentado por separado)
                            - Testing: `/test-email/*`
                            """)
                        .contact(new Contact()
                                .name("PetManager Team")
                                .email("camiloloaiza0303@gmail.com")))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
                .components(new Components()
                        .addSecuritySchemes("bearerAuth",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("JWT Authorization header usando Bearer scheme. Ejemplo: 'Bearer {token}'")));
    }
}