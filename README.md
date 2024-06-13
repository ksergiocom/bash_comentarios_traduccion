# Work in progress
## ToDos
	- Refactor buscar comentarios
	- Loader should be cleared at end
	- Translate comments

## Historial

### 2024-04-27
He trasteado un poco con bash y los requerimientos solicitados en un proyecto en sucio. Ahora que tengo alguna noción básica de como tengo que trabajar con los ficheros he decidido empezar un proyecto en limpio e ir documentando el progreso.

	- Generado el README.md como guión básico
	- Inicializado el repositorio de git
	- Creada cabecera
	- Creado menu de inicio

### 2024-04-28
Ahora se crean los archivos .txt ES y EN para cada script. Se extraen los comentarios y se les asigna una referencia de numeración. Por ahora solo se hace para el ES, el EN solo se numera pero en blanco.
	
	- Generación de archivos .txt
	- Extracción de comentarios y numeración.

### 2024-04-29
He decidido simplificarlo lo máximo posible. Ahora hay 4 opciones posibles para las operaciones básicas.
	- Referenciar
	- Re-Referenciar
	- Extraer comentarios
	- Intercambiar comentarios

Luego agregaré validaciones, soporte para otros idiomas, etc.

### 2024-04-30
He creado una función para borrar las referencias existentes

### 2024-05-01
Estoy preparando el script para poder guardar distintos idiomas de forma dinámica, a forma de base de datos rudimentaria. Utiliza un archivo oculto *.idiomas* que usaré para almacenar y leer los idiomas disponibles para trabajar.

