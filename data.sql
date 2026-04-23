-- 1. RIDER

-- Las contraseñas se almacenan como hashes bcrypt generados con pgcrypto.
-- crypt('texto_plano', gen_salt('bf')) produce un hash distinto cada vez (salt aleatorio incluido).
-- La contraseña original NUNCA se guarda. Para verificar: crypt(input_usuario, hash) = hash.
INSERT INTO rider (nom_rider, ap_rider, mail_rider, tel_rider, hash_pass_rider) VALUES
('Ana', 'Pérez', 'ana.perez@example.com', '600000001', crypt('password1', gen_salt('bf'))),
('Luis', 'García', 'luis.garcia@example.com', '600000002', crypt('password2', gen_salt('bf'))),
('Marta', 'López', 'marta.lopez@example.com', '600000003', crypt('password3', gen_salt('bf'))),
('Javier', 'Ruiz', 'javier.ruiz@example.com', '600000004', crypt('password4', gen_salt('bf'))),
('Lucía', 'Torres', 'lucia.torres@example.com', '600000005', crypt('password5', gen_salt('bf'))),
('Pablo', 'Martín', 'pablo.martin@example.com', '600000006', crypt('password6', gen_salt('bf'))),
('Elena', 'Sánchez', 'elena.sanchez@example.com', '600000007', crypt('password7', gen_salt('bf'))),
('Diego', 'Romero', 'diego.romero@example.com', '600000008', crypt('password8', gen_salt('bf'))),
('Carlos', 'Díaz', 'carlos.diaz@example.com', '600000009', crypt('password9', gen_salt('bf'))),
('Sofía', 'Fernández', 'sofia.fernandez@example.com', '600000010', crypt('password10', gen_salt('bf'))),
('Sergio', 'Moreno', 'sergio.moreno@example.com', '600000011', crypt('password11', gen_salt('bf'))),
('Raúl', 'Navarro', 'raul.navarro@example.com', '600000012', crypt('password12', gen_salt('bf'))),
('Adrián', 'Vega', 'adrian.vega@example.com', '600000013', crypt('password13', gen_salt('bf'))),
('María', 'Gómez', 'maria.gomez@example.com', '600000014', crypt('password14', gen_salt('bf'))),
('Daniel', 'Castro', 'daniel.castro@example.com', '600000015', crypt('password15', gen_salt('bf'))),
('Rubén', 'Ortiz', 'ruben.ortiz@example.com', '600000016', crypt('password16', gen_salt('bf'))),
('Iván', 'Herrera', 'ivan.herrera@example.com', '600000017', crypt('password17', gen_salt('bf'))),
('Álvaro', 'Molina', 'alvaro.molina@example.com', '600000018', crypt('password18', gen_salt('bf'))),
('David', 'Gil', 'david.gil@example.com', '600000019', crypt('password19', gen_salt('bf'))),
('Óscar', 'León', 'oscar.leon@example.com', '600000020', crypt('password20', gen_salt('bf')));


-- 2. EMPRESAS 

INSERT INTO company (nom_company, cif_company) VALUES
('Uber', 'A10000001'),  -- id_company = 1
('Bolt', 'A10000002'),  -- id_company = 2
('Lyft', 'A10000003');  -- id_company = 3

-- 3. VEHICULOS

INSERT INTO vehiculo (matricula, marca, modelo, color, anio) VALUES
('1111ABC', 'Toyota', 'Corolla', 'Blanco', 2021),  -- id_vehiculo = 1
('2222BCD', 'Seat', 'León', 'Negro', 2020),  -- id_vehiculo = 2
('3333CDE', 'Hyundai', 'i30', 'Gris', 2022),  -- id_vehiculo = 3
('4444DEF', 'Kia', 'Ceed', 'Azul', 2021),  -- id_vehiculo = 4
('5555EFG', 'Renault', 'Megane', 'Rojo', 2019),  -- id_vehiculo = 5
('6666FGH', 'Volkswagen', 'Golf', 'Blanco', 2023),  -- id_vehiculo = 6
('7777GHI', 'Peugeot', '308', 'Negro', 2020),  -- id_vehiculo = 7
('8888HIJ', 'Skoda', 'Octavia', 'Gris', 2021),  -- id_vehiculo = 8
('9999IJK', 'Ford', 'Focus', 'Azul', 2018),  -- id_vehiculo = 9
('1010JKL', 'Opel', 'Astra', 'Plata', 2022);  -- id_vehiculo = 10


-- 4. CONDUCTORES los usuarios 9 al 18 son conductores

