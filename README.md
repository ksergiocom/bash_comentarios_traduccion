# NO FUNCIONA - ESTOY EN ELLO

*¿Qué pasa? Estoy aprendiendo, ¿¡Vale!?*
*¡Ver los problemas existentes abajo!*

# Bash Comment Translate Tool

Bienvenido a mi infierno personal. Ahora también atrapamos los echos.

El script referencia todos los comentarios y echos, y te genera ficheros de traducción con las referencias creadas para poder intercambiarlos facilmente.

![example](img/example.png)

![extracted_comments](img/comments.png)

## Problemas existentes y pendientes

1. *MEMORIA (a medias)*Abro y cierro el mismo archivo con sed y con grep. (Carga el archivo en memoria, modifia y lugeo reemplazar 1 vez el orignal por el actualizado). (SWAP, ADD, RENUMERATE. EN CREATE YA ESTA!)
2. *progress bar* esta roto.
3. *findEchoes* Estas lineas no las ha leido correctamente (1599,1600);

    ```bash
    echo -ne "\n Error en la elección de una opción válida\n--> " | tee -a $informeConColorTotal
    echo -ne "\n Error en la elección de una opción válida\n--> " >> $informeSinColorTotal
    ```
4. *Find comments* hay que atrapar el $() (()) [[]]  : Se hace parecido al tratamiento de comillas. Se comprueba el caracter anterior y el actual.
5. Si el nombre ontiene caracteres raros peta, lel!
