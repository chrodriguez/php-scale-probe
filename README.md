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
ab -l -c1 -n4 http://localhost:8080/ 
```

Demora 40 segundos porque secuencialmente se prueba cada conexion, demorando el
test completo 40 segundos aproximadamente y dando un resultado de 0.09
conexiones por segundo

```
ab -l -c4 -n4 http://localhost:8080/
```

Este comando ahora demora 20 segundos, porque se prueban concurrentemente 4
clientes, y se pueden atender de a dos simultáneamente, dando un resultado de
0.20 conexiones por segundo.

Cuantos más clientes agreguemos, los tiempos se irán incrementando porque el
servidor encolará pedidos que irá atendiendo mientras no expire la conexión TCP
iniciada.

## Mejorando los resultados con escalamiento

Proveemos un archivo llamado `docker-compose.lb.yml` que sitúa al web server
detrás de un proxy reverso implementado con NGINX. Dicho proxy reverso se
configura considerando:

* Autoconfigura los upstreams en caso de escalamiento horizontal
* Se restringe las conexiones con los upstream hasta 10 segundos (el mismo valor
  que demora aproximadamente cada proceso de apache)

De esta forma, podremos verificar lo siguiente:

* Un upstream debería atender solo dos conexiones simultáneas, a la tercera
  entregar un 502
* Si escalamos nuestra aplicación, entonces podremos atender **2 * ESCALA**
  clientes simultáneos

### Probamos con un upstream

Iniciamos una aplicación detrás del proxy reverso:


```
docker-compose -p php-scale-probe-lb -f docker-compose.lb.yml up
```

Para poder probar la aplicación, es necesario acceder por el puerto 8090 y 
utilizar como hostname **php-scale.probe**:

Podemos verificar el funcionamiento de la siguiente forma:

```
curl -H 'Host: php-scale.probe' http://localhost:8090/
```

Probamos con tres conexiones simultáneas:

```
tmux new-session \
    'curl -H "Host: php-scale.probe" localhost:8090 && echo Press ENTER && read' \; \
  split-window \
    'curl -H "Host: php-scale.probe" localhost:8090 && echo Press ENTER && read' \; \
  split-window \
    'curl -H "Host: php-scale.probe" localhost:8090 && echo Press ENTER && read'
```

Notamos que el tercer cliente recibe un 504. Este mismo resultado con ab sería:

```
ab -l -c3 -n3 -H "Host: php-scale.probe" http://localhost:8090/
```

Debería obtenerse 1 requerimiento fallido en 10 segundos

### Escalando la app

Si escalamos el web server usando:

```
docker-compose -f docker-compose.lb.yml up --scale app=3 -d
```

Ahora podríamos atender 6 clientes de forma simultánea:

```
ab -l -c12 -n12 -H "Host: php-scale.probe" http://localhost:8090/
```

Deberían obtenerse un promedio de 6 requerimientos exitosos en 10 segundos, y
pueden variar según como se manejan los timeouts del nginx que generalmente
marcan como no disponibles a los upstream por 10 segundos por defecto

_**Es importante destacar que entre pruebas debe esperarse al menos 1 minuto 
para que no queden procesos de apache ocupados, ni upstreams marcados en el
proxy reverso**__
