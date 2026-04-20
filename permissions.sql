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