Además he mejorado el borrrado. Si quería borrar las referenicas, solo borraba el primer patron (#ES_100), pero si este se repetia, no lo borraba.
Ahora he hecho que se borre incluso si hay varias referencias encadenadas... Pj: #ES_100ES_100ES_200....
Esto es así porque tenía un problema con el sed, que a veces escribía varias referenicas sobre el mismo comentario.

### 2024-05-02
Estoy intentando solucionar el problema del sed. Los comentarios se me crean correctamente en los ficheros de cada idioma, pero los que se insertan con sed en el script de origen a veces hacen cosas raras. En ocasiones se escriben asi:   #ES_10ES_40ES900...
He mejorado la regex para que se busque las veces que haga falta el patro [Az]_[0-9]{1,}  <- Ahora lo busca varias veces, si está encadenado lo trata como uno solo.

He agregado el flag -r al read del bucle while al crear las referencias. De esta forma ahora NO escapa caracteres especiales.

He decidido extraer con grep también el numero de línea de del comentario. Así cuando hago el procesado para agregarle la referencia y vuelva a insertarlo con sed, ahora, solo modifico la línea concreta donde estaba ese comentario. De otra forma tenía un error, resulta que en el sed no estoy escapando el caracter "\" y otros que no se cuales son ahora mismo. Lo se porque me genera un montón de errores en el archivo .sh real.

De cualquier manera he decidido dejarlo para más adelante y continuar con las opciones de los idiomas.

### 2024-05-04
Estoy creando la funcion para intercamiar los comentarios de un fichero de .txt numerados por los que existen numerados en el fichero original.

Tiene más complicaciónes de las que me esperaba en un principio ya que hay que extraer la numeración del prefijo e intercambiarlo por aquella que coincida en el fichero original. Pj: ES_50 debe ser intercambiado por EN_50. Hay que separar el prefijo ES_ y quedarse con el numero, y luego trabajar sobre ello.

### 2024-05-05
He decidido abusar del sed.... Para intercambiar los comentarios lo que hago es;
	- Buscar las coincidencias con las expresion regular que busca [AZ]{2,}_[0,9]+  <---- Aqui busco el prefijo y me quedo con el grupo de los numeros.
	- Luego con sed reemplazo todo el prefijo; reemplazo todo lo que coincide con la expresion regular (que sera el prefijo), por nada. Me quedo solo con el texto.
	- Con sed reemplazo la linea que coincida con la numeración por la nueva extraida.

He agregado una funcion que guarda nu idioma nuevo en el archivo .idiomas. Valida que el formato sea el indicado. Posible mejora, comprobar que ya exista el idioma.

Aquí ya tengo una versión funcional básica, hay muchas cosas que todavía se pueden mejorar y muchas faltantes. Aquí hay cosas que deberían mejorarse:
	- Agregar eliminar idioma desde el menú
	- El sed que trabaja el intercambio de los comentarios NO escapa algunos caracteres y da fallos.
	- Dar avisos de comentarios NO insertados o incongruencias de numeración
	- Limpiar (más bien hacer "scroll") la pantalla tras cada selección
	- Ahora mismo el log solo se crea con el error del sed, pero no si no se inserta nada.

Ahora voy a agregar submenús para poder trabajar más facilmente. Mejora de validacion de menus, no hace falta comprobarlo dos veces. Solo una vez hasta que es correcta.

### 2024-05-15
He decidido crear otra versión que en vez de realizar las sustituciones por sed las haga directamente iterando linea a linea y agregando algunas mejoras

	- Menu de inicio en bucle. Ahora el programa no acaba hasta no salir de forma explicita.
	- Menu de idiomas. He agregado una opcion para borrar idiomas
	- Fix idiomas. Despues de crear o borrar uno, hay que cargarlo en la variable global.
	- Funciona todo, pero está duplicado el codigo por todos lados

### 2024-05-19
	- Ahora los comentairos generados no dan problemas con los espacios
	- He arreglado los errores que existian al intercambiar los comentarios. Tenia problemas con los escapados y reemplazados de los # por #XX_Num varias veces, solo debía reemplazarse una.
	- Agregado opcion para agregar referencias nuevasintermedias a los archivos de traduccion ya existentes.

### 2024-05-20
	- Agregada opcion para genrear numeros de nuevo para todas las referencias y ficheros de traduccion
	- Modificado el regex para poder atrapar los comentarios del tipo ############## (no se porque no atrapa los # solos)

### 2024-05-23
	- Corregido un error al insertar comentarios adicionales que escribia en sitios que no le correspondía.
	
### 2024-05-24
	He acudido a la primera defensa. Hay varias cosas que habría que modificar del script:
		- Los idiomas deben estar en el mismo script. No en un archivo a parte.
		- Los idiomas deben poder ser seleccionados por numeros
		- Los idiomas deben estar identificados por el nombre completo. Ej: Español-ES
		- Los prefijos de las referencias deben tener el formato #10-ES- (deben tener un guión final separador)
		- Al crearse un idioma debe generarse directamente sus ficheros de traduccion para cada fichero de script.
		- Al insertar traducciones, si no existe la referencia debe insertarse en blanco (ahora mismo deja la antigua en su lugar)

	Cosas que he hecho hoy:
		- Funcion para cargar en un array todos los scripts .sh
		- Cargar los idiomas desde el mismo archivo script (estan al final del todo)
		- He modificado todo el comportamiento de los idiomas para trabajar sobre el mismo script
		- Al agregar un idioma, pregunta si crear un archivo vacio
		- Modificado el formato de la referencia de comentario 
		- Modificado el intercambio, ahora funciona con el nuevo formato
		- Renumeracion del script original.
		

### 2024-05-31
	He acudido a presentar el trabajo y hemos encontrado varios fallos a solucionar:
		- La validación del patron de idiomas.
		- Cuando se genera un nuevo idioma, el fichero de traducción no se rellena correctamente. A veces atrapa comentarios sin referencias. Estas deben ser ignoradas.
		- Para el intercambio de idiomas ocurre parecido. Debe ignorar las referencias que no estén en el script original, y si en el original existe una referencia que no está en el archivo de traducción, entonces debe dejarse en blanco.
		- Al agregar a las traducciones referencias nuevas hay errores. En concreto con estos patrones:
			Si son comentarios intermedios.
			#XX-11-1
			#XX-21-2
			#3

	Cambios:
		- Cambio de validación de patron. Ahora se realizan dos preguntas. Uno para el prefijo y otro para el nombre e mostrar.
		- El mayor problema es que trabajaba indiscriminadamente con todos los comentarios, cuando en general debía trabajar con comentarios que SOLO tuvieran una referencia. Eso se soluciona ajustado mis busquedas d ecomentarios con grep para tener en cuenta que exista el prefijo correspondiente.
			- Solucionado problema en intercambio de idiomas
			- Solucionado problema con insertado de referencias ADICIONALES nuevas

		- Localizado problema al crear idioma. Si existe un comentario sin referencia y después un con referencia. La ejeución se para en el de sin referencia. SOLUCIONADO! Era un problema relacionado a que ignoraba los comentarios con espacios delante del simbolo #

		- Reenmerar tenia problemas con la REGEX (buscabacomentarios ocn ^# . Estos no atrapan los que van en linea detrás de código).
		- Reenumerar tenia problema en ficheros de traducción, ahora se hace correctamente. Busco la ultima numeración en orden inverso y solo uso la primera coincidencia para evitar soobreescribir las reenumeraciónes que hayan ocurrido antes y puedan coincidir.


### 2024-06-01
	Fin del proyecto. 
		- Hoy me dedico a crear un PDF con las instrucciones e informe del proyecto. 
		- Limpiado del proyecto final. He quitado archivos inutiles y he agregado el PDF
		- Modificado el .gitignore para no agregar los ficheros de traducción generados.

### 2024-06-11
	Puliendo fallos
		- Corregiendo los fallos que existian con algunos caracteres que daban problemas con el uso del sed.
		- Corregido error al pasar parametros a la funcion escape_sed
		- Corregido error al devolver el escape_sed con echo SIN -n

## 2024-06-12
	- Ahora ignora los # que van entre comillas dobles y comillas simples

## 2024-06-13
	- Agregado un indicador de loading basico para generados de referencias
	- Ahora tambien atrapa los # solitarios
	
