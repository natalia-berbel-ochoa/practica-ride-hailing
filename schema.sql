-- LIMPIEZA INICIAL DE LA BASE DE DATOS
DROP INDEX IF EXISTS uq_oferta_viaje_conductor CASCADE;      -- Eliminamos el índice único anterior si existe
DROP INDEX IF EXISTS uq_una_oferta_aceptada_por_viaje CASCADE; -- Eliminamos la restricción de una oferta aceptada por viaje
DROP TABLE IF EXISTS auditoria_operaciones CASCADE;          -- Tabla de auditoría general de operaciones
DROP TABLE IF EXISTS historial_estado_oferta CASCADE;        -- Historial de cambios de estado de las ofertas
DROP TABLE IF EXISTS historial_estado_viaje CASCADE;         -- Historial de cambios de estado de los viajes
DROP TABLE IF EXISTS pago CASCADE;                           -- Costo del viaje
DROP TABLE IF EXISTS oferta CASCADE;                         -- oferta enviadas y decisiones de aceptación/rechazo
DROP TABLE IF EXISTS viaje CASCADE;                          -- viaje con estado
DROP TABLE IF EXISTS vehiculo CASCADE;                       -- Vehículos asociados a los conductores
DROP TABLE IF EXISTS conductor CASCADE;                      -- conductor asociados a una company
DROP TABLE IF EXISTS company CASCADE;                        -- Empresas que agrupan conductores
DROP TABLE IF EXISTS rider CASCADE;                          -- Usuarios que solicitan viajes

DROP TYPE IF EXISTS estado_viaje_enum CASCADE;               -- Tipo enumerado para el estado del viaje
DROP TYPE IF EXISTS estado_oferta_enum CASCADE;              -- Tipo enumerado para el estado de la oferta
DROP TYPE IF EXISTS estado_pago_enum CASCADE;                -- Tipo enumerado para el estado del pago
DROP TYPE IF EXISTS metodo_pago_enum CASCADE;                -- Tipo enumerado para el método de pago

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
); -- Método permitido para abonar el pago


-- CREACIÓN DE TABLAS

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE rider (
    id_rider        BIGSERIAL PRIMARY KEY,                        -- Identificador único del rider
    nom_rider       VARCHAR(100) NOT NULL,                       -- Nombre del rider
    ap_rider        VARCHAR(100) NOT NULL,                       -- Apellidos del rider
    tel_rider       VARCHAR(30) UNIQUE,                          -- No hay dos personas con el mismo número
    mail_rider      VARCHAR(100) NOT NULL UNIQUE,                -- Igual con el correo
    hash_pass_rider VARCHAR(72)  NOT NULL,                      -- Contraseña del rider
    registro_rider  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  -- Se guarda la hora de registro
);

CREATE TABLE company (
    id_company          BIGSERIAL PRIMARY KEY,                   -- Identificador único de la empresa
    nom_company         VARCHAR(120) NOT NULL UNIQUE,           -- El nombre de la empresa no se puede repetir
    cif_company         VARCHAR(30) UNIQUE                      -- El CIF también debe ser único
);

CREATE TABLE vehiculo (
    id_vehiculo             BIGSERIAL PRIMARY KEY,              -- Identificador único del vehículo 
    matricula               VARCHAR(20) NOT NULL UNIQUE,        -- Cada vehículo tiene matrícula única
    marca                   VARCHAR(60) NOT NULL,               -- Marca del vehículo
    modelo                  VARCHAR(60) NOT NULL,               -- Modelo del vehículo
    color                   VARCHAR(40),                        -- Color del vehículo
    anio                    INT CHECK (anio BETWEEN 2000 AND 2100) -- Restringimos el año a un rango razonable
);

