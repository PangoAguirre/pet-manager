package com.petmanager.notification_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI notificationServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("📧 PetManager Notification Service API")
                        .version("1.0")
                        .description("""
                            **Microservicio de Notificaciones Automáticas**
                            
                            Funcionalidades principales:
                            - 📅 Procesamiento automático de vencimientos
                            - 📧 Envío de emails via Brevo SMTP
                            - ⏰ Scheduler con tareas programadas
                            - 🔄 Integración con supplier-service
                            - 📊 Dashboard de notificaciones
                            
                            **Endpoints disponibles:**
                            - GraphQL: `/graphql` (documentado por separado)
                            - Health: `/actuator/health`
                            - Testing: endpoints de prueba para emails
                            
                            **Scheduler automático:**
                            - Ejecución diaria a las 8:00 AM
                            - Verificación cada 2 horas (horario laboral)
                            - Limpieza semanal los domingos
                            
                            **Comunicación externa:**
                            - Consume APIs de supplier-service
                            - Envía emails via Brevo SMTP
                            """)
                        .contact(new Contact()
                                .name("PetManager Team")
                                .email("camiloloaiza0303@gmail.com")));
    }
}