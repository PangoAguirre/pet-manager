package com.petmanager.auth_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuración de Swagger para Auth Service
 * Incluye configuración JWT para endpoints protegidos
 */
@Configuration
public class SwaggerConfig {

    @Value("${server.port:8081}")
    private String serverPort;

    @Bean
    public OpenAPI authServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("🔐 PetManager Auth Service API")
                        .description("""
                                **Microservicio de Autenticación y Autorización para PetManager**
                                
                                Este servicio maneja:
                                - ✅ Registro y autenticación de usuarios
                                - 🔑 Generación y validación de tokens JWT
                                - 📧 Recuperación de contraseñas con email
                                - 👥 Gestión de roles y permisos
                                - 🔒 Logout y revocación de tokens
                                
                                **Endpoints principales:**
                                - `/graphql` - API GraphQL para operaciones complejas
                                - `/api/users/*` - API REST para operaciones básicas
                                - `/password/*` - API REST para recuperación de contraseñas
                                
                                **Autenticación:**
                                Para endpoints protegidos, incluir header: `Authorization: Bearer <token>`
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("PetManager Team")
                                .email("soporte@petmanager.com")
                                .url("https://github.com/petmanager"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))

                // Configuración de servidores
                .servers(List.of(
                        new Server()
                                .url("http://localhost:" + serverPort)
                                .description("🔧 Desarrollo Local"),
                        new Server()
                                .url("https://petmanager-auth-service.onrender.com")
                                .description("🚀 Producción (Render)"),
                        new Server()
                                .url("https://petmanager-api-gateway.onrender.com/auth")
                                .description("🌐 A través del API Gateway")
                ))

                // Configuración de seguridad JWT
                .addSecurityItem(new SecurityRequirement().addList("BearerAuth"))
                .components(new io.swagger.v3.oas.models.Components()
                        .addSecuritySchemes("BearerAuth",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Ingresa el token JWT obtenido del login")
                        )
                );
    }
}