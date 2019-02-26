# Prueba de concepto sobre el escalado con PHP

Asumiendo que se Configuras apache para que soporte un máximo de 2 clientes de
forma simultánea, basada en la configuracion provista en
`www-conf/apache-tune.conf`, podemos verificar el funcionamiento con la
siguiente configuración de docker-compose:

```yml
version: '3'
services:
  app:
    image: php:7-apache
    volumes:
      - ./www-conf/apache-tune.conf:/etc/apache2/conf-enabled/apache-tune.conf
      - ./www:/var/www/html
    ports:
      - "8080:80"
```
Asumiendo que el código PHP en `www/index.php` demora aproximadamente **10
segundos** en responder por como está generado tal script, podemos evidenciar
los resultados con el siguiente ejemplo

```
tmux new-session \
    'curl localhost:8080 && echo Press ENTER && read' \; \
  split-window \
    'curl localhost:8080 && echo Press ENTER && read' \; \
  split-window \
    'curl localhost:8080 && echo Press ENTER && read'
```

O más simple, con ab, podemos ver que:

```
ab -c1 -n4 http://localhost:8080/ 
```

Demora 40 segundos porque secuencialmente se prueba cada conexion, demorando el
test completo 40 segundos aproximadamente y dando un resultado de 0.09
conexiones por segundo

```
ab -c4 -n4 http://localhost:8080/
```

Este comando ahora demora 20 segundos, porque se prueban concurrentemente 4
clientes, y se pueden atender de a dos simultáneamente, dando un resultado de
0.20 conexiones por segundo.

Cuantos más clientes agreguemos, los tiempos se irán incrementando porque el
servidor encolará pedidos que irá atendiendo mientras no expire la conexión TCP
iniciada.

## Mejorando los resultados con escalamiento

Proveemos un archivo llamado `docker-compose.lb.yml` que podemos iniciar de la
siguiente forma:

```
docker-compose -p php-scale-probe-lb -f docker-compose.lb.yml up --scale app=3
```

En este caso, se crearán 3 instancias de nuestra aplicación app y en frente se
autonconfigurará un nginx que balancea las conexiones hacia atrás. El servicio
de nginx atiende ahora en el puerto 8090 y debe utilizar como 
hostname: php-scale.probe

Podemos verificar el funionamiento de la siguiente forma:

```
curl -H 'Host: php-scale.probe' http://localhost:8090/
```

Alternadamente llamando a este comando iremos recibiendo salidas con las
diferentes IP de cada contenedor de app. Serían 3 ip diferentes


