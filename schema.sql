-- LIMPIEZA INICIAL DE LA BASE DE DATOS

DROP TABLE IF EXISTS auditoria_operaciones CASCADE;     -- Historial y auditoría básica de operaciones
DROP TABLE IF EXISTS pagos CASCADE;                     -- Costo del viaje
DROP TABLE IF EXISTS ofertas_viaje CASCADE;             -- Ofertas enviadas y decisiones de aceptación/rechazo
DROP TABLE IF EXISTS viajes CASCADE;                    -- Viajes con estado
DROP TABLE IF EXISTS ubicaciones CASCADE;               -- A y B son geolocalizaciones
DROP TABLE IF EXISTS vehiculos CASCADE;                 
DROP TABLE IF EXISTS conductores CASCADE;               -- conductores asociados a una company
DROP TABLE IF EXISTS company CASCADE;                  
DROP TABLE IF EXISTS rider CASCADE;                
DROP TABLE IF EXISTS usuarios CASCADE;                  -- Usuarios (rider y conductores) y sus perfiles

DROP TYPE IF EXISTS tipo_rol_usuario CASCADE;
DROP TYPE IF EXISTS tipo_estado_viaje CASCADE;
DROP TYPE IF EXISTS tipo_estado_oferta CASCADE;
DROP TYPE IF EXISTS tipo_estado_pago CASCADE;


-- CREACIÓN DE TIPOS ENUM

CREATE TYPE tipo_rol_usuario AS ENUM (
    'rider',
    'conductor',
    'admin'
); -- "Usuarios y sus perfiles"

CREATE TYPE tipo_estado_viaje AS ENUM (
    'solicitado',
    'aceptado',
    'en_curso',
    'finalizado',
    'cancelado'
); -- "Viajes con estado"

CREATE TYPE tipo_estado_oferta AS ENUM (
    'pendiente',
    'aceptada',
    'rechazada',
    'expirada'
); -- "Ofertas enviadas y decisiones de aceptación/rechazo"

CREATE TYPE tipo_estado_pago AS ENUM (
    'pendiente',
    'pagado',
    'fallido',
    'reembolsado'
); -- "Dinero del viaje"


-- CREACIÓN DE TABLAS

CREATE TABLE usuarios (
    id_usuario          BIGSERIAL PRIMARY KEY,                              
    nombre_completo     VARCHAR(120) NOT NULL,                              
    email               VARCHAR(150) NOT NULL UNIQUE,                       
    telefono            VARCHAR(30) UNIQUE,                                 
    rol                 tipo_rol_usuario NOT NULL,                          
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,       
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,       
    activo              BOOLEAN NOT NULL DEFAULT TRUE                       
);

