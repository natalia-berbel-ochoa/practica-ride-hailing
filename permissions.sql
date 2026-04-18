-- permissions.sql (versión basada en apuntes)

-- Limpieza
DROP USER IF EXISTS usr_rider;
DROP USER IF EXISTS usr_conductor;
DROP USER IF EXISTS usr_backend;
DROP USER IF EXISTS usr_analista;
DROP USER IF EXISTS usr_dba;
DROP ROLE IF EXISTS app_rider;
DROP ROLE IF EXISTS app_conductor;
DROP ROLE IF EXISTS app_backend;
DROP ROLE IF EXISTS analista;
DROP ROLE IF EXISTS dba_role;

-- Roles (Tema 3, sección 5.4)
CREATE ROLE app_rider;
CREATE ROLE app_conductor;
CREATE ROLE app_backend;
CREATE ROLE analista;
CREATE ROLE dba_role;

-- Permisos por rol (Tema 3, sección 5.3)
GRANT SELECT, INSERT ON viaje TO app_rider;
GRANT SELECT ON oferta TO app_rider;
GRANT SELECT, UPDATE ON rider TO app_rider;

GRANT SELECT, UPDATE ON oferta TO app_conductor;
GRANT SELECT, UPDATE ON viaje TO app_conductor;
GRANT SELECT, UPDATE ON conductor TO app_conductor;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_backend;

GRANT SELECT ON viaje, oferta, pago, company, vehiculo TO analista;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dba_role;

-- Usuarios (Tema 3, sección 4.1)
CREATE USER usr_rider     WITH PASSWORD 'rider_CHANGE_ME'     IN ROLE app_rider;
CREATE USER usr_conductor WITH PASSWORD 'conductor_CHANGE_ME' IN ROLE app_conductor;
CREATE USER usr_backend   WITH PASSWORD 'backend_CHANGE_ME'   IN ROLE app_backend;
CREATE USER usr_analista  WITH PASSWORD 'analista_CHANGE_ME'  IN ROLE analista;
CREATE USER usr_dba       WITH PASSWORD 'dba_CHANGE_ME'       IN ROLE dba_role;

-- Vista para el analista sin datos personales (Tema 3, sección 6.1)
CREATE VIEW vista_analista_conductores AS
SELECT id_conductor, nom_conductor, ap_conductor, nom_company, marca, modelo
FROM conductor JOIN company USING (id_company) JOIN vehiculo USING (id_vehiculo);

GRANT SELECT ON vista_analista_conductores TO analista;



--AVANZADA
-- LIMPIEZA (por si se ejecuta varias veces, para evitar errores de duplicados)
 
-- Revocamos antes de borrar para evitar dependencias
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM app_rider;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM app_conductor;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM app_backend;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analista;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM dba_role;
 
DROP POLICY IF EXISTS rider_select_viaje ON viaje;
DROP POLICY IF EXISTS rider_insert_viaje ON viaje;
DROP POLICY IF EXISTS rider_update_viaje ON viaje;
DROP POLICY IF EXISTS rider_select_rider ON rider;
DROP POLICY IF EXISTS rider_update_rider ON rider;
DROP POLICY IF EXISTS rider_select_pago ON pago;
 
DROP POLICY IF EXISTS conductor_select_conductor ON conductor;
DROP POLICY IF EXISTS conductor_update_conductor ON conductor;
DROP POLICY IF EXISTS conductor_select_viaje ON viaje;
DROP POLICY IF EXISTS conductor_select_oferta ON oferta;
DROP POLICY IF EXISTS conductor_update_oferta ON oferta;
DROP POLICY IF EXISTS conductor_select_vehiculo ON vehiculo;
DROP POLICY IF EXISTS conductor_select_pago ON pago;
 
DROP POLICY IF EXISTS backend_all_rider ON rider;
DROP POLICY IF EXISTS backend_all_conductor ON conductor;
DROP POLICY IF EXISTS backend_all_viaje ON viaje;
DROP POLICY IF EXISTS backend_all_oferta ON oferta;
DROP POLICY IF EXISTS backend_all_vehiculo ON vehiculo;
DROP POLICY IF EXISTS backend_all_company ON company;
DROP POLICY IF EXISTS backend_all_pago ON pago;
DROP POLICY IF EXISTS backend_all_hist_viaje ON historial_estado_viaje;
DROP POLICY IF EXISTS backend_all_hist_oferta ON historial_estado_oferta;
DROP POLICY IF EXISTS backend_all_auditoria ON auditoria_operaciones;
 
