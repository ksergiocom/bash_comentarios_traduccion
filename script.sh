#!/bin/bash

idioma='ES'
declare -a idiomasDisponibles 
declare -a ficherosScript
declare -a ficherosTraduccion 
declare -a comentariosEncontrados
#########################################################################################
# Funciones a utilizar
#########################################################################################



# AUXILIARES ########################################################

spinner=('processing   ' 'processing.  ' 'processing.. ' 'processing...')
function spin {
    # Loop infinito hasta que haga kill del proceso
    while [ 1 ]
    do
        for i in "${spinner[@]}"
        do
            echo -ne "\r$i"
            sleep 0.5
        done
    done
}

# Funcion para carga los scripts con los que vamos a trabajar
function buscarFicherosScript {
    # Se busca por extension e ignoro este archivo.
    readarray -d '' ficherosScript < <(find "./" -type f -name "*.sh" ! -wholename $0 -print0)
}

# Funcion para cargar los comentarios de un script (Pendiente actualizar)
function buscarComentarios {
    local fichero=$1

    readarray comentariosEncontrados < <(grep -o -E '(^|\s|\t)#[^!].*$' $fichero)
}

# Funcion para cargar los comentarios referenciados de un script (Pendiente pasar a buscarComentarios y hacer esto con un flag)
#### REFACTOR ##############
function buscarComentariosReferenciados {
    local fichero=$1

    readarray comentariosEncontrados < <(grep -o -E '(^|\s|\t)#[^!][A-Z]{,2}-[0-9]*-.*$' $fichero)
}
############################