CREATE TABLE conductor (
    id_conductor            BIGSERIAL PRIMARY KEY,              -- Identificador único del conductor
    id_company              BIGINT NOT NULL,                    -- Empresa a la que pertenece el conductor
    id_vehiculo             BIGINT NOT NULL UNIQUE,                      -- Vehículo asignado al conductor
    nom_conductor           VARCHAR(100) NOT NULL,              -- Nombre del conductor
    ap_conductor            VARCHAR(100) NOT NULL,              -- Apellidos del conductor
    tel_conductor           VARCHAR(30) UNIQUE,                 -- No se repiten teléfonos
    mail_conductor          VARCHAR(100) NOT NULL UNIQUE,       -- No se repiten correos
    hash_pass_conductor VARCHAR(72)  NOT NULL,              -- Contraseña del conductor
    registro_conductor      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Fecha de alta del conductor

    -- AÑADIMOS LAS CLAVES FORÁNEAS
    CONSTRAINT fk_conductor_company
        FOREIGN KEY (id_company)
        REFERENCES company(id_company)
        ON DELETE RESTRICT,                 -- No permitimos borrar una empresa con conductores asociados
    
    CONSTRAINT fk_conductor_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo(id_vehiculo)
        ON DELETE SET NULL                  -- Si se borra el vehículo, el conductor se queda sin vehículo asignado
);

CREATE TABLE viaje (
    id_viaje             BIGSERIAL PRIMARY KEY,                 -- Identificador único del viaje
    id_rider             BIGINT NOT NULL,                       -- Rider que solicita el viaje
    id_conductor         BIGINT, -- Empiezsa null porque se asigna una vez se acepta la oferta   
    origen_lat           NUMERIC(9,6) NOT NULL CHECK (origen_lat BETWEEN -90 AND 90),       -- Latitud del origen
    origen_lon           NUMERIC(9,6) NOT NULL CHECK (origen_lon BETWEEN -180 AND 180),      -- Longitud del origen
    origen_direccion     VARCHAR(255) NOT NULL,                -- Dirección textual del origen
    destino_lat          NUMERIC(9,6) NOT NULL CHECK (destino_lat BETWEEN -90 AND 90),       -- Latitud del destino
    destino_lon          NUMERIC(9,6) NOT NULL CHECK (destino_lon BETWEEN -180 AND 180),     -- Longitud del destino
    destino_direccion    VARCHAR(255) NOT NULL,                -- Dirección textual del destino
    estado_viaje         estado_viaje_enum NOT NULL DEFAULT 'solicitado', -- Ponemos como estado determinado al generarlo "solicitado"
    distancia_km         NUMERIC(8,2) CHECK (distancia_km >= 0), -- Distancia estimada del trayecto
    duracion_min         INT CHECK (duracion_min >= 0),          -- Duración estimada del trayecto en minutos
    solicitud_viaje      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Momento en el que se solicita el viaje
    inicio_viaje         TIMESTAMP,                              -- Momento real de inicio del viaje
    fin_viaje            TIMESTAMP,                              -- Momento real de finalización del viaje

    CONSTRAINT fk_viaje_rider
        FOREIGN KEY (id_rider)
        REFERENCES rider(id_rider)
        ON DELETE RESTRICT,                 -- No permitimos borrar riders con viajes asociados

    CONSTRAINT fk_viaje_conductor
        FOREIGN KEY (id_conductor)
        REFERENCES conductor(id_conductor)
        ON DELETE SET NULL,                 -- Si se borra el conductor, el viaje queda sin conductor asignado

    CONSTRAINT chk_origen_destino_distintos
        CHECK ( -- Comprobamos que origen y destino no sean iguales
            origen_lat <> destino_lat
            OR origen_lon <> destino_lon
            OR origen_direccion <> destino_direccion 
        ),-- Debe cambiar al menos una coordenada o la dirección
        
    CONSTRAINT chk_fechas_viaje
        CHECK (
            inicio_viaje IS NULL
            OR fin_viaje IS NULL
            OR fin_viaje >= inicio_viaje
        ),  

    CONSTRAINT chk_viaje_finalizado_completo
        CHECK (
            estado_viaje <> 'finalizado'
            OR (
                id_conductor IS NOT NULL
                AND inicio_viaje IS NOT NULL
                AND fin_viaje IS NOT NULL
                AND distancia_km IS NOT NULL
                AND duracion_min IS NOT NULL
            )
        ),
        
    CONSTRAINT chk_viaje_aceptado_con_conductor
    CHECK (
        estado_viaje NOT IN ('aceptado', 'en curso', 'finalizado')
        OR id_conductor IS NOT NULL
    )                               
);