INSERT INTO conductor (id_company, id_vehiculo, nom_conductor, ap_conductor, tel_conductor, mail_conductor, hash_pass_conductor) VALUES
(1, 1, 'Juan', 'Gómez', '600000001', 'juan.gomez@example.com', crypt('pass_c1', gen_salt('bf'))),
(1, 2, 'María', 'López', '600000002', 'maria.lopez@example.com', crypt('pass_c2', gen_salt('bf'))),
(1, 3, 'Pedro', 'Martínez', '600000003', 'pedro.martinez@example.com', crypt('pass_c3', gen_salt('bf'))),
(2, 4, 'Luisa', 'Pérez', '600000004', 'luisa.perez@example.com', crypt('pass_c4', gen_salt('bf'))),
(2, 5, 'Miguel', 'García', '600000005', 'miguel.garcia@example.com', crypt('pass_c5', gen_salt('bf'))),
(2, 6, 'Laura', 'Fernández', '600000006', 'laura.fernandez@example.com', crypt('pass_c6', gen_salt('bf'))),
(3, 7, 'Marta', 'Iglesias', '600000007', 'marta.iglesias@example.com', crypt('pass_c7', gen_salt('bf'))),
(3, 8, 'Diego', 'Gómez', '600000008', 'diego.gomez@example.com', crypt('pass_c8', gen_salt('bf'))),
(3, 9, 'Álvaro', 'Díaz', '600000009', 'alvaro.diaz@example.com', crypt('pass_c9', gen_salt('bf'))),
(1, 10, 'Sergio', 'Muñoz', '600000010', 'sergio.munoz@example.com', crypt('pass_c10', gen_salt('bf')));


-- 5. VIAJES

INSERT INTO viaje (
    id_rider,
    id_conductor,
    origen_lat,
    origen_lon,
    origen_direccion,
    destino_lat,
    destino_lon,
    destino_direccion,
    estado_viaje,
    distancia_km,
    duracion_min,
    solicitud_viaje,
    inicio_viaje,
    fin_viaje
) VALUES

-- Viaje 1: finalizado - rider 1, conductor 1
(1, 1, 40.416775, -3.703790, 'Calle Mayor, 1', 40.418880, -3.705550, 'Avenida de América, 10', 'finalizado', 5.5, 18, '2025-03-01 08:00:00', '2025-03-01 08:05:00', '2025-03-01 08:23:00'),

-- Viaje 2: finalizado - rider 2, conductor 2
(2, 2, 40.419990, -3.706660, 'Calle del Prado, 5', 40.421110, -3.707770, 'Plaza de España, 1', 'finalizado', 7.8, 8.0, '2025-03-01 09:10:00', '2025-03-01 09:11:00', '2025-03-01 09:36:00'),

-- Viaje 3: finalizado - rider 3, conductor 4
(3, 4, 40.422220, -3.708880, 'Avenida de América, 15', 40.423330, -3.709990, 'Calle del Prado, 10', 'finalizado', 12.0, 12.4, '2025-03-01 10:00:00', '2025-03-01 10:01:00', '2025-03-01 10:32:00'),

-- Viaje 4: en curso - rider 4, conductor 6
(4, 6, 40.424440, -3.710000, 'Plaza de España, 5', 40.425550, -3.711110, 'Calle Mayor, 5', 'en curso', NULL, NULL, '2025-03-01 11:00:00', NULL, NULL),

-- Viaje 5: aceptado - rider 5, conductor 7
(5, 7, 40.426660, -3.712220, 'Calle del Prado, 10', 40.427770, -3.713330, 'Avenida de América, 20', 'aceptado', NULL, NULL, '2025-03-01 12:00:00', NULL, NULL),

-- Viaje 6: solicitado - rider 6, sin conductor asignado
(6, NULL, 40.428880, -3.714440, 'Plaza de España, 10', 40.429990, -3.715550, 'Calle Mayor, 10', 'solicitado', NULL, NULL, '2025-03-01 12:30:00', NULL, NULL),

-- Viaje 7: cancelado - rider 7, sin conductor asignado
(7, NULL, 40.430000, -3.716660, 'Calle del Prado, 15', 40.431110, -3.717770, 'Avenida de América, 25', 'cancelado', NULL, NULL, '2025-03-01 13:00:00', NULL, NULL),

-- Viaje 8: finalizado - rider 8, conductor 3
(8, 3, 40.432220, -3.718880, 'Calle Mayor, 15', 40.433330, -3.719990, 'Avenida de América, 30', 'finalizado', 4.7, 4.9, '2025-03-01 14:00:00', '2025-03-01 14:02:00', '2025-03-01 14:05:00'),

-- Viaje 9: aceptado - rider 1, conductor 5
(1, 5, 40.434440, -3.721110, 'Plaza de España, 15', 40.435550, -3.722220, 'Calle del Prado, 20', 'aceptado', NULL, NULL, '2025-03-01 15:00:00', NULL, NULL),

-- Viaje 10: solicitado - rider 2, sin conductor asignado
(2, NULL, 40.436660, -3.723330, 'Avenida de América, 35', 40.437770, -3.724440, 'Calle Mayor, 20', 'solicitado', NULL, NULL, '2025-03-01 15:30:00', NULL, NULL);


