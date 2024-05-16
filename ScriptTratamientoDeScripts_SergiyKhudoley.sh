#!/bin/bash

# ANTES DE EMPEZAR!!
# Aqui está la referencia para la sustitucion de parametros con bash
# http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf
 



#########################################################################################
# Declarando las variables globales a usar
#########################################################################################

dirPath=$1
idioma='ES'
declare -a idiomasDisponibles

#########################################################################################



#########################################################################################
# Toda esta parte es para leer y almacenar idiomas de forma persistente
#########################################################################################
# Necesito inicializar esto antes de poder usar mi Storage de idiomas
# Esta función genera un archivo oculto que contendrá todos
# los idiomas disponibles para trabajar, para que se 
# puedan agregar y quitar idiomas de forma dinámimca y 
# perduren entre ejecuciones.
function crearIdiomasStorage {
    local file='./.idiomas'

    # En caso de no existir crearlo de nuevo
    if [ ! -f './.idiomas' ]
    then
        touch .idiomas
        # Idiomas por defecto
        echo 'ES' >> './.idiomas'
        echo 'EN' >> './.idiomas'
    fi
}

# Lo necesito utilizar en las operaciones de guardar o borrar idiomas
function cargarIdiomasDisponibles {
    # Poblando un array a partir de un archivo. A partir de bash 4.0 con "readarray"
    # pero voy a usar una función alternativa FREESTYLE!
    # Lo he sacado de aqui. ¿De verdad necesito que sea compatible con versiones viejas?
    # https://stackoverflow.com/questions/11393817/read-lines-from-a-file-into-a-bash-array
    fileItemString=$(cat  './.idiomas' |tr "\n" " ")
    idiomasDisponibles=($fileItemString)
}

# Antes de iniciarlizar el script cargo la variable local
cargarIdiomasDisponibles

#########################################################################################





#########################################################################################
# Funciones a utilizar
#########################################################################################


# AUXILIARES ----------------------------------------------------------

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
}

# IDIOMAS ----------------------------------------------------------

function verIdiomasDisponibles {
    echo "Los idiomas disponibles son:"
    for i in "${idiomasDisponibles[@]}"
    do
        echo "$i"
    done
}

function agregarIdioma {
    # Pedir al usuario el prefijo del idioma
    read -p "Dame el prefijo del idioma nuevo:" nombre
    
    # El prefijo son 2 letras en mayusculas
    patron='^[A-Z]{2}$'

    # Validacion. Debe tener el patron correcto o vuelve a pedir
    # No compruebo que el idoima ya exista
    until ([[ $nombre =~ $patron ]])
    do
        echo 'El idioma debe ser 2 letras en mayúsculas'
        read -p "Dame el prefijo del idioma nuevo:" nombre
    done

    #Guardar en el archivo de idiomas
    echo $nombre >> './.idiomas'

    echo "Idioma $nombre guardado con éxito"

    cargarIdiomasDisponibles
}

function borrarIdioma {
    # Pedir al usuario el prefijo del idioma
    read -p "Dame el prefijo del idioma a borrar:" nombre
    
    # El prefijo son 2 letras en mayusculas
    patron='^[A-Z]{2}$'

    # Validacion. Debe tener el patron correcto o vuelve a pedir
    # No compruebo que el idoima ya exista
    until ([[ $nombre =~ $patron ]])
    do
        echo 'El idioma debe ser 2 letras en mayúsculas'
        read -p "Dame el prefijo del idioma a borrar:" nombre
    done

    # Aqui si que voy a borrar directamente con sed
    sed -i -e "s/$nombre//g" './.idiomas'

    echo "Idioma $nombre borrado"

    cargarIdiomasDisponibles
}

