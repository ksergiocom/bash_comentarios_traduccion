*¿Qué pasa? Estoy aprendiendo, ¿¡Vale!?*

# Bash Comment Translate Tool

Bienvenido a mi infierno personal. Ahora también atrapamos los echos.

El script referencia todos los comentarios y echos, y te genera ficheros de traducción con las referencias creadas para poder intercambiarlos facilmente.

![example](img/example.png)

![extracted_comments](img/comments.png)

## Problemas existentes y pendientes

1. Repito el mismo código varias veces. Se puede refactorizar.
2. Hago un clear -x al final de cada ejecución. Se pierden los logs que suelta la consola. A veces no se ha realizado correctamnete alguna operación y aún asi limpia la consola y te dice que se ha terminado OK, cuando no es así. Habría que manejar esto.
3. El progress bar está mal hecho. No borra correctamente la iteración anterior.
4. En ocasiones abro el mismo archivo multiple veces para hacer operaciones en vez de cargarlo en memoria, operar sobre los datos de memoria y luego reemplazar el original por el actualizado. 
5. El log file de errores hace un continue en todas partes. Si no existe el file de traducción debe simplemente cortar la ejecución.