DROP POLICY IF EXISTS analista_select_hist_viaje ON historial_estado_viaje;
DROP POLICY IF EXISTS analista_select_hist_oferta ON historial_estado_oferta;
DROP POLICY IF EXISTS analista_select_auditoria ON auditoria_operaciones;
 
DROP VIEW IF EXISTS vista_analista_viajes CASCADE;
DROP VIEW IF EXISTS vista_analista_conductores CASCADE;
DROP VIEW IF EXISTS v_tasa_aceptacion CASCADE;
 
DROP USER IF EXISTS usr_rider;
DROP USER IF EXISTS usr_conductor;
DROP USER IF EXISTS usr_backend;
DROP USER IF EXISTS usr_analista;
DROP USER IF EXISTS usr_dba;
 
DROP ROLE IF EXISTS app_rider;
DROP ROLE IF EXISTS app_conductor;
DROP ROLE IF EXISTS app_backend;
DROP ROLE IF EXISTS analista;
DROP ROLE IF EXISTS dba_role;

-- CREACIÓN DE ROLES (agrupan permisos, no tienen login)
CREATE ROLE app_rider; -- app_rider: representa la app móvil del rider, solo puede ver y crear lo que necesita para solicitar viajes y ver su historial

CREATE ROLE app_conductor; -- app_conductor: representa la app móvil del conductor, solo puede ver y crear lo que necesita para aceptar solicitudes y gestionar sus viajes

CREATE ROLE app_backend; -- app_backend: representa la aplicación backend, tiene permisos para gestionar todos los datos y funcionalidades del sistema

CREATE ROLE analista; -- analista: representa el rol de analista de datos, tiene permisos para consultar y generar informes, pero no para modificar datos

CREATE ROLE dba_role; -- dba_role: representa el rol de database administrator, tiene permisos para gestionar la base de datos y sus objetos, pero no para acceder a los datos de las tablas de la aplicación

-- CREACIÓN DE USUARIOS (tienen login, se asignan a roles)
-- Las contraseñas deben ser cambiadas por valores seguros antes de usar en producción
CREATE USER usr_rider WITH PASSWORD 'rider_pass_CHANGE_ME' IN ROLE app_rider;
CREATE USER usr_conductor WITH PASSWORD 'conductor_pass_CHANGE_ME' IN ROLE app_conductor;
CREATE USER usr_backend WITH PASSWORD 'backend_pass_CHANGE_ME' IN ROLE app_backend;
CREATE USER usr_analista WITH PASSWORD 'analista_pass_CHANGE_ME' IN ROLE analista;
CREATE USER usr_dba WITH PASSWORD 'dba_pass_CHANGE_ME' IN ROLE dba_role;

-- Todos los usuarios necesitan permisos de conexión y uso del esquema público
GRANT USAGE ON SCHEMA public TO app_rider, app_conductor, app_backend, analista, dba_role;
-- Permisos básicos de lectura y escritura sobre tablas
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_rider, app_conductor, app_backend;


-- PERMISOS DETALLADOS POR ROL
-- El rider y el conductor pueden ver el nombre de la empresa
GRANT SELECT ON company TO app_rider, app_conductor, analista;
-- El conductor puede ver el vehículo (el suyo, filtrado luego por RLS)
GRANT SELECT ON vehiculo TO app_conductor;
-- El rider, conductor y analista pueden ver los pagos, pero el analista no ve datos personales del rider ni conductor (filtrado luego por RLS)
GRANT SELECT ON pago TO app_rider, app_conductor, analista;

-- ROW LEVEL SECURITY (RIDER): el rider solo puede ver y gestionar sus propios viajes y ofertas
ALTER TABLE viaje ENABLE ROW LEVEL SECURITY;
ALTER TABLE rider ENABLE ROW LEVEL SECURITY;
ALTER TABLE pago ENABLE ROW LEVEL SECURITY;

-- El rider solo ve su propio perfil
CREATE POLICY rider_select_rider
ON rider FOR SELECT TO app_rider
USING (id_rider = current_setting('app.current_rider_id', true)::BIGINT);
 
-- El rider solo puede actualizar su propio perfil
CREATE POLICY rider_update_rider
ON rider FOR UPDATE TO app_rider
USING     (id_rider = current_setting('app.current_rider_id', true)::BIGINT)
WITH CHECK (id_rider = current_setting('app.current_rider_id', true)::BIGINT);
 