function seleccionarIdioma {
    echo
    echo '¿Con que idioma quieres realizar la acción?'

    # Esta hecho con un for con un indice porque primero iba hacerlo por seleccion numérica
    # posteriormente decidi cambiarlo al prefijo entero porque era más fácil la validación
    for ((i=0; i<${#idiomasDisponibles[@]}; i++))
    do
        echo "${idiomasDisponibles[i]}"
    done

    echo
    read idioma

    until [[ ${idiomasDisponibles[@]} =~ $idioma ]]
    do
        echo
        echo 'El idioma seleccionado NO es válido'
        echo 'Debes escribir exactamente 2 letras en mayúsculas'
        echo 'Los idiomas disponibles son:'

        for ((i=0; i<${#idiomasDisponibles[@]}; i++))
        do
            echo "${idiomasDisponibles[i]}"
        done
        echo
        read idioma
    done

}

# REFERENCIAS ----------------------------------------------------------

function intercambiarComentarios {
    # Seleccionar el idioma
    seleccionarIdioma
    # Buscar los comentarios traducidos
    find "$dirPath" -type f -name "${idioma}_*.sh.txt" | while read file
    do
        # Para cada fichero puede existir su fichero .log con los errores de inserción
        local pathLogs="${file}.log"
        if [ -f "$pathLogs" ]
        then
            rm "$pathLogs"
        fi


        # El nombre del script relacionado con el fichero de comentarios generado
        # Hay que separar el "XX_" de delante y ".txt" del final. La parte intermedia
        # será el nombre del fichero original

        # El grupo 1 captura el path y el grupo 2 captura el nombre del archivo SIN el prefijo y extension .txt
        # Con sed puedo especificar el 1 y 2 para concatenarlos.
        nombreScript=$(echo "$file" | sed 's|\(.*\/\)[A-Z]\{2\}_\(.*\)\.txt$|\1\2|')

        # Iterar sobre cada comentario
        while read -r comentario
        do
            # Escapando los caracteres epseciales del comenetario
            # comentario=$(printf "%q" "$variable")

            # Numeracion del comentario
            numero=$(echo "$comentario" | sed "s|^#${idioma}_\([0-9]\+\).*|\1|")
            # Contenido del comentario
            texto=$(echo "$comentario" | sed "s|^#${idioma}_[0-9]\+||")

            #Escapando caracteres especiales
            comentario=$(printf "%q" "$comentario")

            # Ahora que tengo las dos partes por separadas puedo buscar el comentario que tnega esa numeración en el archivo original
            # y reemplazar con sed ese comenario por el nuevo generado.
            sed -i "s|#[A-Z]\{2,\}_$numero.*|$comentario|" $nombreScript
        done < $file
    done

}

function borrarReferencias {
    # Mensaje INFO de ficheros encontrados
    echo
    echo 'Se va a proceder a borrar todas las referencias que existen en los ficheros de script'
    echo 

    # Itero cada fichero y generar sus .txt
    # Se puede pasar el resultado de un comando al while de esta forma:
    # https://stackoverflow.com/questions/2983213/input-of-while-loop-to-come-from-output-of-command
	find "$dirPath" -type f -name "*.sh" | while read file
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "Borrand las referencias de: $file"
        sed -i -e 's/#\([A-Z]\{1,\}_[0-9]*\)*/#/g' $file

    done
}

function crearReferencias {

    seleccionarIdioma

    # Borro todas las referencias que existan en elos originales! A tomar viento!
    borrarReferencias

    # Mensaje INFO de ficheros encontrados
    echo
    echo "Se han extraido los comentarios de los ficheros .sh encontrados en $dirPath"
    echo "Los nuevos ficheros tienen la extensión *.txt"
    echo 

    # Itero cada fichero y generar sus .txt
    # Se puede pasar el resultado de un comando al while de esta forma:
    # https://stackoverflow.com/questions/2983213/input-of-while-loop-to-come-from-output-of-command
	find "$dirPath" -type f -name "*.sh" | while read file
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "Creando referencias para: $file"

        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")

        for i in "${idiomasDisponibles[@]}"
        do
            echo "${directorioPadre}/${i}_${nombreFichero}.txt"

            # El path completo de los archivos generados para cada idioma
            path="${directorioPadre}/${i}_${nombreFichero}.txt"

            # Borrar posibles archivos anteriores.
            # ¿Por que? Porque quiero siempre empezar a insertar comentarios en la linea 1
            # Si creo primero el archivo, se crea una linea vacia. De estsa otra forma cuando hago el primer append
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
            
            # Esto es si quiero ignorar las almohadillas solas
            grep -o -E -n '(^|\s|\t)#[^!#].*$' "$file" | while IFS=: read -r numero_linea comentario
            do
                # Voy a utilizar la sustitución de strings de bash, ya que es infinitamente más rápida
                # que llamar a sed constantemente (al menos probandolo he tenido esos resultados)
                # Pequeño manual de sustitución de parametros con bash:
                # http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf

                # Si el idioma iterado es el idioma seleccionado, volcar allí los comentarios
                if [ $i = $idioma ]
                then
                    # Bash params substitution. Aqui cambio el # por #IDIOMA_NUMERO
                    comentarioConReferencia=${comentario//'#'/"#${i}_${numeracion}"}

                    ### UN AUTENTICO MADMAN ######################
                    # Tengo que escapar los caracteres especiales de bash para poder usarlos en la expresion de sed. Si no, interpreta cosas
                    # y no funciona como se espera.

                    # Uso doble // para que sean sustituiodos todas las coincidencias, no solo uno
                    # Los backslash \ por \\
                    comentarioEscapado=${comentario//\\/\\\\}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\\/\\\\}
                    # Los [ por \[
                    comentarioEscapado=${comentario//\[/\\[}
                    comentarioConReferenciaEscapado=${comentarioConReferencia//\\/\\\\}
                    # Esto se podrá hacer todo en uno pero ya veremos más adelante si eso.

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

# MENUS ----------------------------------------------------------

function menuReferencias {
    local opcion=0

    #validacion
    until ([[ $opcion > 0 && $opcion < 5 ]])
    do
        echo
        echo '---- Referencias ---------------------'
        echo
        echo '1) Generar'
        echo '2) Intercambiar'
        echo '3) Borrar'
        echo '4) Atras'
        echo

        read opcion
    done 

    case "$opcion" in 
        '1') crearReferencias;;
        '2') intercambiarComentarios;;
        '3') borrarReferencias;;
        '4') 
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
        echo
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
        echo
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

###############################################################################
# Inicio de ejecución del script
###############################################################################

# Antes de hacer nada lo que hago es comprobar que los parametros pasados
# son correctos. En caso contrario no hacer nada.

# Comprobar que se ha pasado el parámetro correctamente y es único.
if [ $# -ne 1 ]
then
    echo "Pásame un ÚNICO directorio como parámetro"
    exit 1
fi

# Comprobación si existe el directorio que se ha pasdao por parámetro.
if [ ! -d "$dirPath" ]
then
    echo "El directorio proporcionado NO existe"
    exit 1
fi

cabecera
crearIdiomasStorage
menuInicio


