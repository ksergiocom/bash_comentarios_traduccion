#!/bin/bash

# ANTES DE EMPEZAR!!
# Aqui está la referencia para la sustitucion de parametros con bash
# http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf
 


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
	echo 
	ascii # Sasonando un poquito
	echo 
    echo 'Sergiy Khudoliy'
    echo `date`
    echo 'v0.3'
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
    cargarIdiomasDisponibles

    echo "Los idiomas disponibles son:"
    for i in "${idiomasDisponibles[@]}"
    do
        echo "$i"
    done
}

function agregarIdioma {
    # Pedir al usuario el prefijo del idioma
    echo 'Dame el prefijo y el nombre del nuevo idioma:'
    echo 'El formato debe ser (XX-Nombre)'
    read nombre
    
    # El prefijo son 2 letras en mayusculas
    patron='^[A-Z]{2}-[A-z]*$'

    # Validacion. Debe tener el patron correcto o vuelve a pedir
    # No compruebo que el idoima ya exista
    until ([[ $nombre =~ $patron ]])
    do
        echo 'El formato proporcionado es incorrecto.'
        echo 'El formato debe ser (XX-Nombre)'
        read nombre
    done

    #Guardar en el archivo de idiomas
    echo "#$nombre" >> $scriptSelfName

    echo "Idioma: $nombre guardado con éxito"

    # Generar nuevos archivos de traduccion?
    echo '¿Quieres generar nuevos ficheros de traducción para este idioma? (N/s)'
    read sn

    # Por defecto NO!
    if [[ $sn = "s" || $sn = "S" ]]
    then
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
            buscarComentarios $file
            
            # Inserto los comentarios existentes en el script con el prefijo de la referencia cambiado
            for comentario in "${comentariosEncontrados[@]}"
            do 
                # Sustituir el prefijo por el idioma nuevo
                comentario=$(echo $comentario | sed "s/^#[A-Z]\{2\}-/#${prefijo}-/")
                # Eliminar todo lo que vaya detras del segundo guion
                comentario=$(echo "$comentario" | sed 's/\(^#[A-Z]\{2\}-[0-9]*-\).*/\1/')
                
                echo "$comentario" >> "$directorioPadre/${prefijo}_${nombreFichero}.txt"
            done

        done
    fi
}

function borrarIdioma {
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


        # Busca todos los comentarios del archivo original script y extrae el numero de linea y comentario
        grep -n -o -E '(^|\s|\t)#[^!].*$' "$file" | while IFS=: read -r numLinea comentario
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
    # Mensaje INFO de ficheros encontrados
    echo
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
                    echo "#${i}_${numeracion}" >> "$path"
                fi

                # Incrementar numeración
                numeracion=$((numeracion+10))
            done
        done

    done
}

function agregarReferenciasAdicionales {    

    buscarFicherosScript
    
    for file in "${ficherosScript[@]}"
    do
        # Para trabajar con los paths
        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")
        
        # Iterar los comentarios
        grep -o -E '(^|\s|\t)#[^!].*$' "$file" | while IFS= read -r comentario
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
                echo '-----------'
                echo "i:$i"
                echo "numero:$numero"
                echo '-----------'

                # ___________ hasta aqui igual que simepre _______________________
                # El path completo de los archivos generados para cada idioma
                pathTraduccion="${directorioPadre}/${i}_${nombreFichero}.txt"
                
                # Compruebo si existe la numeracion en los ficheros de traduccion
                referencia=$(grep -E "#${i}-${numero}-" "$pathTraduccion" | head -n 1 )
                echo $referencia

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
                                sed -i -E "/#${i}-${num_anterior}-/a\\#${i}_${numero}" "$pathTraduccion"
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
    echo 'Pendiente...'
    buscarFicherosScript    

    for file in "${ficherosScript[@]}"
    do
        # La referencia de comentario de cada fichero comienza en 10.
        numeracionBucle=10
        # Iterar los comentarios de cada archivo
        grep -o -E -n '(^|\s|\t)#[^!].*$' "$file" | while IFS=: read -r numLinea comentario
        do
            ######### Sacar datos de los comentarios ################
            # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            # Extraer el prefijo del lenguaje. Empieza en el caracter 1 y coge 2 (asi saco el ES)
            prefijo=${comentario:1:2}
            # Primero elimino el prefijo #
            sinPrefijo=${comentario#*#[A-Z]*_}
            # Para sacar el numero. La parte del principio hasta que no sea un numero. !Ojo los comentairos que empiezen por numero!
            numero="${sinPrefijo%%[^0-9]*}"
            # Texto. Todo lo que vaya detras del numero
            texto="${sinPrefijo#"$numero"}"            
            #########################################################
            
            echo "________________"
            echo "comentario:$comentario"
            echo "prefijo:$prefijo"
            echo "numero:$numero"
            echo "texto:$texto"
            echo "numeracionBucle:$numeracionBucle"


            # El numero de referencia debe coincidir con la variable numeracion
            # que uso en el bucle. Si no es así significa que es una referencia
            # que se ha sido modificada (o falta algun comentario pj.)
            if [[ $numeracionBucle -eq $numero ]]
            then
                # En caso de que coincida NO hay que hacer nada. Todo esta correcto.
                # Saltar al siguiente comentario
                continue
            fi

            # Modificar en el script original el numero antiguo por el nuego que llevo en la variable
            # Buscar todos los ficheros de traduccion que tenga esa numeración
            # Para cada fichero de traducción reemplazar la numeracion
            # Para que sea más rápido busco la linea con grep y hago el sed solo de esa linea.


            numeracionBucle=$(( numeracionBucle + 10 ))
        done
    done
}



# MENUS #############################################################

function menuReferencias {
    local opcion=0

    #validacion
    until ([[ $opcion > 0 && $opcion < 6 ]])
    do
        echo
        echo '---- Referencias ---------------------'
        echo '1) Generar'
        echo '2) Intercambiar'
        echo '3) Agregar adicionales'
        echo '4) Borrar referencias'
        echo '5) Renumerar referencias'
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
	until ([[ $opcion > 0 && $opcion < 6 ]])
    do
        echo
        echo '---- Inicio --------------------------'
        echo '1) Referencias'
        echo '2) Idiomas'
        echo '3) Ayuda'
        echo '4) Test'
        echo '5) Salir'

        read opcion
	done

    # Opciones del menú
    case "$opcion" in
        '1') menuReferencias;;
        '2') menuIdiomas;;
        '3') ayuda;;
        '4') test;;
        '5') exit 0;;
    esac

    menuInicio
}


### TEST ############################################################
function test {
    buscarComentarios './prueba.sh'
    seleccionarIdioma

    for comentario in "${comentariosEncontrados[@]}"
    do 
        # Sustituir el prefijo por el idioma nuevo
        comentario=$(echo $comentario | sed "s/^#[A-Z]\{2\}-/#${idioma}-/")
        # Eliminar todo lo que vaya detras del segundo guion
        comentario=$(echo "$comentario" | sed 's/\(^#[A-Z]\{2\}-[0-9]*-\).*/\1/')
        echo "$comentario"
    done
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
## Se pueden agregar y quitar desde el mismo script.
## NO insertar manualmente! Porque no generaría los
## ficheros de traduccion necesarios.
## DEBE EXISTIR UNA ULTIMA LINEA EN BLANCO, SI NO NO FUNCIONA. NO SE PORQUE!!!!!
##############################
#ES-Español

#EN-Ingles
