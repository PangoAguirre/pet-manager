package TestService;

import com.petmanager.supplier_service.dto.CondicionPagoInput;
import com.petmanager.supplier_service.dto.ProductoInput;
import com.petmanager.supplier_service.dto.ProveedorInput;
import com.petmanager.supplier_service.exception.InvalidDataException;
import com.petmanager.supplier_service.model.Proveedor;
import com.petmanager.supplier_service.repository.CondicionPagoRepository;
import com.petmanager.supplier_service.repository.ProductoRepository;
import com.petmanager.supplier_service.repository.ProveedorRepository;
import com.petmanager.supplier_service.service.ProveedorService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;


public class ProveedorServiceTest {

    @InjectMocks
    private ProveedorService proveedorService;

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
    void crearProveedor_deberiaCrearProveedorConProductosYCondiciones() {
        // Arrange
        ProveedorInput input = new ProveedorInput();
        input.setNombre("Proveedor Uno");
        input.setNit("12345678-9");
        input.setDireccion("Calle Falsa 123");
        input.setTelefono("5551234");
        input.setEmail("proveedor@correo.com");
        input.setIdUsuarioCreador(1L);

        ProductoInput producto = new ProductoInput();
        producto.setCodigo("P001");
        producto.setNombre("Producto Test");
        producto.setPrecio(1000.0);
        input.setProductos(List.of(producto));

        CondicionPagoInput cond = new CondicionPagoInput();
        cond.setDiasCredito(30);
        cond.setFechaInicio(LocalDate.now());
        cond.setFechaFin(LocalDate.now().plusDays(30));
        cond.setIdUsuario(1L);
        input.setCondicionesPago(List.of(cond));

        when(proveedorRepository.findAll()).thenReturn(Collections.emptyList());
        when(productoRepository.existsByCodigo("P001")).thenReturn(false);

        Proveedor mockProveedor = Proveedor.builder()
                .idProveedor(10L)
                .nombre("Proveedor Uno")
                .build();
        when(proveedorRepository.save(any())).thenReturn(mockProveedor);

        // Act
        Proveedor resultado = proveedorService.crearProveedor(input);

        // Assert
        assertNotNull(resultado);
        assertEquals("Proveedor Uno", resultado.getNombre());

        verify(proveedorRepository).save(any());
        verify(productoRepository).saveAll(any());
        verify(condicionPagoRepository).saveAll(any());
    }

    @Test
    void crearProveedor_conInputNull_lanzaExcepcion() {
        InvalidDataException ex = assertThrows(InvalidDataException.class, () -> {
            proveedorService.crearProveedor(null);
        });
        assertEquals("Los datos del proveedor no pueden estar vacíos", ex.getMessage());
    }

    @Test
    void crearProveedor_conEmailInvalido_lanzaExcepcion() {
        ProveedorInput input = new ProveedorInput();
        input.setNombre("Proveedor");
        input.setNit("12345678-9");
        input.setDireccion("Dirección");
        input.setTelefono("5551234");
        input.setEmail("email_invalido");
        input.setIdUsuarioCreador(1L);

        InvalidDataException ex = assertThrows(InvalidDataException.class, () -> {
            proveedorService.crearProveedor(input);
        });
        assertEquals("El formato del email no es válido", ex.getMessage());
    }


}