-- 6. OFERTAS "La solicitud genera una oferta que se envía a múltiples conductores"
-- y "decisiones de aceptación/rechazo"

INSERT INTO oferta (
    id_viaje,
    id_conductor,
    precio_oferta,
    estado_oferta,
    envio_oferta,
    respuesta_oferta
) VALUES

-- Viaje 1
(1, 1, 13.20, 'aceptada',  '2025-03-01 08:02:00', '2025-03-01 08:03:00'),
(1, 2, 13.20, 'rechazada', '2025-03-01 08:03:00', '2025-03-01 08:04:00'),
(1, 3, 13.20, 'rechazada', '2025-03-01 08:04:00', '2025-03-01 08:05:00'),

-- Viaje 2
(2, 2, 16.90, 'aceptada', '2025-03-01 09:11:00', '2025-03-01 09:11:00'),
(2, 4, 16.90, 'rechazada', '2025-03-01 09:12:00', '2025-03-01 09:12:00'),
(2, 5, 16.90, 'rechazada', '2025-03-01 09:13:00', '2025-03-01 09:13:00'),

-- Viaje 3
(3, 4, 25.10, 'aceptada', '2025-03-01 10:01:00', '2025-03-01 10:01:00'),
(3, 6, 25.10, 'rechazada', '2025-03-01 10:02:00', '2025-03-01 10:02:00'),
(3, 7, 25.10, 'rechazada', '2025-03-01 10:03:00', '2025-03-01 10:03:00'),

-- Viaje 4
(4, 6, 18.50, 'aceptada', '2025-03-01 11:00:15', '2025-03-01 11:00:15'),
(4, 8, 18.50, 'rechazada', '2025-03-01 11:00:15', '2025-03-01 11:00:15'),

-- Viaje 5
(5, 7, 20.00, 'aceptada', '2025-03-01 12:04:00', '2025-03-01 12:04:00'),
(5, 8, 20.00, 'rechazada', '2025-03-01 12:05:00', '2025-03-01 12:05:00'),
(5, 10, 20.00, 'enviada', '2025-03-01 12:06:00', NULL),

-- Viaje 6
(6, 1, 15.00, 'enviada', '2025-03-01 12:30:10', NULL),
(6, 3, 15.00, 'enviada', '2025-03-01 12:30:10', NULL),
(6, 9, 15.00, 'enviada', '2025-03-01 12:30:10', NULL),

-- Viaje 7
(7, 2, 15.00, 'rechazada', '2025-03-01 13:00:10', '2025-03-01 13:05:00'),
(7, 4, 15.00, 'enviada', '2025-03-01 13:00:10', NULL),

-- Viaje 8
(8, 3, 11.40, 'aceptada', '2025-03-01 14:00:15', '2025-03-01 14:02:00'),
(8, 5, 11.40, 'rechazada', '2025-03-01 14:00:15', '2025-03-01 14:03:00'),

-- Viaje 9
(9, 5, 15.00, 'aceptada', '2025-03-01 15:00:10', '2025-03-01 15:01:00'),
(9, 6, 15.00, 'rechazada', '2025-03-01 15:00:10', '2025-03-01 15:02:00'),

-- Viaje 10
(10, 2, 15.00, 'enviada', '2025-03-01 15:30:10', NULL),
(10, 7, 15.00, 'enviada', '2025-03-01 15:30:10', NULL),
(10, 8, 15.00, 'enviada', '2025-03-01 15:30:10', NULL);


-- 7. PAGOS (solo para viajes finalizados)

INSERT INTO pago (id_viaje, id_oferta, importe_pago, comision_company, estado_pago, metodo_pago) VALUES
(1, 1, 13.20, 1.32, 'completado', 'tarjeta'),
(2, 4, 16.90, 1.69, 'completado', 'efectivo'),
(3, 7, 25.10, 2.51, 'completado', 'tarjeta'),
(8, 20, 11.40, 1.14, 'completado', 'tarjeta'),
(9, 25, 15.00, 1.50, 'pendiente', 'efectivo'); -- El pago aún no se ha completado porque el viaje acaba de ser aceptado por el conductor 5
-- (10, NULL, NULL, NULL, 'pendiente', NULL), -- No se ha generado porque el viaje aún no ha sido aceptado por ningún conductor
-- Pago fallido en el viaje 5, que aunque ha sido aceptado por el conductor 7, el pago no se ha completado
-- (5, 11, 20.00, 2.00, 'fallido', NULL),
-- Pago reembolsado en el viaje 4, que aunque ha sido aceptado por el conductor 6, el viaje ha sido cancelado posteriormente
-- (4, 10, 18.50, 1.85, 'reembolsado', NULL);

-- COMENTO ESO POR QUE DA ERROR. Ya que el campo de "forma de pago" no puede ser null y ahí lo estabas poniendo y no me compilaba el data.sql
-- También he borrado lo de encima de metodos de pago porque se repetia con lo que ya había puesto en el schema.sql y me daba error.

