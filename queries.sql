-- REGISTRAMOS LOS NUEVOS CONDUCTORES
BEGIN;

INSERT INTO vehiculo (matricula, marca, modelo, color, anio)
VALUES ('1234XYZ', 'Toyota', 'Yaris', 'Blanco', 2022)
RETURNING id_vehiculo;  -- Capturamos el id para usarlo en el conductor

INSERT INTO conductor (id_company, id_vehiculo, nom_conductor, ap_conductor, tel_conductor, mail_conductor, hash_pass_conductor)
VALUES (
    1,                          -- Pertenece a Uber
    currval('vehiculo_id_vehiculo_seq'),  -- Id del vehículo recién insertado
    'Carmen', 'Villanueva', '600000021',
    'carmen.villanueva@example.com', crypt('pass_c11', gen_salt('bf'))
);

COMMIT;

-- SOLICITAR UN VIAJE Y ENVIAR OFERTAS A LOS CONDUCTORES (creamos el viaje y las ofertas juntos porque el viaje siempre tiene que tener una oferta)
BEGIN;
 
INSERT INTO viaje (
    id_rider,
    origen_lat, origen_lon, origen_direccion,
    destino_lat, destino_lon, destino_direccion,
    estado_viaje
)
VALUES (
    3,
    40.416775, -3.703790, 'Calle Mayor, 1',
    40.453210, -3.688900, 'Estadio Santiago Bernabéu',
    'solicitado'
);

INSERT INTO oferta (id_viaje, id_conductor, precio_oferta, estado_oferta) -- Enviamos la oferta a 3 conductores disponiblees
VALUES
    (currval('viaje_id_viaje_seq'), 2, 14.50, 'enviada'),
    (currval('viaje_id_viaje_seq'), 5, 14.50, 'enviada'),
    (currval('viaje_id_viaje_seq'), 8, 14.50, 'enviada');
 
COMMIT;

-- ACTUALIZAMOS EL TELÉFONO DE UN RIDER
UPDATE rider
SET tel_rider = '611000001'
WHERE mail_rider = 'ana.perez@example.com';

-- ACTUALIZAMOS EL VEHÍCULO DE UN CONDUCTOR
UPDATE conductor
SET id_vehiculo = 3
WHERE mail_conductor = 'juan.gomez@example.com';

-- CANCELAMOS VIAJE QUE LLEVA MUCHO RATO EN SOLICITADO
UPDATE viaje
SET estado_viaje = 'cancelado'
WHERE estado_viaje = 'solicitado'
  AND solicitud_viaje < NOW() - INTERVAL '10 minutes'
  AND id_conductor IS NULL;

-- ELIMINAMOS UN RIDER QUE NUNCA HA REALIZADO UN VIAJE
DELETE FROM rider
WHERE id_rider NOT IN (
    SELECT DISTINCT id_rider FROM viaje
)
AND mail_rider = 'test.borrar@example.com';

-- ACEPTAR UNA OFERTA
BEGIN;

SELECT id_oferta, id_viaje, id_conductor, estado_oferta
FROM oferta
WHERE id_oferta = 14  -- Oferta que el conductor quiere aceptar
  AND estado_oferta = 'enviada'
FOR UPDATE; -- SELECT FOR UPDATE para evitar que dos conductores acepten a la vez (la bloqueamos)

UPDATE oferta
SET estado_oferta = 'aceptada', -- Marcamos la oferta como aceptada
    respuesta_oferta = NOW()
WHERE id_oferta = 14;

UPDATE viaje
SET id_conductor = (SELECT id_conductor FROM oferta WHERE id_oferta = 14), -- Asignamos un conductor
    estado_viaje = 'aceptado' -- Ponemos la oferta como aceptada
WHERE id_viaje = (SELECT id_viaje FROM oferta WHERE id_oferta = 14)
  AND estado_viaje = 'solicitado';  -- Solo si el viaje sigue disponible

UPDATE oferta
SET estado_oferta = 'rechazada', -- Rechazamos el resto de ofertas del viaje
    respuesta_oferta = NOW()
WHERE id_viaje = (SELECT id_viaje FROM oferta WHERE id_oferta = 14)
  AND id_oferta <> 14 -- id_oferta es distinto de 14 así que mostramos el resto de ofertas
  AND estado_oferta = 'enviada';
 
COMMIT;

-- INICIAMOS VIAJE (de aceptado a en curso)
BEGIN;
 
UPDATE viaje
SET estado_viaje = 'en curso',
    inicio_viaje = NOW() -- Cogemos la fecha de inicio 
WHERE id_viaje = 4
  AND estado_viaje = 'aceptado';
 
COMMIT;

-- FINALIZAMOS VIAJE Y REGISTRAMOS EL PAGO
BEGIN;
 
UPDATE viaje
SET estado_viaje = 'finalizado',
    fin_viaje    = NOW(),
    distancia_km = 8.3,
    duracion_min = 22
WHERE id_viaje = 4
  AND estado_viaje = 'en curso';
 
INSERT INTO pago (id_viaje, id_oferta, importe_pago, comision_company, estado_pago, metodo_pago)
VALUES (
    4,
    (SELECT id_oferta FROM oferta WHERE id_viaje = 4 AND estado_oferta = 'aceptada'),
    18.50,
    1.85,
    'completado',
    'tarjeta'
); -- Al finalizzar el viaje cambiamos los detalles del cobro
 
