-- Resumimos las ofertas en todos los estados
SELECT
    COUNT(*) AS total_ofertas,
    COUNT(*) FILTER (WHERE estado_oferta = 'aceptada') AS ofertas_aceptadas,
    COUNT(*) FILTER (WHERE estado_oferta = 'rechazada') AS ofertas_rechazadas,
    COUNT(*) FILTER (WHERE estado_oferta = 'enviada') AS ofertas_pendientes,
    -- Calculamose l porcentaje de aceptación
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE estado_oferta = 'aceptada')
        / NULLIF(COUNT(*), 0), -- Si no hay ofertas evitamos el dividir entre 0
        2  -- Redondeamos a 2 decimales
    ) AS tasa_aceptacion_global_pct
FROM oferta;

-- Estadísticas de las ofertas por cada conductor
SELECT
-- Identificamos al conductor y la empresa  a la que pertenece
    c.id_conductor,
    c.nom_conductor,
    c.ap_conductor,
    co.id_company,
    co.nom_company,
    -- Ofertas y lo que ha hecho el conductor con ellas
    COUNT(o.id_oferta) AS ofertas_recibidas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada') AS ofertas_aceptadas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'rechazada') AS ofertas_rechazadas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'enviada') AS ofertas_pendientes,
    -- Porcentaje de aceptación de cada conductor
    ROUND(
        100.0 * COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada')
        / NULLIF(COUNT(o.id_oferta), 0),
        2
    ) AS tasa_aceptacion_pct
FROM conductor c
-- Unimos al conductor con su empresa
JOIN company co
    ON c.id_company = co.id_company
-- Aparecen también los conductores sin oferta
LEFT JOIN oferta o
    ON c.id_conductor = o.id_conductor
-- Agrupamos por conductor y empresa para poder calcular las métricas
GROUP BY
    c.id_conductor, c.nom_conductor, c.ap_conductor,
    co.id_company, co.nom_company
-- Mejores porcentajes de aceptación, y si empata quién recibió más ofertas
ORDER BY tasa_aceptacion_pct DESC NULLS LAST, ofertas_recibidas DESC;

-- Ofertas por empresa
SELECT
    co.id_company,
    co.nom_company,
    -- Ofertas ligadas a los conductores
    COUNT(o.id_oferta) AS ofertas_totales,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada') AS ofertas_aceptadas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'rechazada') AS ofertas_rechazadas,
    COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'enviada') AS ofertas_pendientes,
    ROUND( -- Tasa de aceptación de la empresa
        100.0 * COUNT(o.id_oferta) FILTER (WHERE o.estado_oferta = 'aceptada')
        / NULLIF(COUNT(o.id_oferta), 0),
        2
    ) AS tasa_aceptacion_pct
FROM company co
LEFT JOIN conductor c
    ON co.id_company = c.id_company
LEFT JOIN oferta o
    ON c.id_conductor = o.id_conductor
GROUP BY co.id_company, co.nom_company
-- Ordenamos por mejor tasa de aceptación y por volumen de ofertas
ORDER BY tasa_aceptacion_pct DESC NULLS LAST, ofertas_totales DESC;

-- Resumen de viajes finalizados
SELECT
-- Totsal de viajes finalizados con sus datos
    COUNT(*) AS total_viajes_finalizados,
    ROUND(AVG(distancia_km), 2) AS kilometraje_medio_km,
    ROUND(AVG(duracion_min), 2) AS tiempo_medio_min,
    ROUND(SUM(distancia_km), 2) AS kilometros_totales,
    ROUND(SUM(duracion_min), 2) AS minutos_totales
FROM viaje
WHERE estado_viaje = 'finalizado'
-- Solo consideramos viajes con distancia y duración conocida
  AND distancia_km IS NOT NULL
  AND duracion_min IS NOT NULL;

-- Ingresos y comisiones por conductor
SELECT
    c.id_conductor,
    c.nom_conductor,
    c.ap_conductor,
    co.id_company,
    co.nom_company,
    -- Número de pagos completados a ese conductor
    COUNT(p.id_pago) AS viajes_cobrados,
    -- Suma total del cliente
    ROUND(SUM(p.importe_pago), 2) AS facturacion_bruta,
    -- Comisioens totales que se queda la empresa
    ROUND(SUM(p.comision_company), 2) AS comision_total_company,
    -- Lo que se lleva el conductor una vez quitadas las comisiones
    ROUND(SUM(p.importe_pago - p.comision_company), 2) AS ingreso_neto_conductor
FROM conductor c
JOIN company co
    ON c.id_company = co.id_company
LEFT JOIN oferta o
    ON c.id_conductor = o.id_conductor
LEFT JOIN pago p
    ON o.id_oferta = p.id_oferta
   AND p.estado_pago = 'completado'
