-- LIMPIEZA INICIAL DE LA BASE DE DATOS
DROP TABLE IF EXISTS pago CASCADE;                     -- Costo del viaje
DROP TABLE IF EXISTS oferta CASCADE;             -- oferta enviadas y decisiones de aceptación/rechazo
DROP TABLE IF EXISTS viaje CASCADE;                    -- viaje con estado
DROP TABLE IF EXISTS vehiculo CASCADE;                 
DROP TABLE IF EXISTS conductor CASCADE;               -- conductor asociados a una company
DROP TABLE IF EXISTS company CASCADE;                  
DROP TABLE IF EXISTS rider CASCADE;                

DROP TYPE IF EXISTS estado_viaje_enum CASCADE;
DROP TYPE IF EXISTS estado_oferta_enum CASCADE;
DROP TYPE IF EXISTS estado_pago_enum CASCADE;
DROP TYPE IF EXISTS metodo_pago_enum CASCADE;

-- CREACIÓN DE TIPOS ENUM
CREATE TYPE estado_viaje_enum AS ENUM (
    'solicitado',
    'cancelado',
    'aceptado',
    'en curso',
    'finalizado'
); -- Estado del viaje

CREATE TYPE estado_oferta_enum AS ENUM (
    'enviada',
    'aceptada',
    'rechazada'
); -- oferta enviada y decisiones de aceptación/rechazo

CREATE TYPE estado_pago_enum AS ENUM (
    'pendiente',
    'completado',
    'fallido',
    'reembolsado'
); -- Estado del pago

CREATE TYPE metodo_pago_enum AS ENUM (
    'tarjeta',
    'efectivo'
); 


-- CREACIÓN DE TABLAS
CREATE TABLE rider (
    id_rider        BIGSERIAL PRIMARY KEY,                              
    nom_rider       VARCHAR(100) NOT NULL,
    ap_rider        VARCHAR(100) NOT NULL,
    tel_rider       VARCHAR(30) UNIQUE,         -- No hay dos personas con el mismo número
    mail_rider      VARCHAR(100) NOT NULL UNIQUE,       -- Igual con el correo
    pass_rider      VARCHAR(100) NOT NULL,
    registro_rider  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP        -- Se guarda la hora de registro
);

CREATE TABLE company (
    id_company          BIGSERIAL PRIMARY KEY,                              
    nom_company         VARCHAR(120) NOT NULL UNIQUE,                       
    cif_company         VARCHAR(30) UNIQUE                                                     
);

CREATE TABLE vehiculo (
    id_vehiculo             BIGSERIAL PRIMARY KEY,                                                 
    matricula               VARCHAR(20) NOT NULL UNIQUE,                    
    marca                   VARCHAR(60) NOT NULL,                           
    modelo                  VARCHAR(60) NOT NULL,                           
    color                   VARCHAR(40),                                    
    anio                    INT CHECK (anio BETWEEN 2000 AND 2100)                       
);

CREATE TABLE conductor (
    id_conductor            BIGSERIAL PRIMARY KEY,                                               
    id_company              BIGINT NOT NULL,                                
    id_vehiculo             BIGINT,
    nom_conductor           VARCHAR(100) NOT NULL,
    ap_conductor            VARCHAR(100) NOT NULL,
    tel_conductor           VARCHAR(30) UNIQUE,
    mail_conductor          VARCHAR(100) NOT NULL UNIQUE,
    pass_conductor          VARCHAR(100) NOT NULL,
    registro_conductor      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   

    -- AÑADIMOS LAS CLAVES FORÁNEAS
    CONSTRAINT fk_conductor_company
        FOREIGN KEY (id_company)
        REFERENCES company(id_company)
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_conductor_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo(id_vehiculo)
        ON DELETE SET NULL
);

