#!/bin/bash

#########################################################################################
# Autor:    Sergiy Khudoley
# Fecha:    2024-05-31
# Versión:  0.5
#
# Desc:     Este script busca todos los ficheros .sh de la carpeta en la que se encuentra
#           y realiza una labor de referenciación y traducción de los comentarios que
#           estos conengan. 
#
#           El script guarda dentro de su propio contenido los lenguajes que pueden ser
#           usados, de forma que se puede persistir el agregado o borrado de opciones de
#           lenguajes.
#
#           Por defecto, para el generado de referencias o idiomas nuevas generará los ficheros
#           y referencias necesarias para trabajar. El borrado de idiomas mantendrá los ficheros de 
#           traducción y referencias generadas.
#
#           El script trabaja sobre referencias existentes, cualquier opción salve la de
#           generar nuevas referencias a partir de los comentarios o el borrado de referencias,
#           trabajara SOLO con aquellas referenciadas.
#           
#           ¡Importante! Esta es una versión de prueba. El script se apoya de forma
#           intensiva en el uso de sed, y existen casos en los que los comentarios
#           con los que se trabajen tengan caracteres que den conflictos. No están todos
#           debidamente escapados en todas las situaciónes. Las partes donde es imprecindible
#           escaparlos contiene un código de sustitución que se reoconoce enseguida.
#           Queda pendiente de resolver este inconveniente para poder ser ser funcional.
#
#           ¡Importante! La re-renumeración de los ficheros de traducción solo se aplican si
#           están sincronizados con el script. Si el script ha sido re-numerado correctamente y
#           no necesita re-enumerarse, entonces los ficheros de traducción tampoco lo harán,
#           incluso si les hiciera falta. Esto está pendiente de ser corregido.
#   
#########################################################################################


#########################################################################################
# Declarando las variables globales a usar
#########################################################################################

scriptSelfName=$0 # El nombre de ESTE script para ignorarlo en busquedas de ficheros .sh
dirPath='./' # Donde buscar los ficheros. Modificado!! Ahora trabaja directamente sobre la ruta donde esta el ESTE script.
idioma='ES' # Idioma por defecto

# Esto son arrays que uso como contenedores en las ejecuciones de algunas funciones de abajo.
# Me da bastante rabia que las funciones no puedan retornar valores fuera de los numericos y que me obligue a trabajar con variables globales.
declare -a idiomasDisponibles
declare -a ficherosScript
declare -a ficherosTraduccion 
declare -a comentariosEncontrados



#########################################################################################
# Funciones a utilizar
#########################################################################################



# AUXILIARES ########################################################

function ascii {
echo '.................@@. @@...............'
echo '...............#.      @..............'
echo '...............@   @.  :@.............'
echo '..........@@@:         :@.............'
echo '..............@        ::@............'
echo '..............:        ::@............'
echo '..............@        ::@............'
echo '..............+        .::@...........'
echo '.............@         .:::@..........'
echo '............:.          :::@..........'
echo '............@           ::::@.........'
echo '...........@            .:::@.........'
echo '............@%@          :@...........'
echo '................@ .@.@..@=............'
echo '..................@..@................'
echo '..................@...@...............'
echo '..................@...@...............'
echo '...............@@@@..@@...............'
echo '...................@*@................'
}

function cabecera {
    clear -x

	echo 
	ascii # Sasonando un poquito
	echo 
    echo 'Sergiy Khudoliy'
    # echo `date`
    echo '2024-05-31'
    echo 'v0.5'
    echo 'Internacionalización de comentarios'
    echo
    echo
}

function ayuda {
    clear -x

    echo
    echo '¡Ay, es que me parte el alma,'
	echo 'que muera la esperanza'
	echo 'y toda la dulzura'
	echo 'del amor en tí!'
	echo
    echo '¡Ay! ¿A donde va la calma?'
    echo 'que viva la nostalgia'
    echo 'y que repare el tiempo'
    echo 'lo que en tí rompí'
    echo 
    echo '* De nada por la ayuda emocional'
}


