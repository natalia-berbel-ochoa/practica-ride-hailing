-- 1. USUARIOS corresponde al enunciado: "Usuarios (rider y conductores) y sus perfiles"

INSERT INTO usuarios (nombre_completo, email, telefono, rol) VALUES
('Ana Pérez', 'ana.perez@example.com', '600000001', 'pasajero'),
('Luis García', 'luis.garcia@example.com', '600000002', 'pasajero'),
('Marta López', 'marta.lopez@example.com', '600000003', 'pasajero'),
('Javier Ruiz', 'javier.ruiz@example.com', '600000004', 'pasajero'),
('Lucía Torres', 'lucia.torres@example.com', '600000005', 'pasajero'),
('Pablo Martín', 'pablo.martin@example.com', '600000006', 'pasajero'),
('Elena Sánchez', 'elena.sanchez@example.com', '600000007', 'pasajero'),
('Diego Romero', 'diego.romero@example.com', '600000008', 'pasajero'),

('Carlos Díaz', 'carlos.diaz@example.com', '600000101', 'conductor'),
('Sergio Moreno', 'sergio.moreno@example.com', '600000102', 'conductor'),
('Raúl Navarro', 'raul.navarro@example.com', '600000103', 'conductor'),
('Adrián Vega', 'adrian.vega@example.com', '600000104', 'conductor'),
('Daniel Castro', 'daniel.castro@example.com', '600000105', 'conductor'),
('Rubén Ortiz', 'ruben.ortiz@example.com', '600000106', 'conductor'),
('Iván Herrera', 'ivan.herrera@example.com', '600000107', 'conductor'),
('Álvaro Molina', 'alvaro.molina@example.com', '600000108', 'conductor'),
('David Gil', 'david.gil@example.com', '600000109', 'conductor'),
('Óscar León', 'oscar.leon@example.com', '600000110', 'conductor');


-- 2. PASAJEROS Los usuarios 1 al 8 son pasajeros

INSERT INTO pasajeros (id_usuario, valoracion) VALUES
(1, 4.8),
(2, 4.6),
(3, 4.9),
(4, 4.7),
(5, 5.0),
(6, 4.5),
(7, 4.9),
(8, 4.4);


-- 3. EMPRESAS 

INSERT INTO empresas (nombre, cif, pais) VALUES
('MoveNow', 'A10000001', 'España'),
('QuickRide', 'A10000002', 'España'),
('UrbanGo', 'A10000003', 'España');


-- 4. CONDUCTORES los usuarios 9 al 18 son conductores

INSERT INTO conductores (id_usuario, id_empresa, numero_licencia, valoracion, disponible) VALUES
(9,  1, 'LIC-0001', 4.9, TRUE),
(10, 1, 'LIC-0002', 4.7, TRUE),
(11, 1, 'LIC-0003', 4.8, TRUE),
(12, 2, 'LIC-0004', 4.6, TRUE),
(13, 2, 'LIC-0005', 4.5, TRUE),
(14, 2, 'LIC-0006', 4.9, TRUE),
(15, 3, 'LIC-0007', 4.8, TRUE),
(16, 3, 'LIC-0008', 4.7, TRUE),
(17, 3, 'LIC-0009', 4.6, FALSE),
(18, 1, 'LIC-0010', 4.4, TRUE);


-- 5. VEHICULOS

INSERT INTO vehiculos (id_conductor, matricula, marca, modelo, color, anio, plazas, activo) VALUES
(1, '1111ABC', 'Toyota', 'Corolla', 'Blanco', 2021, 4, TRUE),
(2, '2222BCD', 'Seat', 'León', 'Negro', 2020, 4, TRUE),
(3, '3333CDE', 'Hyundai', 'i30', 'Gris', 2022, 4, TRUE),
(4, '4444DEF', 'Kia', 'Ceed', 'Azul', 2021, 4, TRUE),
(5, '5555EFG', 'Renault', 'Megane', 'Rojo', 2019, 4, TRUE),
(6, '6666FGH', 'Volkswagen', 'Golf', 'Blanco', 2023, 4, TRUE),
(7, '7777GHI', 'Peugeot', '308', 'Negro', 2020, 4, TRUE),
(8, '8888HIJ', 'Skoda', 'Octavia', 'Gris', 2021, 4, TRUE),
(9, '9999IJK', 'Ford', 'Focus', 'Azul', 2018, 4, TRUE),
(10, '1010JKL', 'Opel', 'Astra', 'Plata', 2022, 4, TRUE);


