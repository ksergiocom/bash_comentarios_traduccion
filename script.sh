#!/bin/bash

dirPath=$1


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
    echo 'Sergiy Khudoley'
    echo `date`
    echo 'v0.2'
    echo 'Internacionalización de comentarios'
    echo
    echo
}

function saludar {
	echo
    echo '¡Hay, es que me parte el alma,'
	echo 'que muera la esperanza'
	echo 'y toda la dulzura'
	echo 'del amor en tí!'
	echo
}

function buscarFicheros {
    # Mensaje INFO de ficheros encontrados
    echo
    echo "Se han extraido los comentarios de los ficheros .sh encontrados en $dirPath"
    echo "Los nuevos ficheros tienen la extensión *.txt"
    echo "Estos son los ficheros encontrados:"
    echo 

    # Itero cada fichero y generar sus .txt
    # Se puede pasar el resultado de un comando al while de esta forma:
    # https://stackoverflow.com/questions/2983213/input-of-while-loop-to-come-from-output-of-command
	find "$dirPath" -type f -name "*.sh" | while read file
    do
        # Mensaje informátivo; para saber que archivos se han modificado
        echo "$file"

        directorioPadre=$(dirname "$file")
        nombreFichero=$(basename "$file")

        # El path completo de los archivos generados
        pathES="${directorioPadre}/ES_${nombreFichero}.txt"
        pathEN="${directorioPadre}/EN_${nombreFichero}.txt"

        # Borrar posibles archivos anteriores.
        # ¿Por que? Porque quiero siempre empezar a insertar comentarios en la linea 1
        # Si creo primero el archivo, se crea una linea vacia. De estsa otra forma cuando hago el primer append
        # se crea el archivo y me quito de problemas. EN CASO NECESARIO; puedo modificar esto sin demasiados cambios.
        rm "$pathES"
        rm "$pathEN"

        # Contador de comentarios para cada archivo
        numeracion=10
        # Buscar comentarios
        grep -o -E '(^|\s|\t)#.*$' "$file" | while read comentario
        do
            # Voy a utilizar la sustitución de strings de bash, ya que es infinitamente más rápida
            # que llamar a sed constantemente (al menos probandolo he tenido esos resultados)
            # Pequeño manual de sustitución de parametros con bash:
            # http://46.101.4.154/Art%C3%ADculos%20t%C3%A9cnicos/Scripting/GNU%20Bash%20-%20Sustituci%C3%B3n%20de%20par%C3%A1metros%20y%20manipulaci%C3%B3n%20de%20variables.pdf
            comentarioConReferencia=${comentario//'#'/'#ES_'${numeracion}}

            # Para español
            echo "$comentarioConReferencia" >> "$pathES"
            echo "#EN_$numeracion" >> "$pathEN"

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
    # echo '3) Intercambiar comentarios'
    read seleccionMenuInicio

    # Validación de que se ha escogido una opción correcta
	until ([[ $seleccionMenuInicio > 0 && $seleccionMenuInicio < 3 ]])
    do
        echo "Error en la elección de una opción válida"
        echo
        echo '1) Saludar'
        echo '2) Buscar ficheros'
        # echo '3) Intercambiar comentarios'

        read seleccionMenuInicio
	done

    # Opciones del menú
    case "$seleccionMenuInicio" in
		'1')
            saludar
			;;
        '2')
			buscarFicheros
            ;;
        # '3')
        #     # swapComentarios
        #     menuSeleccionarIdioma
        #     menuSwapComentariosElegirIdiomas
        #     ;;
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
menuInicio