function buscarFicherosScript {
    # Cargar la array de ficheros script con los ficheros encontrados en el $dirPath

    # Como poblar un array con los resultados de un 'find' (Benjamin. W.)
    # https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
    # Voy a excluir al archivo mismo. Necesito pasarle el nombre, no vale el path por eso hago esto:
    # Ojo, esto podría hacer que se excluyan los ficheros que tengan el mismo nombre en otros directorios!
    local selfName=$(basename $scriptSelfName)

    # CUIDADO! Excluyo los que tengan el mismo nombre que este fichero.
    readarray -d '' ficherosScript < <(find "$dirPath" -type f -name "*.sh" ! -name $selfName -print0)
}

function buscarComentarios {
    # Hay que pasarle por parametros el PATH del fichero donde se busca
    local fichero=$1

    # Con grep busco el patron para comentarios
    # Uso la misma tecnica que el anterior para poblar el array.
    readarray comentariosEncontrados < <(grep -o -E '(^|\s|\t)#[^!].*$' $fichero)
}

# Version de la de arriba, solo para los que TENGAN referencias
function buscarComentariosReferenciados {
    local fichero=$1
    readarray comentariosEncontrados < <(grep -o -E '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' $fichero)
}



# IDIOMAS ###########################################################

function cargarIdiomasDisponibles {
    # Limpiar el array
    idiomasDisponibles=()

    # Los idiomas disponibles están al final del fichero. Iteramos el script en orden inverso y leemos los idimas disponibles
    # Cuando llegue al primer comentario que tenga Al menos ## en el comienzo sigfica que hay que parar de buscar idiomas.
    # Los idiomas estan en formato #PrefijoDosLetras-NombreCompleto
    # Luego los almaceno en la array de idiomasDisponibles
    while read linea
    do
        if [[ $linea =~ '##' ]]
        then
            break
        fi
        # El caracter con indice 0 es # siempre, por eso lo quito. Todo lo que vaya a partir del indice 1
        linea=${linea:1}

        idiomasDisponibles+=($linea)

    done < <(tac "$scriptSelfName")
}

function verIdiomasDisponibles {
    clear -x

    cargarIdiomasDisponibles

    echo "Los idiomas disponibles son:"
    for i in "${idiomasDisponibles[@]}"
    do
        echo "$i"
    done
}