-- 6. UBICACIONES

INSERT INTO ubicaciones (direccion_texto, latitud, longitud, ciudad, pais) VALUES
('Puerta del Sol, Madrid', 40.416775, -3.703790, 'Madrid', 'España'),
('Plaza Mayor, Madrid', 40.415363, -3.707398, 'Madrid', 'España'),
('Atocha, Madrid', 40.406586, -3.689402, 'Madrid', 'España'),
('Chamartín, Madrid', 40.472267, -3.682564, 'Madrid', 'España'),
('Gran Vía, Madrid', 40.420300, -3.705800, 'Madrid', 'España'),
('Cibeles, Madrid', 40.419258, -3.693564, 'Madrid', 'España'),
('Moncloa, Madrid', 40.434242, -3.717031, 'Madrid', 'España'),
('Nuevos Ministerios, Madrid', 40.446176, -3.692489, 'Madrid', 'España'),
('IFEMA, Madrid', 40.463667, -3.616000, 'Madrid', 'España'),
('Barajas T4, Madrid', 40.491878, -3.593522, 'Madrid', 'España'),
('Callao, Madrid', 40.420028, -3.705759, 'Madrid', 'España'),
('Príncipe Pío, Madrid', 40.421247, -3.720727, 'Madrid', 'España');


-- 7. VIAJES

INSERT INTO viajes (
    id_pasajero,
    id_conductor_asignado,
    id_ubicacion_origen,
    id_ubicacion_destino,
    fecha_solicitud,
    fecha_aceptacion,
    fecha_inicio,
    fecha_fin,
    fecha_cancelacion,
    estado,
    km_estimados,
    km_reales,
    minutos_estimados,
    minutos_reales,
    precio_estimado,
    precio_final
) VALUES

-- Viaje 1: finalizado
(1, 1, 1, 3, '2025-03-01 08:00:00', '2025-03-01 08:02:00', '2025-03-01 08:05:00', '2025-03-01 08:23:00', NULL, 'finalizado', 5.2, 5.5, 15, 18, 12.50, 13.20),

-- Viaje 2: finalizado
(2, 2, 2, 4, '2025-03-01 09:10:00', '2025-03-01 09:11:00', '2025-03-01 09:15:00', '2025-03-01 09:36:00', NULL, 'finalizado', 7.8, 8.0, 20, 21, 16.40, 16.90),

-- Viaje 3: finalizado
(3, 4, 5, 10, '2025-03-01 10:00:00', '2025-03-01 10:01:00', '2025-03-01 10:05:00', '2025-03-01 10:32:00', NULL, 'finalizado', 12.0, 12.4, 25, 27, 24.00, 25.10),

-- Viaje 4: en curso
(4, 6, 7, 9, '2025-03-01 11:00:00', '2025-03-01 11:03:00', '2025-03-01 11:08:00', NULL, NULL, 'en_curso', 9.5, NULL, 22, NULL, 18.50, NULL),

-- Viaje 5: aceptado
(5, 7, 6, 8, '2025-03-01 12:00:00', '2025-03-01 12:04:00', NULL, NULL, NULL, 'aceptado', 4.3, NULL, 12, NULL, 9.80, NULL),

-- Viaje 6: solicitado
(6, NULL, 3, 5, '2025-03-01 12:30:00', NULL, NULL, NULL, NULL, 'solicitado', 3.9, NULL, 10, NULL, 8.70, NULL),

-- Viaje 7: cancelado
(7, NULL, 8, 11, '2025-03-01 13:00:00', NULL, NULL, NULL, '2025-03-01 13:08:00', 'cancelado', 2.8, NULL, 8, NULL, 6.50, NULL),

-- Viaje 8: finalizado
(8, 3, 12, 1, '2025-03-01 14:00:00', '2025-03-01 14:02:00', '2025-03-01 14:05:00', '2025-03-01 14:20:00', NULL, 'finalizado', 4.7, 4.9, 14, 15, 10.90, 11.40),