CREATE TABLE oferta (
    id_oferta            BIGSERIAL PRIMARY KEY,                  -- Identificador único de la oferta
    id_viaje             BIGINT NOT NULL,                        -- Viaje al que pertenece la oferta
    id_conductor         BIGINT NOT NULL,                        -- Conductor que emite la oferta
    precio_oferta        NUMERIC(10,2) NOT NULL CHECK (precio_oferta >= 0), -- Comprobamos que el precio sea válido
    estado_oferta        estado_oferta_enum NOT NULL DEFAULT 'enviada', -- Estado inicial de la oferta
    envio_oferta         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Momento en el que se envía la oferta
    respuesta_oferta     TIMESTAMP,                              -- Momento en el que se acepta o rechaza la oferta

    CONSTRAINT fk_oferta_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje)
        ON DELETE CASCADE,                   -- Si se elimina el viaje, se eliminan sus ofertas

    CONSTRAINT fk_oferta_conductor
        FOREIGN KEY (id_conductor)
        REFERENCES conductor(id_conductor)
        ON DELETE CASCADE,                   -- Si se elimina el conductor, se eliminan sus ofertas

    CONSTRAINT uq_oferta_viaje_conductor_pair
        UNIQUE (id_viaje, id_conductor),     -- Un conductor solo puede enviar una oferta por viaje

    CONSTRAINT chk_respuesta_oferta
        CHECK (respuesta_oferta IS NULL OR respuesta_oferta >= envio_oferta) -- La respuesta no puede ser anterior al envío
);

CREATE TABLE pago (
    id_pago              BIGSERIAL PRIMARY KEY,                  -- Identificador único del pago
    id_viaje             BIGINT NOT NULL UNIQUE,                 -- Cada viaje solo puede tener un pago
    id_oferta            BIGINT NOT NULL UNIQUE,                 -- Cada pago se asocia a una sola oferta
    importe_pago         NUMERIC(10,2) NOT NULL CHECK (importe_pago >= 0), -- Importe total cobrado
    comision_company     NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (comision_company >= 0), -- Comisión que recibe la empresa
    estado_pago          estado_pago_enum NOT NULL DEFAULT 'pendiente', -- Estado inicial del pago
    metodo_pago          metodo_pago_enum NOT NULL,              -- Forma en la que se realiza el pago

    CONSTRAINT fk_pago_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje)
        ON DELETE CASCADE,                   -- Si se elimina el viaje, también se elimina el pago

    CONSTRAINT fk_pago_oferta
        FOREIGN KEY (id_oferta)
        REFERENCES oferta(id_oferta)
        ON DELETE RESTRICT                   -- No permitimos borrar la oferta si ya tiene pago asociado
);

CREATE TABLE historial_estado_viaje (
    id_historial         BIGSERIAL PRIMARY KEY,                  -- Identificador único del registro histórico
    id_viaje             BIGINT NOT NULL,                        -- Viaje cuyo estado cambia
    estado_anterior      estado_viaje_enum,                      -- Estado previo del viaje
    estado_nuevo         estado_viaje_enum NOT NULL,             -- Nuevo estado del viaje
    fecha_cambio         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Fecha del cambio de estado
    usuario_bd           VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,   -- Usuario de base de datos que provoca el cambio

    CONSTRAINT fk_hist_viaje
        FOREIGN KEY (id_viaje)
        REFERENCES viaje(id_viaje)
        ON DELETE CASCADE                   -- Si se elimina el viaje, también se elimina su historial
);

