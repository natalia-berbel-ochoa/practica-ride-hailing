# Práctica-ride-hailing
## Descripción del proyecto
Práctica en grupo para la asignatura Bases de Datos Avanzadas. Este proyecto implementa una abse de datos relacional para una plataforma de ride-hailin.  En este sistema, un rider solicita un viaje entre dos ubicaciones, se generan varias ofertas para distintos conductores y el primer conductor que acepta queda asignado al viaje y recibe el pago correspondiente al finalizar el trayecto. La base de datos incluye usuarios, riders, conductores, companies, vehículos, ubicaciones, viajes, ofertas, pagos y una tabla de auditoría básica.

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