GROUP BY
    c.id_conductor, c.nom_conductor, c.ap_conductor,
    co.id_company, co.nom_company
ORDER BY ingreso_neto_conductor DESC NULLS LAST;

-- Ingresos y comisiones por empresa
SELECT
    co.id_company,
    co.nom_company,
    -- Pagos completados a la empresa
    COUNT(p.id_pago) AS viajes_cobrados,
    -- Facturación bruta total
    ROUND(SUM(p.importe_pago), 2) AS facturacion_bruta_total,
    -- Ingreso que obtiene la empresa por comisiones
    ROUND(SUM(p.comision_company), 2) AS ingreso_company,
    -- Parte neta que reciben los conductores
    ROUND(SUM(p.importe_pago - p.comision_company), 2) AS ingreso_neto_conductores
FROM company co
LEFT JOIN conductor c
    ON co.id_company = c.id_company
LEFT JOIN oferta o
    ON c.id_conductor = o.id_conductor
LEFT JOIN pago p
    ON o.id_oferta = p.id_oferta
   AND p.estado_pago = 'completado'
GROUP BY co.id_company, co.nom_company
ORDER BY ingreso_company DESC NULLS LAST;

-- Ingresos por km y por minuto
SELECT
-- Ingresos cobrados en pagos completados
    ROUND(SUM(p.importe_pago), 2) AS ingresos_totales,
    -- Kms totales de viajes finalizados
    ROUND(SUM(v.distancia_km), 2) AS km_totales,
    -- Minutos de esos viajes
    ROUND(SUM(v.duracion_min), 2) AS min_totales,
    -- Rentabilidad media por km
    ROUND(SUM(p.importe_pago) / NULLIF(SUM(v.distancia_km), 0), 2) AS euros_por_km,
    -- Rentabilidad media por minuto
    ROUND(SUM(p.importe_pago) / NULLIF(SUM(v.duracion_min), 0), 2) AS euros_por_minuto
FROM pago p
JOIN viaje v
-- Relacionamos cada oagi con el viaje correspondiente
    ON p.id_viaje = v.id_viaje
WHERE p.estado_pago = 'completado'
  AND v.estado_viaje = 'finalizado'
  AND v.distancia_km IS NOT NULL
  AND v.duracion_min IS NOT NULL;

-- Rentabilidad por empresa
SELECT
    co.id_company,
    co.nom_company,
    -- Ingresos totales generados
    ROUND(SUM(p.importe_pago), 2) AS ingresos_totales,
    -- Distancia totoal recorrida
    ROUND(SUM(v.distancia_km), 2) AS km_totales,
    -- Tiempo total invertido
    ROUND(SUM(v.duracion_min), 2) AS min_totales,
    -- Ingreso medio por kilómetro
    ROUND(SUM(p.importe_pago) / NULLIF(SUM(v.distancia_km), 0), 2) AS euros_por_km,
    -- Ingreso medio por minuto
    ROUND(SUM(p.importe_pago) / NULLIF(SUM(v.duracion_min), 0), 2) AS euros_por_minuto
FROM company co
JOIN conductor c
    ON co.id_company = c.id_company
JOIN oferta o
    ON c.id_conductor = o.id_conductor
JOIN pago p
    ON o.id_oferta = p.id_oferta
JOIN viaje v
    ON p.id_viaje = v.id_viaje
WHERE p.estado_pago = 'completado'
  AND v.estado_viaje = 'finalizado'
  AND v.distancia_km IS NOT NULL
  AND v.duracion_min IS NOT NULL
GROUP BY co.id_company, co.nom_company
ORDER BY euros_por_km DESC NULLS LAST;

-- Fechas de los viajes
SELECT
-- Agrupamos las fechas por horas exactas
    DATE_TRUNC('hour', solicitud_viaje) AS hora,
    -- Total de viajes solicitados a esa hora
    COUNT(*) AS viajes_solicitados,
    -- De esos viajes, cuántos se finalizaron
    COUNT(*) FILTER (WHERE estado_viaje = 'finalizado') AS viajes_finalizados,
    -- Cuántos se cancelaron
    COUNT(*) FILTER (WHERE estado_viaje = 'cancelado') AS viajes_cancelados,
    -- Cuantos siguen en curso
    COUNT(*) FILTER (WHERE estado_viaje IN ('solicitado', 'aceptado', 'en curso')) AS viajes_activos_o_abiertos
FROM viaje
GROUP BY DATE_TRUNC('hour', solicitud_viaje)
ORDER BY hora;

-- Fecha de las ofertas aceptadas
SELECT
-- Agrupamos por hora de respuesta
    DATE_TRUNC('hour', respuesta_oferta) AS hora,
    -- Total de ofertas aceptadas en cada hora
    COUNT(*) AS ofertas_aceptadas