-- El rider solo ve sus propios viajes
CREATE POLICY rider_select_viaje
ON viaje FOR SELECT TO app_rider
USING (id_rider = current_setting('app.current_rider_id', true)::BIGINT);
 
-- Al insertar un viaje, el rider_id debe coincidir con el suyo
CREATE POLICY rider_insert_viaje
ON viaje FOR INSERT TO app_rider
WITH CHECK (id_rider = current_setting('app.current_rider_id', true)::BIGINT);
 
-- El rider solo puede actualizar sus propios viajes (p.ej. cancelar)
CREATE POLICY rider_update_viaje
ON viaje FOR UPDATE TO app_rider
USING     (id_rider = current_setting('app.current_rider_id', true)::BIGINT)
WITH CHECK (id_rider = current_setting('app.current_rider_id', true)::BIGINT);
 
-- El rider solo ve los pagos de sus propios viajes
CREATE POLICY rider_select_pago
ON pago FOR SELECT TO app_rider
USING (
    EXISTS (
        SELECT 1 FROM viaje v
        WHERE v.id_viaje = pago.id_viaje
          AND v.id_rider = current_setting('app.current_rider_id', true)::BIGINT
    )
);
 
 
-- ROW LEVEL SECURITY (CONDUCTOR): el conductor solo puede ver y gestionar sus propios viajes, ofertas y vehículo
ALTER TABLE conductor ENABLE ROW LEVEL SECURITY;
ALTER TABLE oferta    ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculo  ENABLE ROW LEVEL SECURITY;
 
-- El conductor solo ve su propio perfil
CREATE POLICY conductor_select_conductor
ON conductor FOR SELECT TO app_conductor
USING (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT);
 
-- El conductor solo puede actualizar su propio perfil
CREATE POLICY conductor_update_conductor
ON conductor FOR UPDATE TO app_conductor
USING     (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT)
WITH CHECK (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT);
 
-- El conductor ve sus viajes asignados Y los viajes en estado
-- 'solicitado' (para poder ver viajes disponibles y aceptar ofertas)
CREATE POLICY conductor_select_viaje
ON viaje FOR SELECT TO app_conductor
USING (
    id_conductor = current_setting('app.current_conductor_id', true)::BIGINT
    OR estado_viaje = 'solicitado'
);
 
-- El conductor solo ve las ofertas que le han enviado a él
CREATE POLICY conductor_select_oferta
ON oferta FOR SELECT TO app_conductor
USING (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT);
 
-- El conductor solo puede actualizar sus propias ofertas (aceptar/rechazar)
CREATE POLICY conductor_update_oferta
ON oferta FOR UPDATE TO app_conductor
USING     (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT)
WITH CHECK (id_conductor = current_setting('app.current_conductor_id', true)::BIGINT);
 
-- El conductor solo ve su propio vehículo
CREATE POLICY conductor_select_vehiculo
ON vehiculo FOR SELECT TO app_conductor
USING (
    EXISTS (
        SELECT 1 FROM conductor c
        WHERE c.id_vehiculo = vehiculo.id_vehiculo
          AND c.id_conductor = current_setting('app.current_conductor_id', true)::BIGINT
    )
);
 
-- El conductor solo ve los pagos de sus propios viajes
CREATE POLICY conductor_select_pago
ON pago FOR SELECT TO app_conductor
USING (
    EXISTS (
        SELECT 1 FROM viaje v
        WHERE v.id_viaje = pago.id_viaje
          AND v.id_conductor = current_setting('app.current_conductor_id', true)::BIGINT
    )
);
 
 
-- ROW LEVEL SECURITY (BACKEND) El backend tiene acceso completo a todas las tablas para ejecutar transacciones. USING (true) significa "sin restricción de filas".
-- El servidor de negocio necesita acceso completo a todas
-- las tablas para ejecutar transacciones. USING (true) significa
-- "sin restricción de filas".
CREATE POLICY backend_all_rider        ON rider                   FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_conductor    ON conductor               FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_viaje        ON viaje                   FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_oferta       ON oferta                  FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_vehiculo     ON vehiculo                FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_company      ON company                 FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_pago         ON pago                    FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_hist_viaje   ON historial_estado_viaje  FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_hist_oferta  ON historial_estado_oferta FOR ALL TO app_backend USING (true) WITH CHECK (true);
CREATE POLICY backend_all_auditoria    ON auditoria_operaciones   FOR ALL TO app_backend USING (true) WITH CHECK (true);
 
