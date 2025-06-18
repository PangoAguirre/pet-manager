package TestService;

import com.petmanager.supplier_service.model.Producto;
import com.petmanager.supplier_service.model.Proveedor;
import com.petmanager.supplier_service.repository.ProductoRepository;
import com.petmanager.supplier_service.repository.ProveedorRepository;
import com.petmanager.supplier_service.service.ProductoService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import java.util.List;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ProductoServiceTest {

    @InjectMocks
    private ProductoService productoService;

    @Mock
    private ProductoRepository productoRepository;

    @Mock
    private ProveedorRepository proveedorRepository;

    private Proveedor proveedorActivo;

    @BeforeEach
    void setup() {
        proveedorActivo = Proveedor.builder()
                .idProveedor(1L)
                .nombre("Proveedor Activo")
                .activo(true)
                .build();
    }

    @Test
    void agregarProducto_deberiaAgregarCorrectamente() {
        Producto producto = new Producto();
        producto.setCodigo("PRD-123");
        producto.setNombre("Producto 1");
        producto.setDescripcion("Descripción de prueba");
        producto.setPrecio(100.0);

        when(proveedorRepository.findById(1L)).thenReturn(Optional.of(proveedorActivo));
        when(productoRepository.existsByCodigo("PRD-123")).thenReturn(false);
        when(productoRepository.save(any(Producto.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Producto resultado = productoService.agregarProducto(1L, producto);

        assertNotNull(resultado);
        assertEquals("PRD-123", resultado.getCodigo());
        verify(productoRepository).save(any(Producto.class));
    }

    @Test
    void actualizarProducto_deberiaActualizarCorrectamente() {
        Producto existente = new Producto();
        existente.setIdProducto(1L);
        existente.setCodigo("OLD-CODE");
        existente.setNombre("Antiguo");
        existente.setPrecio(50.0);
        existente.setProveedor(proveedorActivo);

        Producto actualizado = new Producto();
        actualizado.setCodigo("NEW-CODE");
        actualizado.setNombre("Nuevo Nombre");
        actualizado.setPrecio(150.0);

        when(productoRepository.findById(1L)).thenReturn(Optional.of(existente));
        when(productoRepository.existsByCodigo("NEW-CODE")).thenReturn(false);
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));

        Producto resultado = productoService.actualizarProducto(1L, actualizado);

        assertEquals("NEW-CODE", resultado.getCodigo());
        assertEquals("Nuevo Nombre", resultado.getNombre());
        assertEquals(150.0, resultado.getPrecio());
    }

    @Test
    void eliminarProducto_deberiaEliminarCorrectamente() {
        Producto producto = new Producto();
        producto.setIdProducto(1L);
        producto.setProveedor(proveedorActivo);

        when(productoRepository.findById(1L)).thenReturn(Optional.of(producto));

        boolean eliminado = productoService.eliminarProducto(1L);

        assertTrue(eliminado);
        verify(productoRepository).deleteById(1L);
    }

    @Test
    void buscarPorCodigo_deberiaRetornarCoincidencias() {
        Producto p = new Producto();
        p.setCodigo("ABC-123");
        List<Producto> lista = List.of(p);

        when(productoRepository.findAll()).thenReturn(lista);

        List<Producto> resultados = productoService.buscarPorCodigo("ABC");

        assertFalse(resultados.isEmpty());
        assertEquals("ABC-123", resultados.get(0).getCodigo());
    }

}
