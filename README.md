# Práctica de control de Sistemas Operativos 2024
Esta práctica está dedicada al aprendizaje del lenguaje de scripting de bash.


El trabajo consiste en crear un script de bash que busque dentro de un directorio de forma recursiva todos los ficheros con la extension .sh y realize ciertas operaciones con ellos.

El script se ejecuta con un parámetro OBLIGATORIO de dirección (path) y pedirá al usuario a través de un menú interactivo que elija una de las operaciones posibles:

	- Generar referencias de comentarios
	- Traducir los comentarios referenciados
	- Re-referenciar los comentarios
	- Agregar/Quitar idioma


## Generar referencias de comentarios
Primero solicita al usuario elegir el idioma con el cual se quiere trabajar.

Esta opción busca TODOS los ficheros *.sh contenidos en el directorio y generará para cada idioma (ES,EN,FR) un fichero .txt de referencias de comentarios.

El fichero del idioma seleccionado tendrá un volcado de los comentarios con una numeración para cada uno de ellos (numeración 10,20,30...). Los otros ficheros solo tendrán la numeración SIN el comentario.

A los comentarios del ficher original se le agregará la nueva referencia generada.

Los ficheros de referencia se generan el mismo directorio donde se encuentra el script. Esto para los casos que existan subdirectorios hijos.

## Traducir los comentarios referenciados
Primero se solicita al usuario que escoja el idioma que va a insertar.

Se buscará para cada fichero .sh su fichero de traducción específico en función del idioma elegido. Posteriormente se sustituyen referencia a referencia los comentarios del original por los del fichero .txt

Se pueden crear comentarios con numeración adicional intermedia.

Por ejemplo; entre el comentario 10 y 20, puede existir el 15 creado a mano. En este caso los nuevos comentarios intermedios serán insertados inmediatamente a continuación del más pequeño. Es decir, el 15 irá debajo del 10.

## Re-referenciar los comentarios
Está opción busca todos los ficheros .sh y comprueba que exista una referencia generada. En caso de que no estén referenciados, los genera nuevos.

Busca todas las referencias de los comentarios teniendo en cuenta que pueden existir numeraciones intermedias (aquellos que NO sean multiplos de 10).

Para evitar problemas, teniendo en cuenta que ya están en orden correcto, borrar la referencia y crear una nueva.

## Agregar/Quitar idioma
Por el momento se trabaja con dos idiomas "hardcodeados" (ES,EN) pero más adelante debe dejar la opción de agregar un idioma extra.

Voy a usar un fichero para guardar los posibles idiomas que pueda generar para poder agregar o quitar idiomas de forma dinámica.


### 2024-04-27
He trasteado un poco con bash y los requerimientos solicitados en un proyecto en sucio. Ahora que tengo alguna noción básica de como tengo que trabajar con los ficheros he decidido empezar un proyecto en limpio e ir documentando el progreso.

	- Generado el README.md como guión básico
	- Inicializado el repositorio de git
	- Creada cabecera
	- Creado menu de inicio

## 2024-04-28
Ahora se crean los archivos .txt ES y EN para cada script. Se extraen los comentarios y se les asigna una referencia de numeración. Por ahora solo se hace para el ES, el EN solo se numera pero en blanco.
	
	- Generación de archivos .txt
	- Extracción de comentarios y numeración.

## 2024-04-29
He decidido simplificarlo lo máximo posible. Ahora hay 4 opciones posibles para las operaciones básicas.
	- Referenciar
	- Re-Referenciar
	- Extraer comentarios
	- Intercambiar comentarios

Luego agregaré validaciones, soporte para otros idiomas, etc.
