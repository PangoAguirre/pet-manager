package com.petmanager.api_gateway;

import com.petmanager.api_gateway.config.CorsConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.cors.reactive.CorsWebFilter;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
class CorsConfigTest {

	@Test
	void corsWebFilter_shouldBeCreatedSuccessfully() {
		CorsConfig config = new CorsConfig();
		CorsWebFilter filter = config.corsWebFilter();
		assertNotNull(filter, "El CorsWebFilter no debería ser null");
	}
}

@SpringBootTest
class CorsConfigIntegrationTest {

	@Autowired
	private CorsWebFilter corsWebFilter;

	@Test
	void contextLoadsAndCorsWebFilterIsPresent() {
		assertNotNull(corsWebFilter, "CorsWebFilter debería estar registrado en el contexto");
	}
}
