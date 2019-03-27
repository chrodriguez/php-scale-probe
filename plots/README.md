Los resultados aquí presentados se han obtenido de la siguiente forma:

```
ab -l -c10 -g data/plot-apache-10.tsv  -n 600 http://localhost:8080/ 
ab -l -c3 -g data/plot-apache-3.tsv  -n 600 http://localhost:8080/ 
```

Para generar las gráficas con gnuplot, simplemente correr:

```
gnuplot single-server.plot
```