function agregarIdioma {
    clear -x

    # Pedir al usuario el prefijo del idioma
    echo 'Dame el prefijo del nuevo idioma:'
    echo 'El formato son 2 letras mayúsculas'
    read prefijoIdioma
    
    # El prefijo son 2 letras en mayusculas
    local patron='^[A-Z]{2}$'

    #Validacion. Debe tener el patron correcto o vuelve a pedir
    #No compruebo que el idoima ya exista
    until ([[ $prefijoIdioma =~ $patron ]])
    do
        echo 'El formato proporcionado es incorrecto.'
        echo 'El formato debe ser 2 letras mayúsculas'
        read prefijoIdioma
    done

    # Pedir al usuario el nombre completo del idioma
    echo 'Dame el nombre completo del nuevo idioma:'
    read nombreIdioma

    # El prefijo son 2 letras en mayusculas
    local patron='^[A-Za-z]+$'

    #Validacion. Debe tener el patron correcto o vuelve a pedir
    #No compruebo que el idoima ya exista
    until ([[ $nombreIdioma =~ $patron ]])
    do
        echo 'El formato proporcionado es incorrecto.'
        echo 'El nombre solo puede contener letras'
        read nombreIdioma
    done

    local nombre="${prefijoIdioma}-${nombreIdioma}"

    #Guardar en el archivo de idiomas
    echo "#$nombre" >> $scriptSelfName

    echo "Idioma: $nombre guardado con éxito"

    # # Generar nuevos archivos de traduccion?
    # echo '¿Quieres generar nuevos ficheros de traducción para este idioma? (N/s)'
    # read sn

    # Por defecto siempre voy a generar un fichero de traducción. Lo dejo comentado por si quisiera implementar la condición.

    # # Por defecto NO!
    # if [[ $sn = "s" || $sn = "S" ]]
    # then

        buscarFicherosScript

        # Prefijo para el archivo
        local prefijo=${nombre:0:2}

        for file in "${ficherosScript[@]}"
        do
            local directorioPadre=$(dirname "$file")
            local nombreFichero=$(basename "$file")

            # Con touch le genero vacio de contenido
            touch "$directorioPadre/${prefijo}_${nombreFichero}.txt"

            # Busco los comentarios del archivo
            buscarComentariosReferenciados $file
            
            # Inserto los comentarios existentes en el script con el prefijo de la referencia cambiado
            for comentario in "${comentariosEncontrados[@]}"
            do 
                ######## Estoy usando nu truco para quitar los posible espacios que tenga el comentario######
                # Esto es una CHAPUZA, habría que cambiarlo. Aquí y en otros sitios que lo reuso.
                # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
                comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
                ##### FIN truco#############


                #Primero comprueba si el comentario tiene el prefijo.
                # Si NO lo tienen, NO debe ser insertado, pasa a comprobar el siguiente comentario.
                if [[ ! $comentario =~ ^#[A-Z]{2}-[0-9]+- ]]
                then
                    continue
                fi

                # Sustituir el prefijo por el idioma nuevo
                comentario=$(echo $comentario | sed "s/^#[A-Z]\{2\}-/#${prefijo}-/")
                # Eliminar todo lo que vaya detras del segundo guion
                comentario=$(echo "$comentario" | sed 's/\(^#[A-Z]\{2\}-[0-9]*-\).*/\1/')
                
                echo "$comentario" >> "$directorioPadre/${prefijo}_${nombreFichero}.txt"
            done

        done
    # fi
}

function borrarIdioma {
    clear -x

    cargarIdiomasDisponibles
    
    echo
    echo '¿Que idioma quieres borrar?'

    # Iteramos los idiomas para mostrar las opciones
    for ((i=0; i<${#idiomasDisponibles[@]}; i++))
    do
        echo "$i)${idiomasDisponibles[$i]}"
    done

    echo
    read idxIdioma

    # Comprobamos la seleccion
    # Si es menor a 0 el indice no deberia ser correcto. Aunque funciona también :D. Si es mayor a len-1 esta fuera del rango.
    if [[ $idxIdioma -lt 0 || $idxIdioma -gt ${#idiomasDisponibles[@]}-1 ]]
    then
        echo 'La opción seleccionada no es correcta'
        # En caso de que sea incorrecto volver a pedir
        borrarIdioma
        # Esto es a modo de clausula de guarda. Termina la ejecucion de la funcion primera que llama a la del reintento...
        # Si no lo pongo se ejecuta la de dentro y luego se ejecuta la funcion padre.... No quiero eso. Quiero parar la padre que es la que no es válida.
        exit 0
    fi
    
    local seleccion=${idiomasDisponibles[$idxIdioma]}
    # Voy a borrar la linea que tenga la coincidencia exacta
    sed -i "/^#$seleccion$/d" $scriptSelfName

    echo "Se ha eliminado el idioma: $seleccion"

}

function seleccionarIdioma {
    clear -x

    cargarIdiomasDisponibles

    echo
    echo '¿Con que idioma quieres realizar la acción?'

    # Iteramos los idiomas para mostrar las opciones
    for ((i=0; i<${#idiomasDisponibles[@]}; i++))
    do
        echo "$i) ${idiomasDisponibles[$i]}"
    done

    echo
    read idxIdioma

    # Comprobamos la seleccion
    # Si es menor a 0 el indice no deberia ser correcto. Aunque funciona también :D. Si es mayor a len-1 esta fuera del rango.
    if [[ $idxIdioma -lt 0 || $idxIdioma -gt ${#idiomasDisponibles[@]}-1 ]]
    then
        echo 'La opción seleccionada no es correcta'
        # En caso de que sea incorrecto volver a pedir
        seleccionarIdioma
        # Esto es a modo de clausula de guarda. Termina la ejecucion de la funcion primera que llama a la del reintento...
        # Si no lo pongo se ejecuta la de dentro y luego se ejecuta la funcion padre.... No quiero eso. Quiero parar la padre que es la que no es válida.
        exit 0
    fi
    
    local seleccion=${idiomasDisponibles[$idxIdioma]}
    # Escojo solo el prefijo de delante (Shell parameter expansion)
    idioma=${seleccion:0:2}

    # Solo a modo informativo le enseño el prefijo y el nombre completo (internamente solo trabajo con el prefijo)
    echo "El idioma con el que se va a trabajar es: $seleccion"

}



# REFERENCIAS #######################################################

function intercambiarComentarios {
    clear -x

    # Seleccionar el idioma
    seleccionarIdioma
    buscarFicherosScript
    
    for file in "${ficherosScript[@]}"
    do
        local directorioPadre=$(dirname "$file")
        local nombreFichero=$(basename "$file")
        # Este es el archivo de traduccion para este archivo de script
        local fileTraduccion="${directorioPadre}/${idioma}_${nombreFichero}.txt"

        if [ ! -f "$fileTraduccion" ]
        then
            echo "Archivo de traduccion no encontrado: $fileTraduccion"
            continue
        fi

        # SOLO intercambiamos comentarios CON referencias creadas!!!
        # Busca todos los comentarios del archivo original script y extrae el numero de linea y comentario
        grep -n -o -E '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS=: read -r numLinea comentario
        do
            # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')

            # Primero elimino el prefijo #
            sinPrefijo=${comentario#*#[A-Z]*-}
            # Para sacar el numero. La parte del principio hasta que no sea un numero. !Ojo los comentairos que empiezen por numero!
            numero="${sinPrefijo%%-*}"
            # Texto. Todo lo que vaya detras del numero
            texto="${sinPrefijo#"$numero"}"

            # Busco dentro del archivo de traducciones el que tenga esa referencia
            traduccion=$(grep -E "${idioma}-${numero}" $fileTraduccion | head -n 1)

                    ### UN AUTENTICO MADMAN ######################
                    # Tengo que escapar los caracteres especiales de bash para poder usarlos en la expresion de sed. Si no, interpreta cosas
                    # y no funciona como se espera.

                    # Uso doble // para que sean sustituiodos todas las coincidencias, no solo uno
                    # Los backslash \ por \\
                    comentarioEscapado=${comentario//\\/\\\\}
                    comentarioConReferencia=${traduccion//\\/\\\\}
                    # Los [ por \[
                    comentarioEscapado=${comentarioEscapado//\[/\\[}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\[/\\\[}
                    # Los $ por \$
                    comentarioEscapado=${comentarioEscapado//\$/\\\$}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\$/\\\$}
                    # Los # por \#
                    comentarioEscapado=${comentarioEscapado//\#/\\\#}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\#/\\\#}
                    # Los ! por \!
                    comentarioEscapado=${comentarioEscapado//\!/\\\!}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\!/\\\!}
                    # Los / por \/
                    comentarioEscapado=${comentarioEscapado//\//\\\/}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\//\\\/}
                    # Los ] por \]
                    comentarioEscapado=${comentarioEscapado//\]/\\\]}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\]/\\\]}
                    # Los * por \*
                    comentarioEscapado=${comentarioEscapado//\*/\\\*}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\*/\\\*}
                    # Los . por \.
                    comentarioEscapado=${comentarioEscapado//\./\\\.}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\./\\\.}
                    # Esto se podrá hacer todo en uno pero ya veremos más adelante si eso.
                    # Y AUN ASI SIGUE FALLANDO?!?!

                    ### BASTA YA #################################

            # Sustituyo el comentario antiguo por la traduccion en la linea especifica. ¿Por que la linea concreta?
            # Así evito que sed recorra todo el archivo y ganamos algo de rendimiento. Si no tendría que leer el archivo entero
            # para cada comentario a insertar.

            if [ -z "$traduccion" ]
            then
                # Si no se encontró la traduccion insertarla vacia
                sed -i "${numLinea}s|$comentarioEscapado|#${idioma}-${numero}-|" $file
            else
                # Si existe modificar la anterior por la traducida
                sed -i "${numLinea}s|$comentarioEscapado|$comentarioConReferenciaEscapado|" $file
            fi

        done
    done

}

function borrarReferencias {
    clear -x

    # Mensaje INFO de ficheros encontrados
    echo 'Se va a proceder a borrar todas las referencias que existen en los ficheros de script'
    echo 

    buscarFicherosScript
    for file in "${ficherosScript[@]}"
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "Borrand las referencias de: $file"
        sed -i -e 's/#\([A-Z]\{1,\}-[0-9]*\)-/#/g' $file        
    done

}

function crearReferencias {
    clear -x 

    echo '¡CUIDADO! Esta opción borra todos los ficheros de traducción y los genera vacios salvo el idioma seleccionado'
    echo '¿Estas seguro realizar esta acción? (N/s)'
    read sn

    # Confirmacion
    if [[ $sn != "S" && $sn != "s" ]]
    then
        menuReferencias
        exit 0
    fi

    seleccionarIdioma

    # Borro todas las referencias que existan en elos originales! A tomar viento!
    borrarReferencias

    buscarFicherosScript # Lo llamo 2 veces (una en buscar y otra aqui.... Pero bueno)

    # Itero cada fichero y generar sus .txt
    for file in "${ficherosScript[@]}"
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "Creando referencias para: $file"

        # Para trabajar con los paths
        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")

        for i in "${idiomasDisponibles[@]}"
        do
            # Antes trabajaba solo con el prefijo, ahora guardo el nombre completo.
            # $i tiene que ser solo el PREFIJO. Voy a extraerlo
            i=${i:0:2}
        
            # El path completo de los archivos generados para cada idioma
            path="${directorioPadre}/${i}_${nombreFichero}.txt"

            # Borrar posibles archivos anteriores.
            # ¿Por que? Porque quiero siempre empezar a insertar comentarios en la linea 1
            # Si creo primero el archivo, se crea una linea vacia. De estsa otra forma cuando hago el primer append. Quizas con touch?
            # se crea el archivo y me quito de problemas. EN CASO NECESARIO; puedo modificar esto sin demasiados cambios.
            if [ -f "$path" ]
            then
                rm "$path"
            fi
            
            
            # Contador de comentarios para cada archivo
            numeracion=10
            # Buscar comentarios.
            # He agregado al grep que me saque la linea separado por :
            # Voy a uscar el IFS para que me separe directamente las variables.
            grep -o -E -n '(^|\s|\t)#[^!].*$' "$file" | while IFS=: read -r numero_linea comentario
            do
                # Tenia problemas al atrapar comentarios que tuvieran un espacio o tabulacion delante.
                # Voy a hacer un truco para solo seleccionar lo que no va detras de espacio o tabulacion
                # Usar sed para capturar solo el grupo 2
                comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!]*.*$)/\2/')

                # Voy a utilizar la sustitución de strings de bash, ya que es infinitamente más rápida
                # que llamar a sed constantemente (al menos probandolo he tenido esos resultados)
                # Pequeño manual de sustitución de parametros con bash:
                # http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf
                
                # Si el idioma iterado es el idioma seleccionado, volcar allí los comentarios
                if [ $i = $idioma ]
                then
                    # Bash params substitution. Aqui cambio el # por #NUMERO
                    # Si uso // me sustituye todo, tenia que usar solo un / para el primer #
                    comentarioConReferencia=${comentario/'#'/"#${i}-${numeracion}-"}

                    ### UN AUTENTICO MADMAN ######################
                    # Tengo que escapar los caracteres especiales de bash para poder usarlos en la expresion de sed. Si no, interpreta cosas
                    # y no funciona como se espera.

                    # Uso doble // para que sean sustituiodos todas las coincidencias, no solo uno
                    # Los backslash \ por \\
                    comentarioEscapado=${comentario//\\/\\\\}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\\/\\\\}
                    # Los [ por \[
                    comentarioEscapado=${comentarioEscapado//\[/\\[}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\[/\\\[}
                    # Los $ por \$
                    comentarioEscapado=${comentarioEscapado//\$/\\\$}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\$/\\\$}
                    # Los # por \#
                    comentarioEscapado=${comentarioEscapado//\#/\\\#}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\#/\\\#}
                    # Los ! por \!
                    comentarioEscapado=${comentarioEscapado//\!/\\\!}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\!/\\\!}
                    # Los / por \/
                    comentarioEscapado=${comentarioEscapado//\//\\\/}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\//\\\/}
                    # Los ] por \]
                    comentarioEscapado=${comentarioEscapado//\]/\\\]}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\]/\\\]}
                    # Los ? por \?
                    # ESTO ME DA PROBLEMAS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    comentarioEscapado=${comentarioEscapado//\?/\\\?}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\?/\\\?}
                    # LO DE ARRIBA NO LO PILLA BIEN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                    # Los * por \*
                    comentarioEscapado=${comentarioEscapado//\*/\\\*}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\*/\\\*}
                    # Los . por \.
                    comentarioEscapado=${comentarioEscapado//\./\\\.}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\./\\\.}
                    # Esto se podrá hacer todo en uno pero ya veremos más adelante si eso.
                    # Y AUN ASI SIGUE FALLANDO?!?!

                    ### BASTA YA #################################

                    sed -i "${numero_linea}s|${comentarioEscapado}|${comentarioConReferenciaEscapado}|" $file
                    echo "$comentarioConReferencia" >> "$path"

                # En caso de no ser el idioma seleccionado solo generar la referencia sin el comentario
                else
                    echo "#${i}-${numeracion}-" >> "$path"
                fi

                # Incrementar numeración
                numeracion=$((numeracion+10))
            done
        done

    done
}

function agregarReferenciasAdicionales {    
    clear -x

    buscarFicherosScript
    
    for file in "${ficherosScript[@]}"
    do
        # Para trabajar con los paths
        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")
        
        # Iterar los comentarios
        grep -o -E '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS= read -r comentario
        do
            ############ Para extraer datos #######################

            # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            
            # Extraer el prefijo del lenguaje. Empieza en el caracter 1 y coge 2 (asi saco el ES)
            prefijo=${comentario:1:2}

            # Primero elimino el prefijo #
            sinPrefijo=${comentario#*#[A-Z]*-}
            # Para sacar el numero. La parte del principio hasta que no sea un numero. !Ojo los comentairos que empiezen por numero!
            numero="${sinPrefijo%%-*}"

            # Texto. Todo lo que vaya detras del numero
            texto="${sinPrefijo#"$numero"}"



            #######################################################

            # Para cada idioma existe su propio fichero de traduccion
            for i in "${idiomasDisponibles[@]}"
            do
                # Necesito solo sacar el prefijo
                i=${i:0:2}



                # ___________ hasta aqui igual que simepre _______________________
                # El path completo de los archivos generados para cada idioma
                pathTraduccion="${directorioPadre}/${i}_${nombreFichero}.txt"
                
                # Compruebo si existe la numeracion en los ficheros de traduccion
                referencia=$(grep -E "#${i}-${numero}-" "$pathTraduccion" | head -n 1 )


                if [ -z "$referencia" ]
                then

                    # Lo que voy a hacer es buscar el numero inmediatamente anterior e insertar este comentario justo delante en los archivos de traduccion.
                    # Para encontrar el anterior voy a ir decrementando el numero hasta que coincida con algo.

                    # Inicializamos un contador para decrementar el número
                    num_anterior=$((numero - 1))
                    
                    ########### POR AQUI ANDA LA MOVIDINHA ##################
                    # Buscamos la referencia anterior con un bucle while
                    while [ $num_anterior -ge 0 ]
                    do
                        referencia_anterior=$(grep -E "#${i}-${num_anterior}-" "$pathTraduccion"| head -n 1)
                        
                        # Si encontramos una referencia anterior, insertamos el nuevo comentario justo después de ella
                        if [ -n "$referencia_anterior" ]
                        then
                            # Comprobar si el idioma del comentario en el script coincid con el archivo. En ese caso tiene
                            # que insertar el coentario completo
                            if [ $prefijo = $i ]
                            then
                                sed -i -E "/#${i}-${num_anterior}-/a\\${comentario}" "$pathTraduccion"
                                break
                            # En caso contrario simplemente inserta la referencia sin el texto
                            else
                                sed -i -E "/#${i}-${num_anterior}-/a\\#${i}-${numero}-" "$pathTraduccion"
                                break
                            fi
                        fi
                        
                        # Decrementamos el contador para buscar la siguiente referencia anterior
                        num_anterior=$((num_anterior - 1))
                    done
                fi


            done            
        done
    done
}

function renumerarReferencias {
    clear -x

    buscarFicherosScript    

    for file in "${ficherosScript[@]}"
    do
        # La referencia de comentario de cada fichero debe comenzar en 10.
        numeracionBucle=10

        # SOLO voy a reenumerar los comentarios que ya TENGAN una referencia.
        # Si no tienen refernecias no tengo que re-renumerar nada. Hasta que está no exista ese comentario se deja TAL CUAL.


        # Iterar los comentarios referenciados de cada archivo. (Saco n.linea y el comentario.)
        grep -o -E -n '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS=: read -r numLinea comentario
        do
            ######### Sacar datos de los comentarios ################
            # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            # Extraer el prefijo del lenguaje. Empieza en el caracter 1 y coge 2 (asi saco el ES)
            prefijo=${comentario:1:2}
            # Primero elimino el prefijo #
            sinPrefijo=${comentario#*#[A-Z]*-}
            # Para sacar el numero. La parte del principio hasta que no sea un numero. !Ojo los comentairos que empiezen por numero!
            numero="${sinPrefijo%%-*}"
            # Texto. Todo lo que vaya detras del numero
            texto="${sinPrefijo#"$numero"}"            

            #########################################################

            # El numero de referencia del comentario debe coincidir con la variable numeracion
            # que uso en el bucle. Si no es así significa que es una referencia
            # que se ha sido modificada (o falta algun comentario pj.) En definitiva, hay que 
            # cambiarle la numeracion 
            if [[ $numeracionBucle -eq $numero ]]
            then
                # En caso de que coincida NO hay que hacer nada. Todo esta correcto.
                # Saltar al siguiente comentario

                # Si hace continuo no sube la numeración! Tengo que hacerlo aquí también
                numeracionBucle=$(( numeracionBucle + 10 ))
                # Saltar a siguiente iteración.
                continue
            fi
            

            # Este es el caso de que en numero de referencia != numeracionBucle
            # Hay que actualizar la numeracion en el script al numero nuevo.
            # Tambien el los ficheros de traduccion.

            # 1- Modificar en el script original el numero antiguo por el nuego que llevo en la variable
            sed -i "${numLinea}s/#${prefijo}-${numero}-/#${prefijo}-${numeracionBucle}-/" $file
            
            # Buscar todos los ficheros de traduccion que tenga esa numeración
            for i in "${idiomasDisponibles[@]}"
            do
                # Pillar prefijo
                i=${i:0:2}

                # Para trabajar con los paths
                directorioPadre=$(dirname "$file")
                nombreFichero=$(basename "$file")
                pathTraduccion="${directorioPadre}/${i}_${nombreFichero}.txt"
                
                # Primero localizo el numero de linea en la que está dicha referencia.
                # Esto es necsario para no hacer trabajar a sed sobre todo el fichero de traducción
                # si no solo sobre una única linea. De otra forma cada referencia que queramos editar tendría que leer
                # el archivo de traducción completo una y otra vez.

                # Por otro lado, también puede darse el caso que cambiada una linea, la siguiente tenga la misma numeración.
                # Por ejemplo. la linea 15 pasa a ser la 20 y la siguiente es la 20. Especificando la línea evito este problema.
                
                # Para resolver este problema voy a escoger el numero que coincida empezando desde atrás.
                
                numLineaUltima=$(grep -n "#${i}-${numero}-" "$pathTraduccion" | tac | head -n 1)
                numLineaUltima=${numLineaUltima%%:*}
                
                # Si se encontró una línea, modificar esa línea específica.
                if [[ -n $numLineaUltima ]]
                then
                    sed -i "${numLineaUltima}s/#${i}-${numero}-/#${i}-${numeracionBucle}-/" "$pathTraduccion"
                fi

            done




            numeracionBucle=$(( numeracionBucle + 10 ))
        done
    done
}



# MENUS #############################################################

function menuReferencias {
    clear -x

    local opcion=0

    #validacion
    until ([[ $opcion > 0 && $opcion < 7 ]])
    do
        echo
        echo '---- Referencias ---------------------'
        echo '1) Nuevos ficheros de traducción'
        echo '2) Intercambiar por otro idioma'
        echo '3) Agregar comentarios adicionales a fichero de traducción'
        echo '4) Borrar referencias'
        echo '5) Re-enumerar'
        echo '6) Atras'
        echo

        read opcion
    done 

    case "$opcion" in 
        '1') crearReferencias;;
        '2') intercambiarComentarios;;
        '3') agregarReferenciasAdicionales;;
        '4') borrarReferencias;;
        '5') renumerarReferencias;;
        '6') 
            clear -x
            menuInicio
        ;;
    esac
}

function menuIdiomas {
    clear -x

    local opcion=0

    #validacion
    until ([[ $opcion > 0 && $opcion < 5 ]])
    do
        echo
        echo '---- Idiomas -------------------------'
        echo '1) Agregar'
        echo '2) Borrar'
        echo '3) Ver disponibles'
        echo '4) Atras'
        echo

        read opcion
    done 

    case "$opcion" in 
        '1') agregarIdioma;;
        '2') borrarIdioma;;
        '3') verIdiomasDisponibles;;
        '4') 
            clear -x
            menuInicio
        ;;
    esac
}

function menuInicio {

    local opcion=0

    # Validación de que se ha escogido una opción correcta
	until ([[ $opcion > 0 && $opcion < 5 ]])
    do
        echo
        echo '---- Inicio --------------------------'
        echo '1) Referencias'
        echo '2) Idiomas'
        echo '3) Ayuda'
        echo '4) Salir'

        read opcion
	done

    # Opciones del menú
    case "$opcion" in
        '1') menuReferencias;;
        '2') menuIdiomas;;
        '3') ayuda;;
        '4') exit 0;;
    esac

    menuInicio
}


#####################################################################
# Inicio de ejecución del script
#####################################################################

# Ejecución
cargarIdiomasDisponibles
cabecera
menuInicio



##############################
## Idiomas disponibles
## Se puede pero NO DEBE agregar y quitar desde el mismo script.
## NO insertar manualmente! Porque NO generaría los
## ficheros de traduccion necesarios.
## DEBE EXISTIR UN SALTO DE LINEA AL FINAL DEL ULTIMO IDIOMA, SI NO, NO FUNCIONA.
##############################
#EN-Inglés
#ES-Español