CREATE TABLE historial_estado_oferta (
    id_historial         BIGSERIAL PRIMARY KEY,                  -- Identificador único del registro histórico
    id_oferta            BIGINT NOT NULL,                        -- Oferta cuyo estado cambia
    estado_anterior      estado_oferta_enum,                     -- Estado previo de la oferta
    estado_nuevo         estado_oferta_enum NOT NULL,            -- Nuevo estado de la oferta
    fecha_cambio         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Fecha del cambio de estado
    usuario_bd           VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,   -- Usuario de base de datos que provoca el cambio

    CONSTRAINT fk_hist_oferta
        FOREIGN KEY (id_oferta)
        REFERENCES oferta(id_oferta)
        ON DELETE CASCADE                   -- Si se elimina la oferta, también se elimina su historial
);

CREATE TABLE auditoria_operaciones (
    id_auditoria         BIGSERIAL PRIMARY KEY,                  -- Identificador único del evento de auditoría
    tabla_afectada       VARCHAR(50) NOT NULL,                   -- Nombre de la tabla afectada
    operacion            VARCHAR(10) NOT NULL,                   -- Tipo de operación realizada
    id_registro          BIGINT,                                 -- Identificador del registro afectado
    fecha_operacion      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Fecha de la operación
    usuario_bd           VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,   -- Usuario que ejecuta la operación
    datos_antes          JSONB,                                  -- Estado anterior del registro
    datos_despues        JSONB                                   -- Estado posterior del registro
);


-- FUNCIONES DE HISTORIAL

CREATE OR REPLACE FUNCTION fn_historial_viaje()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO historial_estado_viaje (id_viaje, estado_anterior, estado_nuevo)
        VALUES (NEW.id_viaje, NULL, NEW.estado_viaje);           -- Registramos el estado inicial al crear el viaje

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.estado_viaje IS DISTINCT FROM NEW.estado_viaje THEN
            INSERT INTO historial_estado_viaje (id_viaje, estado_anterior, estado_nuevo)
            VALUES (NEW.id_viaje, OLD.estado_viaje, NEW.estado_viaje); -- Registramos solo cambios reales de estado
        END IF;
    END IF;

    RETURN NEW;                                                  -- Devolvemos el registro nuevo para continuar con la operación
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_historial_oferta()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO historial_estado_oferta (id_oferta, estado_anterior, estado_nuevo)
        VALUES (NEW.id_oferta, NULL, NEW.estado_oferta);         -- Registramos el estado inicial al crear la oferta

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.estado_oferta IS DISTINCT FROM NEW.estado_oferta THEN
            INSERT INTO historial_estado_oferta (id_oferta, estado_anterior, estado_nuevo)
            VALUES (NEW.id_oferta, OLD.estado_oferta, NEW.estado_oferta); -- Registramos solo cambios reales de estado
        END IF;
    END IF;

    RETURN NEW;                                                  -- Devolvemos el registro nuevo para continuar con la operación
END;
$$ LANGUAGE plpgsql;


-- FUNCIONES DE AUDITORÍA

