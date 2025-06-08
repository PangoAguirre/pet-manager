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
    ('Admin Aiven', '.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@petmanager.com')
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

