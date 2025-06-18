package TestService;

import com.petmanager.supplier_service.dto.CondicionPagoInput;
import com.petmanager.supplier_service.exception.BusinessValidationException;
import com.petmanager.supplier_service.exception.InvalidDataException;
import com.petmanager.supplier_service.model.CondicionPago;
import com.petmanager.supplier_service.repository.CondicionPagoRepository;
import com.petmanager.supplier_service.repository.ProductoRepository;
import com.petmanager.supplier_service.repository.ProveedorRepository;
import com.petmanager.supplier_service.service.CondicionPagoService;
import com.petmanager.supplier_service.service.ProveedorService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.when;

public class CondicionServiceTest {

    @InjectMocks
    private ProveedorService proveedorService;

    @InjectMocks
    private CondicionPagoService condicionPagoService;

    @Mock
    private ProveedorRepository proveedorRepository;

    @Mock
    private ProductoRepository productoRepository;

    @Mock
    private CondicionPagoRepository condicionPagoRepository;


    @BeforeEach
    void setup() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void crearCondicionPago_deberiaCrearCorrectamente() {
        CondicionPagoInput input = new CondicionPagoInput();
        input.setDiasCredito(30);
        input.setFechaInicio(LocalDate.now());
        input.setFechaFin(LocalDate.now().plusDays(10));
        input.setNota("Pago mensual");
        input.setIdUsuario(1L);

        CondicionPago mockSaved = CondicionPago.builder()
                .idCondicionPago(1L)
                .diasCredito(30)
                .fechaInicio(input.getFechaInicio())
                .fechaFin(input.getFechaFin())
                .nota(input.getNota())
                .idUsuario(1L)
                .build();

        when(condicionPagoRepository.save(any())).thenReturn(mockSaved);

        CondicionPago result = condicionPagoService.crearCondicionPago(input);

        assertNotNull(result);
        assertEquals(30, result.getDiasCredito());
        assertEquals("Pago mensual", result.getNota());
    }

    @Test
    void crearCondicionPago_diasCreditoNegativo_deberiaLanzarExcepcion() {
        CondicionPagoInput input = new CondicionPagoInput();
        input.setDiasCredito(-5);
        input.setFechaInicio(LocalDate.now());
        input.setFechaFin(LocalDate.now().plusDays(5));
        input.setIdUsuario(1L);

        assertThrows(InvalidDataException.class, () -> condicionPagoService.crearCondicionPago(input));
    }

    @Test
    void crearCondicionPago_fechaInicioPosteriorAFechaFin_deberiaLanzarExcepcion() {
        CondicionPagoInput input = new CondicionPagoInput();
        input.setDiasCredito(30);
        input.setFechaInicio(LocalDate.now().plusDays(10));
        input.setFechaFin(LocalDate.now());
        input.setIdUsuario(1L);

        assertThrows(BusinessValidationException.class, () -> condicionPagoService.crearCondicionPago(input));
    }

    @Test
    void crearCondicionPago_idUsuarioNulo_deberiaLanzarExcepcion() {
        CondicionPagoInput input = new CondicionPagoInput();
        input.setDiasCredito(30);
        input.setFechaInicio(LocalDate.now());
        input.setFechaFin(LocalDate.now().plusDays(5));
        input.setIdUsuario(null);

        assertThrows(InvalidDataException.class, () -> condicionPagoService.crearCondicionPago(input));
    }

}