FROM oferta
-- Contamos sólo ofertas que fueron aceptadas
WHERE estado_oferta = 'aceptada'
  AND respuesta_oferta IS NOT NULL
GROUP BY DATE_TRUNC('hour', respuesta_oferta)
ORDER BY hora;

-- Tiempo medio de respuesta de los conductores
SELECT
    c.id_conductor,
    c.nom_conductor,
    c.ap_conductor,
    co.nom_company,
    -- Número de ofertas respondidas por un conductor
    COUNT(o.id_oferta) FILTER (WHERE o.respuesta_oferta IS NOT NULL) AS ofertas_respondidas,
    ROUND( -- Tiempo medio de respuesta en minutos
        AVG(EXTRACT(EPOCH FROM (o.respuesta_oferta - o.envio_oferta)) / 60.0),
        2
    ) AS tiempo_medio_respuesta_min
FROM conductor c
JOIN company co
    ON c.id_company = co.id_company
LEFT JOIN oferta o
    ON c.id_conductor = o.id_conductor
WHERE o.respuesta_oferta IS NOT NULL
GROUP BY
    c.id_conductor, c.nom_conductor, c.ap_conductor, co.nom_company
ORDER BY tiempo_medio_respuesta_min ASC NULLS LAST;

-- Distribución de viajes por estado
SELECT
    estado_viaje,
    -- Número de viajes en cada estado
    COUNT(*) AS total_viajes
FROM viaje
GROUP BY estado_viaje
ORDER BY total_viajes DESC;

-- Pagos por estado
SELECT
    estado_pago,
    -- Número de pagos en cada estado
    COUNT(*) AS total_pagos,
    -- Importe acumulado por estado
    ROUND(SUM(importe_pago), 2) AS importe_total
FROM pago
GROUP BY estado_pago
ORDER BY total_pagos DESC;

-- Tamaño de la base de datos
SELECT
-- Nombre de la base de datos actual
    current_database() AS base_de_datos,
    -- Tamaño total de la base en un formato legible
    pg_size_pretty(pg_database_size(current_database())) AS tamanio_total_bd;

-- Tamaño de cada tabla
SELECT
    relname AS tabla,
    -- Tamaño de la tabla, incluyendo datos, índices y TOAST
    pg_size_pretty(pg_total_relation_size(relid)) AS tamanio_total
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Estadísticas de tablas
SELECT
    relname AS tabla,
    -- Número de lecturas realiadas
    seq_scan,
    -- Número de lecturas usando índices
    idx_scan,
    -- Filas insertadas
    n_tup_ins AS filas_insertadas,
    n_tup_upd AS filas_actualizadas,
    n_tup_del AS filas_borradas,
    n_live_tup AS filas_vivas_estimadas,
    -- Estimación de filas pendientes de limpieza
    n_dead_tup AS filas_muertas_estimadas
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC, relname;

-- Tamaño de los índices
SELECT
    t.relname AS tabla,
    i.relname AS indice,
    s.idx_scan AS veces_usado,
    -- Tamaño en formato legible
    pg_size_pretty(pg_relation_size(i.oid)) AS tamanio_indice
FROM pg_class t
JOIN pg_index x
-- Relacionamos tablas con sus índices
    ON t.oid = x.indrelid
JOIN pg_class i
    -- Obtenemos el nombre del índice
    ON i.oid = x.indexrelid
JOIN pg_stat_user_indexes s
    -- Obtenemos estadísticas de uso del índice
    ON s.indexrelid = i.oid
-- Relaciones de tipo tabla ordinaria
WHERE t.relkind = 'r'
ORDER BY s.idx_scan DESC, tabla, indice;

-- Resumen de la auditoría de operaciones
SELECT
    tabla_afectada,
    operacion,
    COUNT(*) AS total_operaciones,
    MIN(fecha_operacion) AS primera_operacion,
    MAX(fecha_operacion) AS ultima_operacion
FROM auditoria_operaciones
GROUP BY tabla_afectada, operacion
ORDER BY tabla_afectada, operacion;

-- Estado de las conexiones
SELECT
-- Estadi de la conexión
    state AS estado_conexion,
    -- Número de conexiones en ese estado
    COUNT(*) AS total
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state
ORDER BY total DESC;

-- Estadísticas de actividad de la base de datos
SELECT
-- Nombre de la BBDD
    datname,
    numbackends AS conexiones_activas,
    -- Transacciones confirmadas
    xact_commit AS transacciones_commit,
    xact_rollback AS transacciones_rollback,
    tup_returned AS filas_devueltas,
    tup_fetched AS filas_leidas,
    tup_inserted AS filas_insertadas,
    tup_updated AS filas_actualizadas,
    tup_deleted AS filas_borradas
FROM pg_stat_database
WHERE datname = current_database();