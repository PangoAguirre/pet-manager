# ============================================
# SCRIPT DE MIGRACION A AIVEN POSTGRESQL (PowerShell)
# ============================================

Write-Host "Iniciando migracion de PetManager a Aiven PostgreSQL..." -ForegroundColor Blue

# Variables de Aiven
$AIVEN_HOST = "pet-manager-filmverse-db.c.aivencloud.com"
$AIVEN_PORT = "10898"
$AIVEN_DB = "defaultdb"
$AIVEN_USER = "avnadmin"
$AIVEN_PASSWORD = "AVNS_SlYBLMRNIYyXuTt1oju"
$AIVEN_SSL = "require"

Write-Host "Configuracion de conexion:" -ForegroundColor Blue
Write-Host "  Host: $AIVEN_HOST" -ForegroundColor Yellow
Write-Host "  Puerto: $AIVEN_PORT" -ForegroundColor Yellow
Write-Host "  Base de datos: $AIVEN_DB" -ForegroundColor Yellow
Write-Host "  Usuario: $AIVEN_USER" -ForegroundColor Yellow

# Funcion para verificar si psql esta disponible
function Test-PostgreSQLClient {
    try {
        $null = Get-Command psql -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Verificar cliente PostgreSQL
if (-not (Test-PostgreSQLClient)) {
    Write-Host "Error: psql no esta instalado o no esta en el PATH" -ForegroundColor Red
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  1. Instalar PostgreSQL desde: https://www.postgresql.org/download/windows/" -ForegroundColor White
    Write-Host "  2. O usar la migracion manual que voy a crear" -ForegroundColor White

    # Crear archivo SQL para migracion manual
    Write-Host "Creando archivo SQL para migracion manual..." -ForegroundColor Blue

    $sqlContent = @"
-- ============================================
-- ESTRUCTURA DE BASE DE DATOS PETMANAGER
-- ============================================

-- Crear extension si no existe
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Configuracion de zona horaria
SET timezone = 'UTC';

-- Crear tabla rol
CREATE TABLE IF NOT EXISTS rol (
    id_rol BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Crear tabla usuario
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE
);

-- Crear tabla rolxusuario
CREATE TABLE IF NOT EXISTS rolxusuario (
    id_rolxusuario SERIAL PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario(id_usuario),
    id_rol BIGINT NOT NULL REFERENCES rol(id_rol),
    UNIQUE(id_usuario, id_rol)
);

-- Crear tabla proveedor
CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nit VARCHAR(30) NOT NULL UNIQUE,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    id_usuario_creador BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

-- Crear tabla producto
CREATE TABLE IF NOT EXISTS producto (
    id_producto BIGSERIAL PRIMARY KEY,
    id_proveedor BIGINT NOT NULL REFERENCES proveedor(id_proveedor),
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio DOUBLE PRECISION NOT NULL CHECK (precio > 0)
);

-- Crear tabla condicion_pago
CREATE TABLE IF NOT EXISTS condicion_pago (
    id_condicion_pago BIGSERIAL PRIMARY KEY,
    id_proveedor BIGINT NOT NULL REFERENCES proveedor(id_proveedor),
    dias_credito INTEGER NOT NULL CHECK (dias_credito >= 0),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    nota VARCHAR(255),
    id_usuario BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

-- Crear tabla plazo_entrega
CREATE TABLE IF NOT EXISTS plazo_entrega (
    id_plazo_entrega SERIAL PRIMARY KEY,
    id_proveedor INTEGER NOT NULL REFERENCES proveedor(id_proveedor),
    dias_entrega INTEGER NOT NULL CHECK (dias_entrega > 0),
    region VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    condiciones TEXT
);

-- Crear tabla orden_compra
CREATE TABLE IF NOT EXISTS orden_compra (
    id_orden_compra SERIAL PRIMARY KEY,
    id_proveedor INTEGER NOT NULL REFERENCES proveedor(id_proveedor),
    id_usuario INTEGER NOT NULL REFERENCES usuario(id_usuario),
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega_esperada DATE NOT NULL,
    valor_total NUMERIC(18,2) NOT NULL CHECK (valor_total >= 0)
);

-- Crear tabla orden_compra_detalle
CREATE TABLE IF NOT EXISTS orden_compra_detalle (
    id_orden_compra_detalle SERIAL PRIMARY KEY,
    id_orden_compra INTEGER NOT NULL REFERENCES orden_compra(id_orden_compra),
    id_producto INTEGER NOT NULL REFERENCES producto(id_producto),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(18,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(18,2) GENERATED ALWAYS AS (cantidad::numeric * precio_unitario) STORED
);

-- Crear tabla notificacion_pago
CREATE TABLE IF NOT EXISTS notificacion_pago (
    id_notificacion_pago SERIAL PRIMARY KEY,
    id_proveedor INTEGER NOT NULL REFERENCES proveedor(id_proveedor),
    id_condicion_pago INTEGER NOT NULL REFERENCES condicion_pago(id_condicion_pago),
    fecha_vencimiento DATE NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notificado BOOLEAN DEFAULT FALSE,
    estado VARCHAR(20) DEFAULT 'Pendiente'
);

-- Crear tabla historial_negociacion
CREATE TABLE IF NOT EXISTS historial_negociacion (
    id_historial_negociacion SERIAL PRIMARY KEY,
    id_proveedor INTEGER NOT NULL REFERENCES proveedor(id_proveedor),
    id_usuario INTEGER NOT NULL REFERENCES usuario(id_usuario),
    fecha_negociacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalle TEXT NOT NULL
);

-- Crear tabla password_reset_tokens
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiration_date TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    user_id BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

-- Crear tabla revoked_tokens
CREATE TABLE IF NOT EXISTS revoked_tokens (
    id SERIAL PRIMARY KEY,
    token TEXT NOT NULL,
    revoked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DATOS INICIALES
-- ============================================

-- Insertar roles
INSERT INTO rol (nombre, descripcion) VALUES
    ('ADMIN', 'Administrador del sistema'),
    ('USER', 'Usuario del sistema')
ON CONFLICT (nombre) DO NOTHING;

-- Insertar usuario administrador por defecto (password: admin123)
INSERT INTO usuario (nombre, password, email) VALUES
    ('Admin Aiven', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@petmanager.com')
ON CONFLICT (email) DO NOTHING;

-- Asignar rol ADMIN al usuario admin
INSERT INTO rolxusuario (id_usuario, id_rol)
SELECT u.id_usuario, r.id_rol
FROM usuario u, rol r
WHERE u.email = 'admin@petmanager.com' AND r.nombre = 'ADMIN'
ON CONFLICT (id_usuario, id_rol) DO NOTHING;

-- Insertar proveedor de prueba
INSERT INTO proveedor (nombre, nit, direccion, telefono, email, id_usuario_creador)
SELECT 'Proveedor Aiven Test', '900123456', 'Calle Cloud 123', '3001234567', 'proveedor@aiven.com', u.id_usuario
FROM usuario u WHERE u.email = 'admin@petmanager.com'
ON CONFLICT (email) DO NOTHING;

-- Insertar condicion de pago de prueba
INSERT INTO condicion_pago (id_proveedor, dias_credito, fecha_inicio, fecha_fin, nota, id_usuario)
SELECT p.id_proveedor, 30, '2025-06-07', '2025-12-31', 'Condicion de prueba Aiven', u.id_usuario
FROM proveedor p, usuario u
WHERE p.email = 'proveedor@aiven.com' AND u.email = 'admin@petmanager.com';

"@

    $sqlContent | Out-File -FilePath "aiven-migration.sql" -Encoding UTF8

    Write-Host "Archivo 'aiven-migration.sql' creado exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "INSTRUCCIONES MANUALES:" -ForegroundColor Yellow
    Write-Host "1. Ve a https://console.aiven.io" -ForegroundColor White
    Write-Host "2. Entra a tu servicio PostgreSQL 'pet-manager'" -ForegroundColor White
    Write-Host "3. Busca una opcion para ejecutar SQL o conectar con un cliente" -ForegroundColor White
    Write-Host "4. Ejecuta el contenido del archivo 'aiven-migration.sql'" -ForegroundColor White
    Write-Host ""
    Write-Host "O instala PostgreSQL client desde:" -ForegroundColor Yellow
    Write-Host "   https://www.postgresql.org/download/windows/" -ForegroundColor White

    # Generar variables de entorno de todas formas
    Write-Host "Generando variables de entorno para Render..." -ForegroundColor Blue

    $envContent = @"
# AIVEN POSTGRESQL CONFIGURATION
DB_URL=postgresql://$AIVEN_USER`:$AIVEN_PASSWORD@$AIVEN_HOST`:$AIVEN_PORT/$AIVEN_DB`?sslmode=$AIVEN_SSL
DB_USERNAME=$AIVEN_USER
DB_PASSWORD=$AIVEN_PASSWORD
DB_HOST=$AIVEN_HOST
DB_PORT=$AIVEN_PORT
DB_NAME=$AIVEN_DB
DB_SSL_MODE=$AIVEN_SSL

# EMAIL CONFIGURATION (actualizar con tus credenciales Brevo)
BREVO_USERNAME=your-brevo-username
BREVO_SMTP_PASSWORD=your-brevo-password
BREVO_API_KEY=your-brevo-api-key
SENDER_EMAIL=camiloloaiza0303@gmail.com
SENDER_NAME=PetManager

# SERVICE URLS (actualizar despues del deploy en Render)
AUTH_SERVICE_URL=https://petmanager-auth-service.onrender.com
SUPPLIER_SERVICE_URL=https://petmanager-supplier-service.onrender.com
NOTIFICATION_SERVICE_URL=https://petmanager-notification-service.onrender.com
API_GATEWAY_URL=https://petmanager-api-gateway.onrender.com
"@

    $envContent | Out-File -FilePath ".env.aiven" -Encoding UTF8
    Write-Host "Variables de entorno creadas en .env.aiven" -ForegroundColor Green

    return
}

# Si llegamos aqui, psql esta disponible
Write-Host "Cliente PostgreSQL encontrado" -ForegroundColor Green

# Verificar conexion
Write-Host "Verificando conexion a Aiven..." -ForegroundColor Blue

$env:PGPASSWORD = $AIVEN_PASSWORD
$testQuery = "SELECT version()"

try {
    $result = & psql -h $AIVEN_HOST -p $AIVEN_PORT -U $AIVEN_USER -d $AIVEN_DB -c $testQuery 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Conexion exitosa a Aiven PostgreSQL" -ForegroundColor Green
    } else {
        Write-Host "Error de conexion a Aiven" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        return
    }
} catch {
    Write-Host "Error ejecutando psql: $_" -ForegroundColor Red
    return
}

# Crear estructura de base de datos usando el archivo SQL generado
Write-Host "Creando estructura de base de datos..." -ForegroundColor Blue

# Usar el contenido SQL incluido
$sqlStructure = @"
-- ESTRUCTURA DE BASE DE DATOS PETMANAGER
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SET timezone = 'UTC';

CREATE TABLE IF NOT EXISTS rol (
    id_rol BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS rolxusuario (
    id_rolxusuario SERIAL PRIMARY KEY,
    id_usuario BIGINT NOT NULL REFERENCES usuario(id_usuario),
    id_rol BIGINT NOT NULL REFERENCES rol(id_rol),
    UNIQUE(id_usuario, id_rol)
);

CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nit VARCHAR(30) NOT NULL UNIQUE,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    id_usuario_creador BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS producto (
    id_producto BIGSERIAL PRIMARY KEY,
    id_proveedor BIGINT NOT NULL REFERENCES proveedor(id_proveedor),
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio DOUBLE PRECISION NOT NULL CHECK (precio > 0)
);

CREATE TABLE IF NOT EXISTS condicion_pago (
    id_condicion_pago BIGSERIAL PRIMARY KEY,
    id_proveedor BIGINT NOT NULL REFERENCES proveedor(id_proveedor),
    dias_credito INTEGER NOT NULL CHECK (dias_credito >= 0),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    nota VARCHAR(255),
    id_usuario BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS notificacion_pago (
    id_notificacion_pago SERIAL PRIMARY KEY,
    id_proveedor INTEGER NOT NULL REFERENCES proveedor(id_proveedor),
    id_condicion_pago INTEGER NOT NULL REFERENCES condicion_pago(id_condicion_pago),
    fecha_vencimiento DATE NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notificado BOOLEAN DEFAULT FALSE,
    estado VARCHAR(20) DEFAULT 'Pendiente'
);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiration_date TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    user_id BIGINT NOT NULL REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS revoked_tokens (
    id SERIAL PRIMARY KEY,
    token TEXT NOT NULL,
    revoked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DATOS INICIALES
INSERT INTO rol (nombre, descripcion) VALUES
    ('ADMIN', 'Administrador del sistema'),
    ('USER', 'Usuario del sistema')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO usuario (nombre, password, email) VALUES
    ('Admin Aiven', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@petmanager.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO rolxusuario (id_usuario, id_rol)
SELECT u.id_usuario, r.id_rol
FROM usuario u, rol r
WHERE u.email = 'admin@petmanager.com' AND r.nombre = 'ADMIN'
ON CONFLICT (id_usuario, id_rol) DO NOTHING;
"@

# Ejecutar SQL
try {
    $result = & psql -h $AIVEN_HOST -p $AIVEN_PORT -U $AIVEN_USER -d $AIVEN_DB -c $sqlStructure 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Estructura de BD creada exitosamente" -ForegroundColor Green
    } else {
        Write-Host "Error creando estructura de BD" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "Error ejecutando SQL: $_" -ForegroundColor Red
}

# Verificar datos
Write-Host "Verificando datos en Aiven..." -ForegroundColor Blue

$verifyQuery = "SELECT 'Usuarios' as tabla, COUNT(*) as registros FROM usuario UNION ALL SELECT 'Roles' as tabla, COUNT(*) as registros FROM rol"

try {
    $result = & psql -h $AIVEN_HOST -p $AIVEN_PORT -U $AIVEN_USER -d $AIVEN_DB -c $verifyQuery
    Write-Host $result -ForegroundColor White
} catch {
    Write-Host "Error verificando datos: $_" -ForegroundColor Yellow
}

# Generar variables de entorno
Write-Host "Generando variables de entorno para Render..." -ForegroundColor Blue

$envContent = @"
# AIVEN POSTGRESQL CONFIGURATION
DB_URL=postgresql://$AIVEN_USER`:$AIVEN_PASSWORD@$AIVEN_HOST`:$AIVEN_PORT/$AIVEN_DB`?sslmode=$AIVEN_SSL
DB_USERNAME=$AIVEN_USER
DB_PASSWORD=$AIVEN_PASSWORD
DB_HOST=$AIVEN_HOST
DB_PORT=$AIVEN_PORT
DB_NAME=$AIVEN_DB
DB_SSL_MODE=$AIVEN_SSL

# EMAIL CONFIGURATION
BREVO_USERNAME=your-brevo-username
BREVO_SMTP_PASSWORD=your-brevo-password
BREVO_API_KEY=your-brevo-api-key
SENDER_EMAIL=camiloloaiza0303@gmail.com
SENDER_NAME=PetManager

# SERVICE URLS
AUTH_SERVICE_URL=https://petmanager-auth-service.onrender.com
SUPPLIER_SERVICE_URL=https://petmanager-supplier-service.onrender.com
NOTIFICATION_SERVICE_URL=https://petmanager-notification-service.onrender.com
API_GATEWAY_URL=https://petmanager-api-gateway.onrender.com
"@

$envContent | Out-File -FilePath ".env.aiven" -Encoding UTF8

Write-Host "Variables de entorno creadas en .env.aiven" -ForegroundColor Green
Write-Host ""
Write-Host "Migracion completada!" -ForegroundColor Green
Write-Host "Proximos pasos:" -ForegroundColor Blue
Write-Host "  1. Usa .env.aiven para configurar Render" -ForegroundColor Yellow
Write-Host "  2. Procede con el despliegue en Render" -ForegroundColor Yellow