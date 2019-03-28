# Prueba de concepto sobre el escalado con PHP

Asumiendo que configuramos apache para que soporte un máximo de 2 clientes de
forma simultánea, basada en la configuración provista en
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
Asumiendo que el código PHP en `www/index.php` demora aproximadamente **2
segundos** en responder por como está generado tal script, podemos evidenciar
los resultados con el siguiente ejemplo

```
ab -l -c10 -n600 http://localhost:8080/ 
```

Demora 600 segundos porque secuencialmente se prueba cada conexion, dando como
resultado que cada requerimiento se sirve en 2 segundos, pero con un tiempo
promedio de 10 segundos, esto es 5 veces más de lo esperado

```
ab -l -c3 -n600 http://localhost:8080/
```

Este comando ahora demora también 600 segundos, dando como resultado que cada
requerimiento se sirve en aproximadamente 4 segundos, esto es el doble de lo
esperado

Cuantos más clientes agreguemos, los tiempos se irán incrementando porque el
servidor encolará pedidos que irá atendiendo mientras no expire la conexión HTTP
iniciada.

Los resultados pueden analizarse mejor usando la opción de `ab` que exporta los
resultados en TSV para luego graficar con [GnuPlot](http://www.gnuplot.info/)

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

Probamos con ab usando nuevamente 10 conexiones concurrentes:

```
ab -l -c10 -n 600 -H 'Host: php-scale.probe' http://localhost:8090/
```

### Escalando la app

Si escalamos el web server usando:

```
docker-compose -f docker-compose.lb.yml up --scale app=2 -d
```

Ahora podríamos atender más clientes en menos tiempo

