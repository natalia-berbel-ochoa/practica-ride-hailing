# Descripción
Para la práctica de la asignatura Bases de Datos Avanzadas se ha diseñado e implementado la base de datos de una plataforma de ride-hailing. En este sistema, un rider solicita un viaje que es ofertado a varios conductores. Estos pueden aceptarlo o rechazarlo, de modo que el primer conductor que lo acepte queda asignado al viaje y recibe el pago correspondiente una vez finalizado.

Nuestro modelo se articula en torno a siete entidades principales, cada una con sus correspondientes claves y atributos. A lo largo del presente archivo se explicarán dichas entidades, así como las relaciones existentes entre ellas y los criterios seguidos para su diseño.

# Supuestos para el diseño
En primer lugar, se han definido las relaciones del modelo entidad-relación a partir de una serie de supuestos, necesarios para comprender las decisiones adoptadas en el diseño:

1. Relación CONDUCTOR-VEHÍCULO  
    Dado que el enunciado no especifica si un conductor puede utilizar varios vehículos, se ha optado por asumir que cada conductor conduce siempre un único vehículo. Por ello, esta relación es una relación 1:1.

2. Relación VIAJE-PAGO  
    Se ha asumido que cada viaje genera un único pago, realizado una vez finalizado el trayecto. En consecuencia, la relación entre VIAJE y PAGO se ha planteado como 1:1.

3. Variable geolocalización  
    En la entidad VIAJE se almacenan tanto las coordenadas geográficas del origen y del destino como la dirección asociada a cada punto. De este modo, el usuario indica la ubicación deseada sin necesidad de buscar su latitud y longitud.

4. Clave foránea de VIAJE  
    La entidad VIAJE incorpora una clave foránea correspondiente al conductor asignado. Esta clave permanece vacía mientras el viaje se encuentra solicitado y pasa a completarse en el momento en que una de las ofertas es aceptada por un conductor. De este modo, el viaje queda vinculado al conductor que finalmente lo realizará.

# Modelo Entidad-Relación
A continuación, se presenta el MER resultante, realizado mediante la herramienta "Mermaid", recomendada en el enunciado proporcionado. 

![MER](./MER.png)

# Entidades principales
En este apartado se describen las entidades sobre las que hemos basado nuestra base de datos. 
- **RIDER**: Usuario que utiliza la aplicación para solicitar un viaje.Cuenta con un ID como clave primaria, además de los datos necesarios para el registro. Cada rider puede realizar múltiples solicitudes a lo largo del tiempo.
- **VIAJE**: Entidad que representa el núcleo del modelo. Almacena la infromación de cada trayecto solicitado, como el precio y el conductor asignado. Además, supone también un putno de conexión con otras entidades.
- **OFERTA**: Representa la lógica del problema. Cuando un rider solicita un viaje, se genera la oferta, que recoge el viaje, el conductor y el estado de la respuesta. Permite registrar qué conductores han recibido una solicitud y cuáles la han aceptado.
- **CONDUCTOR**: Representa a los usuarios que reciben ofertas y realizan los viajes. Cada uno pertenece a una única empresa, y de acuerdo con los supeustos mencionados previamente, está vinculado con un único vehículo. Sobre esta entidad se calculan métricas como la tasa de aceptación o los ingresos generados.
- **COMPANY**: Agrupa a los conductores según la empresa a la que pertenecen. Representa una naecesidad fucnional, pues el enunciado pide el cálculo de métricas asociadas a la empresa, como los ingresos o la tasa de aceptación.
- **PAGO**: Recoge la información económica asociada a cada solicitud de viaje. Es una entidad independiente para facilitar la gestión del cobro. Por esta separación, es más fácil calcular ingresos por conductor y por empresa, además de los euros por kilómetro o los euros por minuto.
- **VEHÍCULO**: Almacena la innformación del transporte empleado por el conductor. Su función principal es descriptiva, pero permite también acercar el modelo al funcionamiento real de este tipo de aplicaciones.

# Relaciones y cardinalidades
Las relaciones entre las entidades han sido definidas siguiendo el funcionamiento del sistema y los supuestos previamente mencionados.

En primer lugar, la relación entre RIDER y VIAJE es de uno a muchos, dado que un mismo rider puede solicitar varios viajes a lo largo del tiempo, mientras que cada viaje solo puede haber sido solicitado por un único rider.

Asimismo, la relación entre VIAJE y OFERTA es también de uno a muchos. Esto se debe a que una misma solicitud de viaje puede generar múltiples ofertas dirigidas a distintos conductores. Cada oferta, sin embargo, pertenece exclusivamente a un único viaje.

La relación entre CONDUCTOR y OFERTA es igualmente de uno a muchos. Un mismo conductor puede recibir muchas ofertas a lo largo de su actividad, pero cada oferta concreta se remite a un solo conductor.

Por otro lado, la relación entre COMPANY y CONDUCTOR es de uno a muchos, puesto que una empresa puede agrupar a varios conductores, mientras que cada conductor pertenece únicamente a una company.

Como se ha mencionado antes, la relación entre CONDUCTOR y VEHÍCULO es de uno a uno. De este modo, cada conductor dispone de un único vehículo asociado y cada vehículo queda vinculado a un solo conductor.

Por último, la relación entre VIAJE y PAGO se ha definido como uno a uno, ya que cada trayecto genera un único pago asociado.

# Consultas operativas (archivo queries.sql)
Se han realizado 4 tipos de consultas para tratar de cubrir el ciclo de vida de u viaje.
1. Inserts con transacciones atómicas
    Se ha introducido el registro de un conductor y su vehículo dentro de una sola transacción. Esto garantiza que no haya conductor sin vehículo ni vehículo sin conductor. Del mismo modo, la solicitud del viaje y el envío de la oferta se ha agrupado en una transacción, de maner aque ningún viaje en estado solicitado carezca de oferta.

2. Aceptación de oferta con bloqueo
    Se bloquea la oferta con 'SELECT...FOR UPDATE', impidiendo que otra sesión la modifique. Tras ello, se marca la oferta como aceptada y se asigna el conductor. Automáticamente se rechazan el resto de ofertas, garantizando el requisito de no haber dos conductores que acepten la misma oferta.

3. Finalización del viaje y registro del pago
    La transición a finalizado y el pago se realizan en una única transacción. Por tanto, si el registro del pago fallase, el viaje no quedaría como finalizado.

4. Consultas 
    Se incluyen las consultas más habituales en este tipo de aplicaciones:
        - Historial de estados de un viaje
        - Viajes activos
        - Ofertas por viaje
        - Pagos completados (con información sobre el conductor)