CREATE TABLE rider (
    id_rider         BIGSERIAL PRIMARY KEY,                              
    id_usuario          BIGINT NOT NULL UNIQUE,                             
    valoracion          NUMERIC(3,2) NOT NULL DEFAULT 5.00
                        CHECK (valoracion BETWEEN 0 AND 5),                 

    CONSTRAINT fk_rider_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

CREATE TABLE company (
    id_company          BIGSERIAL PRIMARY KEY,                              
    nombre              VARCHAR(120) NOT NULL UNIQUE,                       
    cif                 VARCHAR(30) UNIQUE,                                 
    pais                VARCHAR(80),                                        
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,       
    activa              BOOLEAN NOT NULL DEFAULT TRUE                       
);

CREATE TABLE conductores (
    id_conductor            BIGSERIAL PRIMARY KEY,                          
    id_usuario              BIGINT NOT NULL UNIQUE,                         
    id_company              BIGINT NOT NULL,                                
    numero_licencia         VARCHAR(50) NOT NULL UNIQUE,                    
    valoracion              NUMERIC(3,2) NOT NULL DEFAULT 5.00
                            CHECK (valoracion BETWEEN 0 AND 5),             
    disponible              BOOLEAN NOT NULL DEFAULT TRUE,                  
    fecha_creacion          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   

    CONSTRAINT fk_conductores_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_conductores_company
        FOREIGN KEY (id_company)
        REFERENCES company(id_company)
        ON DELETE RESTRICT
);

CREATE TABLE vehiculos (
    id_vehiculo             BIGSERIAL PRIMARY KEY,                          
    id_conductor            BIGINT NOT NULL UNIQUE,                         
    matricula               VARCHAR(20) NOT NULL UNIQUE,                    
    marca                   VARCHAR(60) NOT NULL,                           
    modelo                  VARCHAR(60) NOT NULL,                           
    color                   VARCHAR(40),                                    
    anio                    INT CHECK (anio BETWEEN 2000 AND 2100),         
    plazas                  INT NOT NULL DEFAULT 4 CHECK (plazas BETWEEN 1 AND 8), 
    activo                  BOOLEAN NOT NULL DEFAULT TRUE,                  

    CONSTRAINT fk_vehiculos_conductores
        FOREIGN KEY (id_conductor)
        REFERENCES conductores(id_conductor)
        ON DELETE CASCADE
);

CREATE TABLE ubicaciones (
    id_ubicacion            BIGSERIAL PRIMARY KEY,                          
    direccion_texto         VARCHAR(255),                                   
    latitud                 NUMERIC(9,6) NOT NULL
                            CHECK (latitud BETWEEN -90 AND 90),             
    longitud                NUMERIC(9,6) NOT NULL
                            CHECK (longitud BETWEEN -180 AND 180),          
    ciudad                  VARCHAR(100),                                  
    pais                    VARCHAR(100)                                    
);

CREATE TABLE viajes (
    id_viaje                    BIGSERIAL PRIMARY KEY,                     
    id_rider                 BIGINT NOT NULL,                           
    id_conductor_asignado       BIGINT,                                     
    id_ubicacion_origen         BIGINT NOT NULL,                            
    id_ubicacion_destino        BIGINT NOT NULL,                            
    fecha_solicitud             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    fecha_aceptacion            TIMESTAMP,                                  
    fecha_inicio                TIMESTAMP,                                 
    fecha_fin                   TIMESTAMP,                                 
    fecha_cancelacion           TIMESTAMP,                                  
    estado                      tipo_estado_viaje NOT NULL DEFAULT 'solicitado', 
    km_estimados                NUMERIC(8,2) CHECK (km_estimados >= 0),     
    km_reales                   NUMERIC(8,2) CHECK (km_reales >= 0),        
    minutos_estimados           INT CHECK (minutos_estimados >= 0),         
    minutos_reales              INT CHECK (minutos_reales >= 0),            
    precio_estimado             NUMERIC(10,2) CHECK (precio_estimado >= 0), 
    precio_final                NUMERIC(10,2) CHECK (precio_final >= 0),    

    CONSTRAINT fk_viajes_rider
        FOREIGN KEY (id_rider)
        REFERENCES rider(id_rider)
        ON DELETE RESTRICT,

    CONSTRAINT fk_viajes_conductores
        FOREIGN KEY (id_conductor_asignado)
        REFERENCES conductores(id_conductor)
        ON DELETE SET NULL,

    CONSTRAINT fk_viajes_ubicacion_origen
        FOREIGN KEY (id_ubicacion_origen)
        REFERENCES ubicaciones(id_ubicacion)
        ON DELETE RESTRICT,

    CONSTRAINT fk_viajes_ubicacion_destino
        FOREIGN KEY (id_ubicacion_destino)
        REFERENCES ubicaciones(id_ubicacion)
        ON DELETE RESTRICT,

    CONSTRAINT chk_viajes_origen_distinto_destino
        CHECK (id_ubicacion_origen <> id_ubicacion_destino)                
);

CREATE TABLE ofertas_viaje (
    id_oferta                BIGSERIAL PRIMARY KEY,                        
    id_viaje                 BIGINT NOT NULL,                               
    id_conductor             BIGINT NOT NULL,                               
    fecha_envio              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    fecha_respuesta          TIMESTAMP,                                     
    estado                   tipo_estado_oferta NOT NULL DEFAULT 'pendiente', 

    CONSTRAINT fk_ofertas_viaje_viajes
        FOREIGN KEY (id_viaje)
        REFERENCES viajes(id_viaje)
        ON DELETE CASCADE,

    CONSTRAINT fk_ofertas_viaje_conductores
        FOREIGN KEY (id_conductor)
        REFERENCES conductores(id_conductor)
        ON DELETE CASCADE,

    CONSTRAINT uq_oferta_viaje_conductor
        UNIQUE (id_viaje, id_conductor)                                    
);

CREATE TABLE pagos (
    id_pago                  BIGSERIAL PRIMARY KEY,                       
    id_viaje                 BIGINT NOT NULL UNIQUE,                       
    importe                  NUMERIC(10,2) NOT NULL CHECK (importe >= 0),   
    moneda                   VARCHAR(3) NOT NULL DEFAULT 'EUR',             
    estado_pago              tipo_estado_pago NOT NULL DEFAULT 'pendiente', 
    fecha_pago               TIMESTAMP,                                    
    fecha_creacion           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  

    CONSTRAINT fk_pagos_viajes
        FOREIGN KEY (id_viaje)
        REFERENCES viajes(id_viaje)
        ON DELETE CASCADE
);

CREATE TABLE auditoria_operaciones (
    id_auditoria             BIGSERIAL PRIMARY KEY,                         
    nombre_tabla             VARCHAR(100) NOT NULL,                        
    operacion                VARCHAR(10) NOT NULL,                         
    id_registro              BIGINT,                                       
    datos_anteriores         JSONB,                                        
    datos_nuevos             JSONB,                                        
    fecha_cambio             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  
    cambiado_por             VARCHAR(100) NOT NULL DEFAULT CURRENT_USER     
);


-- ÍNDICES Y VISTAS


CREATE INDEX idx_usuarios_rol
    ON usuarios(rol);                                                      

CREATE INDEX idx_conductores_company
    ON conductores(id_company);                                             

CREATE INDEX idx_conductores_disponible
    ON conductores(disponible);                                             

CREATE INDEX idx_viajes_rider
    ON viajes(id_rider);                                                 

CREATE INDEX idx_viajes_conductor_asignado
    ON viajes(id_conductor_asignado);                                      

CREATE INDEX idx_viajes_estado
    ON viajes(estado);                                                      

CREATE INDEX idx_viajes_fecha_solicitud
    ON viajes(fecha_solicitud);                                             

CREATE INDEX idx_ofertas_viaje_viaje
    ON ofertas_viaje(id_viaje);                                            

CREATE INDEX idx_ofertas_viaje_conductor
    ON ofertas_viaje(id_conductor);                                         

CREATE INDEX idx_ofertas_viaje_estado
    ON ofertas_viaje(estado);                                               

CREATE INDEX idx_pagos_viaje
    ON pagos(id_viaje);             


-- RESTRICCIÓN CLAVE DEL NEGOCIO (Solo una oferta aceptada por viaje)

CREATE UNIQUE INDEX uq_una_oferta_aceptada_por_viaje
    ON ofertas_viaje(id_viaje)
    WHERE estado = 'aceptada';