CREATE OR REPLACE FUNCTION fn_auditoria_viaje()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'viaje', 'INSERT', NEW.id_viaje, NULL, to_jsonb(NEW) -- Guardamos el registro nuevo completo
        );
        RETURN NEW;                                              -- Devolvemos el nuevo registro

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'viaje', 'UPDATE', NEW.id_viaje, to_jsonb(OLD), to_jsonb(NEW) -- Guardamos el antes y el después
        );
        RETURN NEW;                                              -- Devolvemos el nuevo registro actualizado

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'viaje', 'DELETE', OLD.id_viaje, to_jsonb(OLD), NULL -- Guardamos solo el estado anterior al borrado
        );
        RETURN OLD;                                              -- Devolvemos el registro antiguo eliminado
    END IF;

    RETURN NULL;                                                 -- Por seguridad, devolvemos NULL si no entra en ningún caso
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_auditoria_oferta()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'oferta', 'INSERT', NEW.id_oferta, NULL, to_jsonb(NEW) -- Guardamos el registro nuevo completo
        );
        RETURN NEW;                                                -- Devolvemos el nuevo registro

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'oferta', 'UPDATE', NEW.id_oferta, to_jsonb(OLD), to_jsonb(NEW) -- Guardamos el antes y el después
        );
        RETURN NEW;                                                -- Devolvemos el nuevo registro actualizado

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'oferta', 'DELETE', OLD.id_oferta, to_jsonb(OLD), NULL -- Guardamos solo el estado anterior al borrado
        );
        RETURN OLD;                                                -- Devolvemos el registro antiguo eliminado
    END IF;

    RETURN NULL;                                                   -- Por seguridad, devolvemos NULL si no entra en ningún caso
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_auditoria_pago()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'pago', 'INSERT', NEW.id_pago, NULL, to_jsonb(NEW) -- Guardamos el registro nuevo completo
        );
        RETURN NEW;                                            -- Devolvemos el nuevo registro

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'pago', 'UPDATE', NEW.id_pago, to_jsonb(OLD), to_jsonb(NEW) -- Guardamos el antes y el después
        );
        RETURN NEW;                                            -- Devolvemos el nuevo registro actualizado

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_operaciones (
            tabla_afectada, operacion, id_registro, datos_antes, datos_despues
        )
        VALUES (
            'pago', 'DELETE', OLD.id_pago, to_jsonb(OLD), NULL -- Guardamos solo el estado anterior al borrado
        );
        RETURN OLD;                                            -- Devolvemos el registro antiguo eliminado
    END IF;

    RETURN NULL;                                               -- Por seguridad, devolvemos NULL si no entra en ningún caso
END;
$$ LANGUAGE plpgsql;

-- ÍNDICES Y VISTAS
CREATE INDEX idx_conductor_company
    ON conductor(id_company);          -- Mejora las búsquedas de conductores por empresa

CREATE INDEX idx_viaje_rider
    ON viaje(id_rider);                -- Mejora las consultas de viajes de un rider

CREATE INDEX idx_viaje_conductor
    ON viaje(id_conductor);            -- Mejora las consultas de viajes asignados a un conductor

CREATE INDEX idx_viaje_estado
    ON viaje(estado_viaje);            -- Mejora los filtros por estado del viaje

CREATE INDEX idx_oferta_viaje
    ON oferta(id_viaje);               -- Mejora las consultas de ofertas asociadas a un viaje

CREATE INDEX idx_oferta_conductor
    ON oferta(id_conductor);           -- Mejora las consultas de ofertas realizadas por un conductor

CREATE INDEX idx_oferta_estado
    ON oferta(estado_oferta);          -- Mejora los filtros por estado de la oferta

CREATE INDEX idx_pago_viaje
    ON pago(id_viaje);                 -- Acelera la localización del pago de un viaje concreto

-- Aceptamos una sola oferta por viaje
CREATE UNIQUE INDEX uq_una_oferta_aceptada_por_viaje
    ON oferta(id_viaje)
    WHERE estado_oferta = 'aceptada';  -- Garantiza que solo haya una oferta aceptada por viaje


-- TRIGGERS DE HISTORIAL

CREATE TRIGGER trg_historial_viaje
AFTER INSERT OR UPDATE ON viaje
FOR EACH ROW
EXECUTE FUNCTION fn_historial_viaje();     -- Ejecuta el registro histórico al insertar o cambiar el estado

CREATE TRIGGER trg_historial_oferta
AFTER INSERT OR UPDATE ON oferta
FOR EACH ROW
EXECUTE FUNCTION fn_historial_oferta();    -- Ejecuta el registro histórico al insertar o cambiar el estado


-- TRIGGERS DE AUDITORÍA

CREATE TRIGGER trg_auditoria_viaje
AFTER INSERT OR UPDATE OR DELETE ON viaje
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_viaje();     -- Registra en auditoría cualquier operación sobre viaje

CREATE TRIGGER trg_auditoria_oferta
AFTER INSERT OR UPDATE OR DELETE ON oferta
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_oferta();    -- Registra en auditoría cualquier operación sobre oferta

CREATE TRIGGER trg_auditoria_pago
AFTER INSERT OR UPDATE OR DELETE ON pago
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_pago();      -- Registra en auditoría cualquier operación sobre pago