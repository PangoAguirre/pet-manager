package com.petmanager.api_gateway;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@Slf4j
public class ApiGatewayApplication {

	public static void main(String[] args) {
		log.info("🚀 Iniciando PetManager API Gateway...");
		SpringApplication.run(ApiGatewayApplication.class, args);
		log.info("✅ API Gateway iniciado en puerto 8080");
	}
}