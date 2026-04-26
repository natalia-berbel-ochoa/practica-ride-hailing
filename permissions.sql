-- LIMPIEZA PREVIA
-- Borramos usuarios y roles si ya existen para evitar errores al ejecutar el script varias veces
-- Primero borramos los usuarios, luego los roles para evitar conflictos de dependencias
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

-- ROLES
-- Un rol es un conjunto de permisos que se pueden asignar a uno o más usuarios. Facilita la gestión de permisos al agruparlos por función o responsabilidad dentro de la organización.
-- No tiene login propio, es decir, no puede iniciar sesión directamente, sino que se asigna a usuarios que sí pueden iniciar sesión. 
-- Esto permite una administración más eficiente de los permisos, ya que al modificar un rol se actualizan automáticamente los permisos de todos los usuarios que lo tienen asignado.
CREATE ROLE app_rider; -- app móvil del rider
CREATE ROLE app_conductor; -- app móvil del conductor
CREATE ROLE app_backend; -- servidor de negocio (backend)
CREATE ROLE analista; -- analista de datos (solo lectura, sin acceso a datos personales)
CREATE ROLE dba_role; -- administrador de base de datos (DBA) con acceso total, necesario para mantenimiento, backups y gestión del esquema

-- PERMISOS POR ROL 
-- Asignamos a cada rol solo los permisos necesarios

-- Para el rider (usuario de la app móvil del rider):
GRANT SELECT, INSERT ON viaje TO app_rider; -- Puede solicitar viajes
GRANT SELECT ON oferta TO app_rider; -- Puede ver sus viajes y ofertas
GRANT SELECT, UPDATE ON rider TO app_rider; -- Puede ver y actualizar su perfil. El filtrado por rider concreto se aplica en la capa de aplicación

-- Para el conductor (usuario de la app móvil del conductor):
GRANT SELECT, UPDATE ON oferta TO app_conductor; -- Puede ver y responder ofertas
GRANT SELECT, UPDATE ON viaje TO app_conductor; -- Puede ver viajes disponibles y los suyos
GRANT SELECT, UPDATE ON conductor TO app_conductor; -- Puede ver y actualizar su perfil. El filtrado por conductor concreto se aplica en la capa de aplicación

-- Para el backend (servidor de negocio):
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_backend; -- Puede realizar todas las operaciones en todas las tablas del esquema público

-- Para el analista de datos (solo lectura, sin acceso a datos personales):
GRANT SELECT ON viaje, oferta, pago, company, vehiculo TO analista; -- Puede consultar datos de viajes, ofertas, pagos, empresas y vehículos, pero no puede acceder a datos personales de riders o conductores

-- Para el DBA (administrador de base de datos):
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dba_role; -- Necesita acceso total para mantenimiento, backups y gestión del esquema

-- Permisos de secuencias
-- Necesario para que los INSERT funcionen con columnas BIGSERIAL
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_rider, app_conductor, app_backend;


-- USUARIOS
-- Cada usuario tiene una contraseña y se le asigna a uno o más roles según su función en la organización.
-- IMPORTANTE: cambiar las contraseñas antes de usar en producción.
CREATE USER usr_rider     WITH PASSWORD 'rider_CHANGE_ME'     IN ROLE app_rider;
CREATE USER usr_conductor WITH PASSWORD 'conductor_CHANGE_ME' IN ROLE app_conductor;
CREATE USER usr_backend   WITH PASSWORD 'backend_CHANGE_ME'   IN ROLE app_backend;
CREATE USER usr_analista  WITH PASSWORD 'analista_CHANGE_ME'  IN ROLE analista;
CREATE USER usr_dba       WITH PASSWORD 'dba_CHANGE_ME'       IN ROLE dba_role;

-- VISTA PARA EL ANALISTA
-- El analista necesita datos de conductores para sus análisis, pero no debe tener acceso a datos personales. 
-- Creamos una vista que solo incluya la información necesaria para el análisis, sin datos personales como email o teléfono.
CREATE VIEW vista_analista_conductores AS
SELECT 
    c.id_conductor, 
    c.nom_conductor, 
    c.ap_conductor, 
    comp.nom_company, 
    v.marca, 
    v.modelo
    -- Sin tel_conductor, mail_conductor, pass_conductor
FROM conductor c
JOIN company comp ON c.id_company = comp.id_company
JOIN vehiculo v ON c.id_vehiculo = v.id_vehiculo;

-- Le damos acceso al analista solo sobre esta vista, no sobre la tabla
GRANT SELECT ON vista_analista_conductores TO analista;