COMMIT;

-- VEMOS LOS VIAJES DE UN RIDER CON EL CONDCUTOR Y EL ESTADO
SELECT
    v.id_viaje,
    v.solicitud_viaje,
    v.origen_direccion,
    v.destino_direccion,
    v.estado_viaje,
    v.distancia_km,
    v.duracion_min,
    c.nom_conductor || ' ' || c.ap_conductor AS conductor, -- Metemos un esapcio para separar
    co.nom_company                            AS empresa
FROM viaje v
LEFT JOIN conductor c  ON v.id_conductor = c.id_conductor -- Unimos la tabla de viajes con la de conductores 
LEFT JOIN company  co  ON c.id_company   = co.id_company -- Unimos al conductor con su empresa
WHERE v.id_rider = 1
ORDER BY v.solicitud_viaje DESC;

-- VER LAS OFERTAS CON EL CONDUCTOR Y SU EMPRESA
SELECT
    o.id_oferta,
    o.precio_oferta,
    o.estado_oferta,
    o.envio_oferta,
    o.respuesta_oferta,
    c.nom_conductor || ' ' || c.ap_conductor AS conductor,
    co.nom_company                            AS empresa
FROM oferta o
JOIN conductor c ON o.id_conductor = c.id_conductor -- JOIN para solo enseñar los resultados si hay información en todas las tablas (oferta, conductor y empresa)
JOIN company  co ON c.id_company   = co.id_company
WHERE o.id_viaje = 1
ORDER BY o.envio_oferta;

-- HISTORIAL DE ESTADOS DE UN VIAJE
SELECT
    h.fecha_cambio,
    h.estado_anterior,
    h.estado_nuevo,
    h.usuario_bd
FROM historial_estado_viaje h
WHERE h.id_viaje = 1
ORDER BY h.fecha_cambio;

-- VIAJES ACTIVOS CON CONDUCTOR ASIGNADO
SELECT
    v.id_viaje,
    v.estado_viaje,
    v.origen_direccion,
    v.destino_direccion,
    r.nom_rider  || ' ' || r.ap_rider   AS rider,
    c.nom_conductor || ' ' || c.ap_conductor AS conductor,
    ve.matricula,
    co.nom_company AS empresa
FROM viaje v
JOIN rider     r  ON v.id_rider     = r.id_rider
JOIN conductor c  ON v.id_conductor = c.id_conductor
JOIN vehiculo  ve ON c.id_vehiculo  = ve.id_vehiculo
JOIN company   co ON c.id_company   = co.id_company
WHERE v.estado_viaje IN ('aceptado', 'en curso')
ORDER BY v.solicitud_viaje;

-- PAGOS REALIZADOS Y CONDUCTOR QUE LO COBRÓ
SELECT
    p.id_pago,
    p.importe_pago,
    p.comision_company,
    p.metodo_pago,
    p.estado_pago,
    v.origen_direccion,
    v.destino_direccion,
    v.distancia_km,
    v.duracion_min,
    c.nom_conductor || ' ' || c.ap_conductor AS conductor,
    co.nom_company                            AS empresa
FROM pago p
JOIN viaje     v  ON p.id_viaje     = v.id_viaje
JOIN oferta    o  ON p.id_oferta    = o.id_oferta
JOIN conductor c  ON o.id_conductor = c.id_conductor
JOIN company   co ON c.id_company   = co.id_company
WHERE p.estado_pago = 'completado'
ORDER BY v.fin_viaje DESC;

-- VERIFICACIÓN DE LOGIN
SELECT id_rider, nom_rider FROM rider
WHERE mail_rider = 'ana.perez@example.com'
  AND hash_pass_rider = crypt('password1', hash_pass_rider);
SELECT id_conductor, nom_conductor FROM conductor
WHERE mail_conductor = 'juan.gomez@example.com'
  AND hash_pass_conductor = crypt('pass_c1', hash_pass_conductor);
UPDATE rider SET hash_pass_rider = crypt('nueva_password', gen_salt('bf'))
WHERE mail_rider = 'ana.perez@example.com';

-- Verificación usuarios y permisos

-- Usuarios creados y son superusuarios (deben ser false)
SELECT usename, usesuper 
FROM pg_user
WHERE usename LIKE 'usr_%';

-- Roles asignados a cada usuario
SELECT r.rolname AS usuario, m.rolname AS rol_asignado
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.member
JOIN pg_roles m ON am.roleid = m.oid
WHERE r.rolname LIKE 'usr_%'
ORDER BY r.rolname;

-- Permisos de cada rol sobre las tablas
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('app_rider', 'app_conductor', 'app_backend', 'analista', 'dba_role')
ORDER BY grantee, table_name;

-- Verificar que el analista NO tiene acceso a datos personales (ejemplo con la tabla conductor)
SET ROLE usr_analista;
SELECT * FROM rider; -- Debería dar error por falta de permisos
SELECT * FROM conductor; -- Debería dar error por falta de permisos
RESET ROLE;

-- Verificar que el analista tiene acceso a la vista sin datos personales
SET ROLE usr_analista;
SELECT * FROM vista_analista_conductores; -- Debería mostrar datos de conductores sin datos personales
RESET ROLE;