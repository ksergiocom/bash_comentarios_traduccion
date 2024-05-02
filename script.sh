#!/bin/bash

dirPath=$1
idioma='ES'


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
    echo 'v0.2'
    echo 'Internacionalización de comentarios'
    echo
    echo
}

function saludar {
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

function seleccionarIdioma {
    echo
    echo '¿Con que idioma quieres realizar la acción?'
    echo '1) (ES)pañol'
    echo '2) (EN)glish'
    read seleccionIdioma

	until ([[ $seleccionIdioma > 0 && $seleccionMenuInicio < 4 ]])
    do
        echo "Error en la elección de una opción válida"
        echo '1) (ES)pañol'
        echo '2) (EN)glish'

        read seleccionIdioma
	done

    case "$seleccionIdioma" in
		'1')
            idioma='ES'
			;;
        '2')
            idioma='EN'
            ;;
        *)
            echo 'El idioma seleccionado es incorrecto!'
            # Guard clause. Terminar el programa con status de error (1) en caso de que haya este fallo
            exit 1
    esac
}

function intercambiarComentarios {
    # Seleccionar el idioma
    echo 'Pendiente de implementar... Mira el código'
    # Buscar todos los archivos

    # Para cada archivo buscar el archivo con el idioma a insertar

    # Iterar sobre el ficero sacando cada comentario

    # Buscar el comentario en el script 

    # Intercambiar el comentario
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

        # El path completo de los archivos generados
        pathES="${directorioPadre}/ES_${nombreFichero}.txt"
        pathEN="${directorioPadre}/EN_${nombreFichero}.txt"

        # Borrar posibles archivos anteriores.
        # ¿Por que? Porque quiero siempre empezar a insertar comentarios en la linea 1
        # Si creo primero el archivo, se crea una linea vacia. De estsa otra forma cuando hago el primer append
        # se crea el archivo y me quito de problemas. EN CASO NECESARIO; puedo modificar esto sin demasiados cambios.
        if [ -f "$pathES" ]
        then
            rm "$pathES"
        fi
        if [ -f "$pathEN" ]
        then
            rm "$pathEN"
        fi

        # Contador de comentarios para cada archivo
        numeracion=10
        # Buscar comentarios
        grep -o -E -n '(^|\s|\t)#[^!#].*$' "$file" | while IFS=: read -r numero_linea comentario
        do
            # Voy a utilizar la sustitución de strings de bash, ya que es infinitamente más rápida
            # que llamar a sed constantemente (al menos probandolo he tenido esos resultados)
            # Pequeño manual de sustitución de parametros con bash:
            # http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf

            case "$idioma" in 
                'ES')
                    comentarioConReferencia=${comentario//'#'/'#ES_'${numeracion}}
                    
                    # WOW!!!!!!! Esto si que no me lo esperaba...
                    # Esto esta chivado por ChatGPT!!!
                    # Para que sed maneje cualquier cadena literal sin procesarla, puedes usar un delimitador 
                    # distinto para el comando s. Pj: si usas @ como delimitador en lugar de /, 
                    # no necesitas escapar los caracteres / 
                    sed -i "${numero_linea}s@$comentario@$comentarioConReferencia@g" $file

                    echo "$comentarioConReferencia" >> "$pathES"
                    echo "#EN_$numeracion" >> "$pathEN"
                ;;
                'EN')
                    comentarioConReferencia=${comentario//'#'/'#EN_'${numeracion}}

                    sed -i "s@$comentario@$comentarioConReferencia@g" $file


                    echo "$comentarioConReferencia" >> "$pathEN"
                    echo "#ES_$numeracion" >> "$pathES"
                ;;
                *)
                    echo '¿Pero que has hecho?'
                    exit 1
                ;;
            esac

            # Incrementar numeración
            numeracion=$((numeracion+10))
        done

    done
}

function menuInicio {
    echo
    echo 'MENU INICIO'
    echo '1) Saludar'
    echo '2) Buscar ficheros'
    echo '3) Intercambiar comentarios'
    echo '4) Borrar referencias'
    echo '5) Re-referenciar'
    read seleccionMenuInicio

    # Validación de que se ha escogido una opción correcta
	until ([[ $seleccionMenuInicio > 0 && $seleccionMenuInicio < 5 ]])
    do
        echo "Error en la elección de una opción válida"
        echo
        echo '1) Saludar'
        echo '2) Buscar ficheros'
        echo '3) Intercambiar comentarios'
        echo '4) Borrar referencias'
        echo '5) Re-referenciar'

        read seleccionMenuInicio
	done

    # Opciones del menú
    case "$seleccionMenuInicio" in
		'1')
            saludar
			;;
        '2')
            seleccionarIdioma
			crearReferencias
            ;;
        '3')
            seleccionarIdioma
            ;;
        '4')
            borrarReferencias
    esac
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