-- El backend necesita permisos explícitos sobre todas las tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_backend;
 
 
-- ANALISTA — solo lectura, sin datos personales
-- El analista accede a métricas y operativa, pero NO debe ver
-- emails, teléfonos ni contraseñas de riders ni conductores.
-- Por eso NO tiene GRANT directo sobre rider ni conductor:
-- solo accede a través de las vistas definidas abajo.
GRANT SELECT ON viaje, oferta, vehiculo, company, pago,
    historial_estado_viaje, historial_estado_oferta, auditoria_operaciones
TO analista;
-- rider y conductor: acceso solo a través de vistas (sin datos de contacto)
 
 
-- Vista de viajes con empresa, sin datos personales del rider
CREATE OR REPLACE VIEW vista_analista_viajes AS
SELECT
    v.id_viaje,
    v.id_rider,
    v.id_conductor,
    v.origen_lat,
    v.origen_lon,
    v.origen_direccion,
    v.destino_lat,
    v.destino_lon,
    v.destino_direccion,
    v.estado_viaje,
    v.distancia_km,
    v.duracion_min,
    v.solicitud_viaje,
    v.inicio_viaje,
    v.fin_viaje,
    c.nom_conductor,
    c.ap_conductor,
    co.nom_company
FROM viaje v
LEFT JOIN conductor c  ON v.id_conductor = c.id_conductor
LEFT JOIN company   co ON c.id_company   = co.id_company;
 
-- Vista de conductores SIN email ni teléfono
CREATE OR REPLACE VIEW vista_analista_conductores AS
SELECT
    c.id_conductor,
    c.nom_conductor,
    c.ap_conductor,
    co.nom_company,
    ve.marca,
    ve.modelo,
    ve.color,
    ve.anio
FROM conductor c
JOIN company  co ON c.id_company   = co.id_company
LEFT JOIN vehiculo ve ON c.id_vehiculo = ve.id_vehiculo;
 
-- Vista de tasa de aceptación por conductor (para métricas de negocio)
CREATE OR REPLACE VIEW v_tasa_aceptacion AS
SELECT
    c.id_conductor,
    c.nom_conductor,
    c.ap_conductor,
    co.nom_company,
    COUNT(o.id_oferta) AS ofertas_recibidas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada')  AS ofertas_aceptadas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'rechazada') AS ofertas_rechazadas,
    ROUND(
        100.0 * COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada')
        / NULLIF(COUNT(o.id_oferta), 0),
        2
    ) AS tasa_aceptacion_pct
FROM conductor c
JOIN company co ON c.id_company = co.id_company
LEFT JOIN oferta o ON c.id_conductor = o.id_conductor
GROUP BY c.id_conductor, c.nom_conductor, c.ap_conductor, co.nom_company;
 
GRANT SELECT ON vista_analista_viajes      TO analista;
GRANT SELECT ON vista_analista_conductores TO analista;
GRANT SELECT ON v_tasa_aceptacion          TO analista;
 
 
-- DBA — acceso total para mantenimiento y backups
-- No es SUPERUSER para limitar el impacto de un acceso no
-- autorizado, pero tiene todos los privilegios sobre la BD.
GRANT ALL PRIVILEGES ON DATABASE ride_hailing_db TO dba_role;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO dba_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dba_role;
 
 
-- FORCE ROW LEVEL SECURITY. Sin esto, el dueño de la tabla y los superusuarios saltan
-- las políticas RLS. Con FORCE RLS, nadie se las salta.
ALTER TABLE rider                   FORCE ROW LEVEL SECURITY;
ALTER TABLE conductor               FORCE ROW LEVEL SECURITY;
ALTER TABLE viaje                   FORCE ROW LEVEL SECURITY;
ALTER TABLE oferta                  FORCE ROW LEVEL SECURITY;
ALTER TABLE vehiculo                FORCE ROW LEVEL SECURITY;
ALTER TABLE pago                    FORCE ROW LEVEL SECURITY;
ALTER TABLE historial_estado_viaje  FORCE ROW LEVEL SECURITY;
ALTER TABLE historial_estado_oferta FORCE ROW LEVEL SECURITY;
ALTER TABLE auditoria_operaciones   FORCE ROW LEVEL SECURITY;
 