-- Viaje 9: aceptado
(1, 5, 10, 2, '2025-03-01 15:00:00', '2025-03-01 15:01:00', NULL, NULL, NULL, 'aceptado', 11.5, NULL, 24, NULL, 22.80, NULL),

-- Viaje 10: solicitado
(2, NULL, 11, 6, '2025-03-01 15:30:00', NULL, NULL, NULL, NULL, 'solicitado', 6.1, NULL, 16, NULL, 13.10, NULL);


-- 8. OFERTAS_VIAJE "La solicitud genera una oferta que se envía a múltiples conductores"
-- y "decisiones de aceptación/rechazo"

INSERT INTO ofertas_viaje (
    id_viaje,
    id_conductor,
    fecha_envio,
    fecha_respuesta,
    estado
) VALUES

-- Viaje 1
(1, 1, '2025-03-01 08:00:30', '2025-03-01 08:02:00', 'aceptada'),
(1, 2, '2025-03-01 08:00:30', '2025-03-01 08:03:00', 'rechazada'),
(1, 3, '2025-03-01 08:00:30', '2025-03-01 08:04:00', 'rechazada'),

-- Viaje 2
(2, 2, '2025-03-01 09:10:20', '2025-03-01 09:11:00', 'aceptada'),
(2, 4, '2025-03-01 09:10:20', '2025-03-01 09:12:00', 'rechazada'),
(2, 5, '2025-03-01 09:10:20', '2025-03-01 09:13:00', 'rechazada'),

-- Viaje 3
(3, 4, '2025-03-01 10:00:10', '2025-03-01 10:01:00', 'aceptada'),
(3, 6, '2025-03-01 10:00:10', '2025-03-01 10:02:00', 'rechazada'),
(3, 7, '2025-03-01 10:00:10', '2025-03-01 10:03:00', 'rechazada'),

-- Viaje 4
(4, 6, '2025-03-01 11:00:15', '2025-03-01 11:03:00', 'aceptada'),
(4, 8, '2025-03-01 11:00:15', '2025-03-01 11:04:00', 'rechazada'),

-- Viaje 5
(5, 7, '2025-03-01 12:00:20', '2025-03-01 12:04:00', 'aceptada'),
(5, 8, '2025-03-01 12:00:20', '2025-03-01 12:05:00', 'rechazada'),
(5, 10, '2025-03-01 12:00:20', NULL, 'expirada'),

-- Viaje 6
(6, 1, '2025-03-01 12:30:10', NULL, 'pendiente'),
(6, 3, '2025-03-01 12:30:10', NULL, 'pendiente'),
(6, 9, '2025-03-01 12:30:10', NULL, 'pendiente'),

-- Viaje 7
(7, 2, '2025-03-01 13:00:10', '2025-03-01 13:05:00', 'rechazada'),
(7, 4, '2025-03-01 13:00:10', NULL, 'expirada'),

-- Viaje 8
(8, 3, '2025-03-01 14:00:15', '2025-03-01 14:02:00', 'aceptada'),
(8, 5, '2025-03-01 14:00:15', '2025-03-01 14:03:00', 'rechazada'),

-- Viaje 9
(9, 5, '2025-03-01 15:00:10', '2025-03-01 15:01:00', 'aceptada'),
(9, 6, '2025-03-01 15:00:10', '2025-03-01 15:02:00', 'rechazada'),

-- Viaje 10
(10, 2, '2025-03-01 15:30:10', NULL, 'pendiente'),
(10, 7, '2025-03-01 15:30:10', NULL, 'pendiente'),
(10, 8, '2025-03-01 15:30:10', NULL, 'pendiente');


-- 9. PAGOS (solo para viajes finalizados)

INSERT INTO pagos (id_viaje, importe, moneda, estado_pago, fecha_pago) VALUES
(1, 13.20, 'EUR', 'pagado', '2025-03-01 08:24:00'),
(2, 16.90, 'EUR', 'pagado', '2025-03-01 09:37:00'),
(3, 25.10, 'EUR', 'pagado', '2025-03-01 10:33:00'),
(8, 11.40, 'EUR', 'pagado', '2025-03-01 14:21:00');