CREATE TABLE viaje (
    id_viaje                    BIGSERIAL PRIMARY KEY,                     
    id_rider                 BIGINT NOT NULL,                           
    id_conductor       BIGINT, -- Empiezsa null porque se asigna una vez se acepta la oferta   
    origen_lat           NUMERIC(9,6) NOT NULL CHECK (origen_lat BETWEEN -90 AND 90),
    origen_lon           NUMERIC(9,6) NOT NULL CHECK (origen_lon BETWEEN -180 AND 180),
    origen_direccion     VARCHAR(255) NOT NULL,
    destino_lat          NUMERIC(9,6) NOT NULL CHECK (destino_lat BETWEEN -90 AND 90),
    destino_lon          NUMERIC(9,6) NOT NULL CHECK (destino_lon BETWEEN -180 AND 180),
    destino_direccion    VARCHAR(255) NOT NULL,
    estado_viaje         estado_viaje_enum NOT NULL DEFAULT 'solicitado',       -- Ponemos como estado determinado al generarlo "solicitado"
    distancia_km         NUMERIC(8,2) CHECK (distancia_km >= 0),
    duracion_min         INT CHECK (duracion_min >= 0),
    solicitud_viaje      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    inicio_viaje         TIMESTAMP,
    fin_viaje            TIMESTAMP,

    CONSTRAINT fk_viaje_rider
        FOREIGN KEY (id_rider)
        REFERENCES rider(id_rider)
        ON DELETE RESTRICT,

    CONSTRAINT fk_viaje_conductor
        FOREIGN KEY (id_conductor)
        REFERENCES conductor(id_conductor)
        ON DELETE SET NULL,

    CONSTRAINT chk_origen_destino_distintos
        CHECK ( -- Comprobamos que origen y destino no sean iguales
            origen_lat <> destino_lat
            OR origen_lon <> destino_lon
            OR origen_direccion <> destino_direccion
        )                                              
);

CREATE TABLE oferta (
    id_oferta            BIGSERIAL PRIMARY KEY,
    id_viaje             BIGINT NOT NULL,
    id_conductor         BIGINT NOT NULL,
    precio_oferta        NUMERIC(10,2) NOT NULL CHECK (precio_oferta >= 0), -- Comprobamos que el precio sea válido
    estado_oferta        estado_oferta_enum NOT NULL DEFAULT 'enviada',
    envio_oferta         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    respuesta_oferta     TIMESTAMP,

    CONSTRAINT fk_oferta_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje)
        ON DELETE CASCADE,

    CONSTRAINT fk_oferta_conductor
        FOREIGN KEY (id_conductor)
        REFERENCES conductor(id_conductor)
        ON DELETE CASCADE,

    CONSTRAINT uq_oferta_viaje_conductor
        UNIQUE (id_viaje, id_conductor),

    CONSTRAINT chk_respuesta_oferta
        CHECK (respuesta_oferta IS NULL OR respuesta_oferta >= envio_oferta)                                   
);

CREATE TABLE pago (
    id_pago              BIGSERIAL PRIMARY KEY,
    id_viaje             BIGINT NOT NULL UNIQUE,
    id_oferta            BIGINT NOT NULL UNIQUE,
    importe_pago         NUMERIC(10,2) NOT NULL CHECK (importe_pago >= 0),
    comision_company     NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (comision_company >= 0),
    estado_pago          estado_pago_enum NOT NULL DEFAULT 'pendiente',
    metodo_pago          metodo_pago_enum NOT NULL,

    CONSTRAINT fk_pago_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje)
        ON DELETE CASCADE,

    CONSTRAINT fk_pago_oferta
        FOREIGN KEY (id_oferta)
        REFERENCES oferta(id_oferta)
        ON DELETE RESTRICT
);

-- ÍNDICES Y VISTAS
CREATE INDEX idx_conductor_company
    ON conductor(id_company);

CREATE INDEX idx_viaje_rider
    ON viaje(id_rider);

CREATE INDEX idx_viaje_conductor
    ON viaje(id_conductor);

CREATE INDEX idx_viaje_estado
    ON viaje(estado_viaje);

CREATE INDEX idx_oferta_viaje
    ON oferta(id_viaje);

CREATE INDEX idx_oferta_conductor
    ON oferta(id_conductor);

CREATE INDEX idx_oferta_estado
    ON oferta(estado_oferta);

CREATE INDEX idx_pago_viaje
    ON pago(id_viaje);        

-- Aceptamos una sola oferta por viaje
CREATE UNIQUE INDEX uq_una_oferta_aceptada_por_viaje
    ON oferta(id_viaje)
    WHERE estado_oferta = 'aceptada';