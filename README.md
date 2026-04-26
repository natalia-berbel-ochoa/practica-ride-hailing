# Práctica-ride-hailing
## Descripción del proyecto
Práctica en grupo para la asignatura Bases de Datos Avanzadas. Este proyecto implementa una base de datos relacional para una plataforma de ride-hailing.  En este sistema, un rider solicita un viaje entre dos ubicaciones, se generan varias ofertas para distintos conductores y el primer conductor que acepta queda asignado al viaje y recibe el pago correspondiente al finalizar el trayecto. La base de datos incluye usuarios, riders, conductores, companies, vehículos, ubicaciones, viajes, ofertas, pagos y una tabla de auditoría básica.

## Contenido de la práctica
El repositorio contiene los siguientes archivos principales:
- **schema.sql**: creación del esquema de la base de datos, tablas, restricciones e índices.
- **data.sql**: carga de datos de prueba.
- **queries.sql**: consultas para la operativa básica.
- **dashboard.sql**: consultas para métricas y dashboard.
- **backup.sql**: plan de backup y recuperación.
- **permissions.sql**: usuarios y permisos de base de datos.
- **compose.yml**: despliegue con Docker Compose.
- **DESIGN.md**: explicación del diseño de la base de datos y MER.
- **README.md**: instrucciones de uso del proyecto.
- **presentacion.pdf**: presentación final del proyecto para la defensa

## Instrucciones de arranque
*Requisitos Previos:*
- Docker y Docker Compose instalados
- Puerto 5432 libre en la máquina local

*Arranque Rápido:*
1. **Levantar los contenedores:** docker compose up -d
2. **Verificar que el contenedor está corriendo:** docker ps
3. **Cargar el esquema:** docker exec -i ride_hailing psql -U postgres -d ride_hailing_db < schema.sql
4. **Cargar los datos de prueba:** docker exec -i ride_hailing psql -U postgres -d ride_hailing_db < data.sql
5. **Cargar los permisos:** docker exec -i ride_hailing psql -U postgres -d ride_hailing_db < permissions.sql

*Acceso a la Base de Datos:*
- **Conexión directa:** docker exec -it ride_hailing psql -U postgres -d ride_hailing_db
- **Ejecutar un archivo de consultas:**
    docker exec -i ride_hailing psql -U postgres -d ride_hailing_db < queries.sql
    docker exec -i ride_hailing psql -U postgres -d ride_hailing_db < dashboard.sql

*Dashboard visual:*
Se incorpora además un dashboard visual mediante la herramienta Adminer. Esta permite visualizar y ejecutar consultas sobre la base de datos sin necesidad de instalar software adicional. De este modo, se cumple el requisito de disponer de un dashboard de métricas, facilitando la inspección tanto de métricas de negocio como de bases de datos.

El acceso a este dashboard es tan sencillo como, tras levantar los contenedores (indicado en la sección de arranque rápido), acceder a:
http://localhost:8081

Ahí, se inicia sesión con los siguientes datos, tras lo cual se podrán realizar las consultas necesarias.
Sistema: PostgreSQL
Servidor: postgres
Usuario: postgres
Contraseña: postgres
Base de datos: ride_hailing_db

## Modelo de datos
El modelo se basa en siete entidades principales:
- RIDER
- VIAJE
- OFERTA
- CONDUCTOR
- COMPANY
- PAGO
- VEHÍCULO

El núcleo del sistema es la entidad VIAJE, que conecta con el resto del modelo y representa el ciclo completo. Se han definido relaciones 1:N y 1:1 según el dominio del problema, destacando:
- Un rider puede realizar múltiples viajes.
- Un viaje genera múltiples ofertas.
- Sólo una oferta puede ser aceptada por viaje.
- Cada viaje genera un único pago.

Las tablas auxiliares de auditoría e historial no se incluyen en el MER por claridad, pero están implementadas en el modelo físico.

## Flujo del sistema
El sistema tiene el siguiente ciclo de vida:
1. Un rider solicita un viaje, creándose un registro en VIAJE.
2. Se generan múltiples ofertas en la tabla OFERTA.
3. Los conductores responden a las ofertas.
4. Cuando acepta el primer conductor:
    - Se le asigna el viaje.
    - El resto de ofertas se rechazan automáticamente.
5. El viaje pasa por los estados solicitado, aceptado, en curso y finalizado.
6. Al finalizar, se genera el pago, quedando registrado en la tabla pago.

## Concurrencia y transacciones
Se han implementado mecanismos de control de concurrencia para garantizar la consistencia del sistema. Concretamente:
- Uso de SELECT...FOR UPDATE para bloquear registros durante la aceptación de ofertas.
- Transacciones atómicas para:
    - Creación de viaje y ofertas.
    - Aceptación de oferta.
    - Finalización de viaje y pago.

Además, se ha definido un índice único que impide que más de una oferta pueda ser aceptada para un mismo viaje. Esto garantiza que un único conductor se quede el viaje.

## Índices
Se han creado índices sobre claves foráneas para la optimización de consultas, como por ejemplo:
- Búsqueda de viajes por estado.
- Ofertas por viaje y conductor.
- Pagos por viaje.
- Conductores por company.

## Backup y recuperación
Se ha definido un plan de backup que permite restaurar copias completas en la base de datos, ademñas de la restauración del sistema en caso de fallo. Esto garantiza la disponibilidad del sistema.