# Funcion para tratar un string para poder ser usada en sed.
function escapeSed {
    local str="$1"

    str=${str//\\/\\\\}   # \
    str=${str//\$/\\\$}   # $
    str=${str//\./\\\.}   # .
    str=${str//\*/\\\*}   # *
    str=${str//\[/\\\[}   # [
    str=${str//\]/\\\]}   # ]
    str=${str//\^/\\\^}   # ^
    str=${str//\//\\\/}   # /
    str=${str//\(/\\\(}   # (
    str=${str//\)/\\\)}   # )
    str=${str//\{/\\\{}   # {
    str=${str//\}/\\\}}   # }
    str=${str//\|/\\\|}   # |
    str=${str//\+/\\\+}   # +
    str=${str//\?/\\\?}   # ?
    str=${str//\"/\\\"}   # "
    str=${str//\&/\\\&}   # &

    str=${str//$'\n'/\\n} # Newline (LF)
    str=${str//$'\r'/\\r} # Carriage Return (CR)

    echo -n "$str"
}



# IDIOMAS ###########################################################

# Funcion para cargar los idiomas disponibles
# Carga un string tipo Prefijo-Nombre
function cargarIdiomasDisponibles {
    idiomasDisponibles=()

    # Los comentarios se encuentran al final de este script. Itero de forma inversa con tac
    while read linea
    do
        if [[ $linea =~ '##' ]]
        then
            break
        fi

        # Eliminar el # del prefijo
        linea=${linea:1}

        idiomasDisponibles+=($linea)

    done < <(tac "$0")
}

# Funcion para imprimir por pantalla los idiomsa disponibles
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

    echo 'Dame el prefijo del nuevo idioma:'
    echo 'El formato son 2 letras mayúsculas'
    read prefijoIdioma
    

    # Validacion
    local patron='^[A-Z]{2}$'
    until ([[ $prefijoIdioma =~ $patron ]])
    do
        echo 'El formato proporcionado es incorrecto.'
        echo 'El formato debe ser 2 letras mayúsculas'
        read prefijoIdioma
    done

    # Solicitando nombre
    echo 'Dame el nombre completo del nuevo idioma:'
    read nombreIdioma

    # Validacion
    local patron='^[A-Za-z]+$'
    until ([[ $nombreIdioma =~ $patron ]])
    do
        echo 'El formato proporcionado es incorrecto.'
        echo 'El nombre solo puede contener letras'
        read nombreIdioma
    done

    # Guardando idioma
    local nombre="${prefijoIdioma}-${nombreIdioma}"
    echo "#$nombre" >> $0

    clear -x

    echo "Idioma: $nombre guardado con éxito"


    ########## Generar nuevos archivos de traducción ###########
    echo "Generando nuevos ficheros de traduccion para el idioma: $nombre"

    buscarFicherosScript

    for file in "${ficherosScript[@]}"
    do
        # Necesario para trabajar con los paths
        local directorioPadre=$(dirname "$file")
        local nombreFichero=$(basename "$file")

        # Generando el fichero para cada script
        touch "$directorioPadre/${prefijoIdioma}_${nombreFichero}.txt"

        buscarComentariosReferenciados $file
        
        # Inserto los comentarios existentes en el script con el prefijo de la referencia cambiado
        for comentario in "${comentariosEncontrados[@]}"
        do 
            ### REFACTOR #########
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            ##################


            # Si NO esta referenciado no hay que guardarlo en el fichero de traduccion
            if [[ ! $comentario =~ ^#[A-Z]{2}-[0-9]+- ]]
            then
                continue
            fi

            # Sustituir el prefijo por el idioma nuevo
            comentario=$(echo $comentario | sed "s/^#[A-Z]\{2\}-/#${prefijoIdioma}-/")
            # Eliminar todo lo que vaya detras del segundo guion
            comentario=$(echo "$comentario" | sed 's/\(^#[A-Z]\{2\}-[0-9]*-\).*/\1/')
            
            echo "$comentario" >> "$directorioPadre/${prefijoIdioma}_${nombreFichero}.txt"
        done

    done
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
    until [[ $idxIdioma -ge 0 && $idxIdioma -le ${#idiomasDisponibles[@]}-1 ]]
    do
        echo 'La opción seleccionada no es correcta'
        echo '¿Que idioma quieres borrar?'
        read idxIdioma

    done
    
    local seleccion=${idiomasDisponibles[$idxIdioma]}
    # Voy a borrar la linea que tenga la coincidencia exacta
    sed -i "/^#$seleccion$/d" $0

    clear -x

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
    until [[ $idxIdioma -ge 0 || $idxIdioma -le ${#idiomasDisponibles[@]}-1 ]]
    do
        echo 'La opción seleccionada no es correcta'
        echo '¿Con que idioma quieres realizar la acción?'
        read idxIdioma

    done
    
    local seleccion=${idiomasDisponibles[$idxIdioma]}
    # Escojo solo el prefijo de delante (Shell parameter expansion)
    idioma=${seleccion:0:2}

    # Solo a modo informativo le enseño el prefijo y el nombre completo (internamente solo trabajo con el prefijo)
    echo "El idioma con el que se va a trabajar es: $seleccion"

}



# REFERENCIAS #######################################################

function intercambiarComentarios {
    clear -x

    seleccionarIdioma
    buscarFicherosScript
    
    echo 'Intercambiando comentarios'

    # Indicador de que el proceso corre
    spin & spinPid=$!

    for file in "${ficherosScript[@]}"
    do
        local directorioPadre=$(dirname "$file")
        local nombreFichero=$(basename "$file")
        local fileTraduccion="${directorioPadre}/${idioma}_${nombreFichero}.txt" # Este es el archivo de traduccion para este archivo de script

        clear -x

        if [ ! -f "$fileTraduccion" ]
        then
            echo "Archivo de traduccion no encontrado: $fileTraduccion"
            continue
        fi

        # SOLO intercambiamos comentarios CON referencias
        # Busca todos los comentarios del archivo original script y extrae el numero de linea y comentario
        grep -n -o -E '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS=: read -r numLinea comentario
        do
            ##### REFACTOR ###########
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            ##########################

            # Extrayendo datos de la referencia
            sinPrefijo=${comentario#*#[A-Z]*-}
            numero="${sinPrefijo%%-*}"
            texto="${sinPrefijo#"$numero"}"

            # Busco dentro del archivo de traducciones el que tenga esa numeracion
            ###### REFACTOR ############
            traduccion=$(grep -E "${idioma}-${numero}" $fileTraduccion | head -n 1)
            ############################

            comentarioEscapado=$(escapeSed "$comentario")
            comentarioConReferenciaEscapado=$(escapeSed "$traduccion")

            # Sustituyo el comentario antiguo por la traduccion en la linea especifica. 
            if [ -z "$traduccion" ]
            then
                # Si no se encontró la traduccion insertarla vacia
                sed -E -i "${numLinea}s@$comentarioEscapado@#${idioma}-${numero}-@" $file
            else
                # Si existe modificar la anterior por la traducida
                sed -E -i "${numero_linea}s@${comentarioEscapado}@${comentarioConReferenciaEscapado}@" $file
            fi

        done
    done
    kill $spinPid

    echo 'Se han sustituidos los comentarios correctamente'

}

function borrarReferencias {
    clear -x

    # Mensaje INFO de ficheros encontrados
    echo 'Se va a proceder a borrar todas las referencias que existen en los ficheros de script'
    echo 

    buscarFicherosScript
    
    # Indicador de que el proceso corre
    spin & spinPid=$!

    for file in "${ficherosScript[@]}"
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "Borrand las referencias de: $file"
        sed -i -e 's/#\([A-Z]\{1,\}-[0-9]*\)-/#/g' $file        
    done

    kill $spinPid
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
    borrarReferencias

    ### REFACTOR ########
    buscarFicherosScript # Lo llamo 2 veces (una en buscar y otra aqui.... Pero bueno)
    ######################

    # Indicador de que el proceso corre
    spin & spinPid=$!

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
            ### REFACTOR #######
            i=${i:0:2}
            ####################

            # El path completo de los archivos generados para cada idioma
            path="${directorioPadre}/${i}_${nombreFichero}.txt"

            # Borrar posibles archivos anteriores.
            if [ -f "$path" ]
            then
                rm "$path"
            fi
            
            
            # Contador de comentarios para cada archivo
            numeracion=10
            # Buscar comentarios y extraemos su linea y numero de linea

            ### REFACTOR ############
            grep -E -n '(^|\s|\t)#[^!].*$' "$file" | while IFS=: read -r numero_linea linea
            do

                # Vamos a extraer el comentario de la linea
                comentario=""
                previousC=""
                parteParaQuitar=()

                # Si empieza por # es un comentario
                if [[ ${linea:0:1} == "#" ]]
                then
                    comentario="$linea"

                # En caso contrario limpiar la linea de posibles # dentro de comillas
                # Si itero la linea y aparece una comilla hay que ignornar todo hasta que encuentre la siguiente comilla doble.
                else
                    dentroComillas=""
                    dentroComillasSimples=""
                    
                    # Itero caracter a caracter la linea
                    for (( j=0; j<${#linea}; j++ ))
                    do
                        # El caracter iterado
                        c="${linea:j:1}"

                        # Si es una comilla DOBLE
                        if [[ "$c" == "\"" ]]
                        then
                            if [[ -z "$dentroComillas" ]]
                            then
                                dentroComillas="1"
                            else
                                dentroComillas=""
                            fi
                        fi

                        # Si es una comilla SIMPLE
                        if [[ "$c" == "'" ]]
                        then
                            if [[ -z "$dentroComillasSimples" ]]
                            then
                                dentroComillasSimples="1"
                            else
                                dentroComillasSimples=""
                            fi
                        fi
                        
                        # Si se cumple esto, TERMINA de buscar
                        if [[ "$c" == "#" && -z "$dentroComillas" && -z $dentroComillasSimples && "$previousC" =~ [[:space:]] ]]
                        then
                            comentario="${linea:j}"
                            break
                        fi

                        # Agregar al array la parte que hay que quitar
                        parteParaQuitar+=("$c")
                        # Guardar el caracter para la siguiente iteracion. Necesario para comprobar que el # este precedido de un espacio
                        previousC="$c"
                    done
                fi

                ### REFACTOR ##########
                comentario=$(echo "$comentario" | sed 's/^[[:space:]]*//')
                #######################

                # Después de limpiar puede quedar vacio, en ese caso simplemente ingoralo.
                if [[ -z "$comentario" ]]
                then
                    continue
                fi

                # Si el idioma iterado es el idioma seleccionado, volcar allí los comentarios
                if [ $i = $idioma ]
                then
                    # Cambio el # por #NUMERO
                    comentarioConReferencia=${comentario/'#'/"#${i}-${numeracion}-"}

                    comentarioEscapado=$(escapeSed "$comentario")
                    comentarioConReferenciaEscapado=$(escapeSed "$comentarioConReferencia")

                    sed -E -i "${numero_linea}s@${comentarioEscapado}@${comentarioConReferenciaEscapado}@" $file
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

    kill $spinPid
}

function agregarReferenciasAdicionales {    
    clear -x

    buscarFicherosScript
    
    # Indicador de que el proceso corre
    spin & spinPid=$!

    for file in "${ficherosScript[@]}"
    do
        # Para trabajar con los paths
        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")
        
        # Iterar los comentarios
        grep -o -E '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS= read -r comentario
        do
            ############ REFACTOR #######################

            # Para eliminar el espacio de delante lo hago seleccionado el segundo grupo.
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            #############################################

            # Extrayedo datos de la referencia
            prefijo=${comentario:1:2}
            sinPrefijo=${comentario#*#[A-Z]*-}
            numero="${sinPrefijo%%-*}"
            texto="${sinPrefijo#"$numero"}"

            # Para cada idioma existe su propio fichero de traduccion
            for i in "${idiomasDisponibles[@]}"
            do
                # REFACTOR####
                i=${i:0:2}
                ##############

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
                    
                    while [ $num_anterior -ge 0 ]
                    do
                        ### REFACTOR ######
                        referencia_anterior=$(grep -E "#${i}-${num_anterior}-" "$pathTraduccion"| head -n 1)
                        ###################

                        # Si encontramos una referencia anterior, insertamos el nuevo comentario justo después de ella
                        if [ -n "$referencia_anterior" ]
                        then
                            # Comprobar si el idioma del comentario en el script coincid con el archivo. En ese caso tiene
                            # que insertar el comentario completo
                            if [ $prefijo = $i ]
                            then
                                sed -E -i "/#${i}-${num_anterior}-/a\\${comentario}" "$pathTraduccion"
                                break
                            # En caso contrario simplemente inserta la referencia sin el texto
                            else
                                sed -E -i "/#${i}-${num_anterior}-/a\\#${i}-${numero}-" "$pathTraduccion"
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

    kill $spinPid

    echo 'Se han agregado los comentarios adicionales'
}

function renumerarReferencias {
    clear -x

    buscarFicherosScript    

    # Indicador de que el proceso corre
    spin & spinPid=$!

    for file in "${ficherosScript[@]}"
    do
        # La referencia de comentario de cada fichero debe comenzar en 10.
        numeracionBucle=10

        # SOLO voy a reenumerar los comentarios que ya TENGAN una referencia.
        # Si no tienen refernecias no tengo que re-renumerar nada. Hasta que está no exista ese comentario se deja TAL CUAL.

        ### REFACTOR #####
        grep -o -E -n '(^|\s|\t)#[^!][A-Z]-[0-9]*-.*$' "$file" | while IFS=: read -r numLinea comentario
        do
            ### REFACTOR #####
            comentario=$(echo "$comentario" | sed -E 's/(^|\s|\t)(#[^!].*$)/\2/')
            ##################

            # Extraer datos de la referencia
            prefijo=${comentario:1:2}
            sinPrefijo=${comentario#*#[A-Z]*-}
            numero="${sinPrefijo%%-*}"
            texto="${sinPrefijo#"$numero"}"            

            # El numero de referencia del comentario debe coincidir con la variable numeracion
            # que uso en el bucle. Si no es así significa que es una referencia
            # que se ha sido modificada (o falta algun comentario pj.)
            if [[ $numeracionBucle -eq $numero ]]
            then
                # En caso de que coincida NO hay que hacer nada. Todo esta correcto.
                # Saltar al siguiente comentario

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
                # Por otro lado, también puede darse el caso que cambiada una linea, la siguiente tenga la misma numeración.
                # Por ejemplo. la linea 15 pasa a ser la 20 y la siguiente es la 20. Especificando la línea evito este problema.
                # Para resolver este problema voy a escoger el numero que coincida empezando desde atrás.
                
                ### REFACTOR #####
                numLineaUltima=$(grep -n "#${i}-${numero}-" "$pathTraduccion" | tac | head -n 1)
                numLineaUltima=${numLineaUltima%%:*}
                ######

                # Si se encontró una línea, modificar esa línea específica.
                if [[ -n $numLineaUltima ]]
                then
                    sed -i "${numLineaUltima}s/#${i}-${numero}-/#${i}-${numeracionBucle}-/" "$pathTraduccion"
                fi

            done




            numeracionBucle=$(( numeracionBucle + 10 ))
        done
    done

    kill $spinPid

    echo 'Se ha generado una numeración nueva'
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
        echo '4) Salir'

        read opcion
	done

    # Opciones del menú
    case "$opcion" in
        '1') menuReferencias;;
        '2') menuIdiomas;;
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
#EN-Ingles
#ES-Español
#CH-Chino
