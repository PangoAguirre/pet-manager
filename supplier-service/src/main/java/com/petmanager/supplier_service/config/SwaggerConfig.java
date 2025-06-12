package com.petmanager.supplier_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI supplierServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("🏪 PetManager Supplier Service API")
                        .version("1.0")
                        .description("""
                            **Microservicio de Gestión de Proveedores**
                            
                            Funcionalidades principales:
                            - 🏢 Gestión completa de proveedores (CRUD)
                            - 📦 Administración de productos por proveedor
                            - 💳 Condiciones de pago y crédito
                            - 📊 Consultas y reportes
                            - 🔄 Integración con notification-service
                            
                            **Endpoints disponibles:**
                            - REST API: `/api/proveedores/*`, `/api/condiciones-pago/*`
                            - GraphQL: `/graphql` (documentado por separado)
                            - Health: `/actuator/health`
                            
                            **Nota importante:**
                            Este servicio se comunica con notification-service para 
                            alertas de vencimiento de condiciones de pago.
                            """)
                        .contact(new Contact()
                                .name("PetManager Team")
                                .email("camiloloaiza0303@gmail.com")));
    }
}