#!/bin/bash

# '.................@@. @@...............'
# '...............#.      @..............'
# '...............@   @.  :@.............'
# '..........@@@:         :@.............'
# '..............@        ::@............'
# '..............:        ::@............'
# '..............@        ::@............'
#'..............+        .::@...........'
#'.............@         .:::@..........'
#'............:.          :::@..........'
#'............@           ::::@.........'
# '...........@            .:::@.........'
#'............@%@          :@...........'
# '................@ .@.@..@=............'
#'..................@..@................'
#'..................@...@...............'
#'..................@...@...............'
#'...............@@@@..@@...............'
#'...................@*@................'


# ¡CUIDADO! #########################################################
# Lee el README.md , aparecen los errores que todavía no he
# tenido tiempo de solucionar. Hay "funcionalidades" que están 
# a medio hacer.
#####################################################################


# DEBUG #############################################################
# set -x  # Activa trazado
#####################################################################


language='EN' # Default language to work with

declare -a availableLanguages 
declare -a scriptFiles
declare -a commentsFound
declare -a echoesFound

# AUXILIARY #########################################################

# Function to load the scripts with which we are going to work
function findScriptFiles {
    # Search by extension and I ignore this file.
    readarray -d '' scriptFiles < <(find "./" -type f -name "*.sh" ! -wholename $0 -print0)
}

# By parameters the file where to search and accept another parameter -R that will make it ONLY search for referenced comments
function findComments {
    local file=$1
    local onlyReferenced=""
    local totalLines=$(wc -l < "$file") # To show progress

    # Check if the flag has been passed to search only for references
    if [[ $* == *-R* ]]
    then
        onlyReferenced="1"
    fi


    commentsFound=()

    echo "Extracting comments from: $file"
    while IFS=: read -r numLine line
    do
        # Let's extract the comment from the line
        comment=""
        previousC=""
        toTrim=()

        # Show progress
        echo -ne "Progress (${numLine}/${totalLines})\r"

        # If -R was passed then skip the iteration of the lines that have no reference
        if [[ "$onlyReferenced" -eq 1 && ! "$line" =~ .*#[A-Z]{,2}-[0-9]*-.* ]]
        then
            continue
        fi

        # If the comment is a shebang skip iteration
        if [[ "$line" =~ ^#\! ]]
        then
            continue
        fi

        # If it starts with # it is a comment
        if [[ ${line:0:1} == "#" ]]
        then
            comment="$line"

        # Otherwise, clean the line of possible # inside quotes
        # If I iterate the line and a quote appears, you have to ignore everything until you find the next double quote.
        else
            insideDoubleQuotes=""
            insideSimpleQuotes=""
            
            # Iterate the line character by character
            for (( j=0; j<${#line}; j++ ))
            do
                # The iterated character
                c="${line:j:1}"

                # If it is a DOUBLE quote
                if [[ "$c" == "\"" ]]
                then
                    if [[ -z "$insideDoubleQuotes" ]]
                    then
                        insideDoubleQuotes="1"
                    else
                        insideDoubleQuotes=""
                    fi
                fi

                # If it is a SINGLE quote
                if [[ "$c" == "'" ]]
                then
                    if [[ -z "$insideSimpleQuotes" ]]
                    then
                        insideSimpleQuotes="1"
                    else
                        insideSimpleQuotes=""
                    fi
                fi
                
                # If this is true, FINISH searching
                if [[ "$c" == "#" && -z "$insideDoubleQuotes" && -z $insideSimpleQuotes && "$previousC" =~ [[:space:]] ]]
                then
                    comment="${line:j}"
                    break
                fi

                # Add to the array the part that needs to be removed
                toTrim+=("$c")
                # Save the character for the next iteration. Necessary to check that the # is preceded by a space
                previousC="$c"
            done
        fi

        comment=$(trimStartingSpaces "$comment")

        # After cleaning it may be empty, in that case simply empty it.
        if [[ -z "$comment" ]]
        then
            continue
        fi
        
        # End of processing. If you get this far the comment is valid, save it.
        commentsFound+=("${numLine}:${comment}")

    done < <(grep -E -n '#' "$file")
}

# Find all echoes statments and save to array
function findEchoes {
    echoesFound=() # Reset found echoes
    local compoundLane="" # For multilanes, will be a concatenation of every lane with break till last.
    local lineNumber=0
    local onlyReferenced=""

    # Check if the flag has been passed to search only for references
    if [[ $* == *-R* ]]
    then
        onlyReferenced="1"
    fi

    while IFS= read -r lane
    do
        lineNumber=$((lineNumber + 1)) # Increment line number for each line read

        # --------------- Multilines ------------------------------------
        # Checkin if is multiline (ending in with '\' character )
        # if so, then save to use with the next lane as one.

        strippedLine="${lane%"${lane##*[![:space:]]}"}" # Be carefull with lanes that ends with \ and some kind of spaces


        # If ends with \ ; Just save this lane to use with the next one
        if [[ "$strippedLine" =~ \\$ ]]
        then
            continuedLine+="${lane%\\*} "
            continue
        # If doesnt end with \ we can then keep going (concat all previos and go on).
        else
            lane="$continuedLine$lane"
            continuedLine="" # Reset. Next lane will be the start again.
        fi
        # ---------------------------------------------------------------



        # ------------- Only for referenced ones  --------------------
        # Sometimes we only want to find the referenced, as when we work with swapping.
        # We dont want to touch not referenced ones.

        # If -R was passed then skip the iteration of the lines that have no reference
        if [[ "$onlyReferenced" -eq 1 && ! "$lane" =~ .*##[A-Z]{,2}-[0-9]*-.* ]]
        then
            continue
        fi
        # ------------------------------------------------------------


        # ------- Casos especiales --------------------
        # Si es un comentario estandar de un alinea que empieza por # saltatelo! 
        # Puede ser un echo dentr ode un comentario!
        if [[ "$lane" =~ ^[[:space:]]*# ]]
        then
            continue
        fi

        # ------- Here we start ---------------------
        # Does the lane has an echo statment?
        # if [[ "$lane" =~ echo ]] # <----- Simple. Pero atrapa cosas como declaraciones de variables llamadsa echoCosa, por ejemplo....
        # Buscamos lineas que tengan un comando echo válido
        if [[ "$lane" =~ (^|[[:space:];&|])echo[[:space:]] ]]
        then

            # Quitar todo lo anterior al primer echo
            resto="${lane#*echo}"

            # Quitar lo que viene después de redirecciones o separadores
            # Esto corta en el primer operador que encuentre entre:
            # ; | > < && || (y sus combinaciones)
            resto=$(echo "$resto" | sed -E 's/[|;&<>]{1,2}.*//')

            # Quitar los flags -e -n -N y posibles combinaciones. Mínimo 1 a 3 caracteres porque existe el -name
            # quitamos todas las posibles apariciones con /g
            # \b → límite de palabra, para evitar que capture cosas como -name o -extra. What????
            resto=$(echo "$resto" | sed -E 's/\s*-([enE]{1,3})\b//g')

            # Añadir a array con el número de línea
            echoesFound+=("$lineNumber:$resto")
        fi


    done <<< `cat $1`

}

# Function to process a string so it can be used in sed.
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
    str=${str//\@/\\\@}   #@ (delimiter used in my seds)

    str=${str//$'\n'/\\n} # Newline (LF)
    str=${str//$'\r'/\\r} # Carriage Return (CR)

    echo -n "$str"
}

function trimStartingSpaces {
    local str=$1
    echo "$str" | sed 's/^[[:space:]]*//'
}

# LANGUAGES ############################################ ###############

# Function to load available languages
# Load a Prefix-Name type string
function loadAvailableLanguages {
    availableLanguages=()

    # Comments are at the end of this script. Iterate in reverse with tac
    while read line
    do
        if [[ $line =~ '##' ]]
        then
            break
        fi

        # Remove the # from the prefix
        line=${line:1}

        availableLanguages+=($line)

    done < <(tac "$0")
}

# Function to print the available languages ​​on the screen
function showAvailableLenguages {
    clear -x

    loadAvailableLanguages

    echo "The available languages are:"
    for i in "${availableLanguages[@]}"
    do
        echo "$i"
    done
}

function addLanguage {
    clear -x    

    echo 'Give me the prefix of the new language:'
    echo 'The format is 2 uppercase letters'

    read languagePrefix
    

    # Validation
    local pattern='^[A-Z]{2}$'
    until ([[ $languagePrefix =~ $pattern ]])
    do
        echo 'The provided format is incorrect.'
        echo 'The format should be 2 uppercase letters.'
        read languagePrefix
    done

    # Requesting name
    echo 'Give me the full name of the new language:'

    read languageName

    # Validation
    local pattern='^[A-Za-z]+$'
    until ([[ $languageName =~ $pattern ]])
    do
        echo 'The provided format is incorrect.'
        echo 'The name can only contain letters.'
        read languageName
    done

    # Saving language
    local name="${languagePrefix}-${languageName}"
    echo "#$name" >> $0

    clear -x

    echo "Language: $name created successfully"


    ########## Generate new translation files ###########

    findScriptFiles

    for file in "${scriptFiles[@]}"
    do
        # Necessary to work with paths
        local parentDirectory=$(dirname "$file")
        local filesNames=$(basename "$file")

        # Generating the file for each script
        touch "$parentDirectory/${languagePrefix}_${filesNames}.txt"

        findComments "$file" -R
        
        counter=1 # To show progress

        echo "Generating new translation files for: $name" "$file"
        for lineAndComment in "${commentsFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            echo -ne "Progress (${counter}/${#commentsFound[@]})\r"
            counter=$((counter+1))

            # This is presented as numLine:comment so I split them into two variables.
            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # If it is NOT referenced, it does not have to be saved in the translation file
            if [[ ! $comment =~ ^#[A-Z]{2}-[0-9]+- ]]
            then
                continue
            fi

            # Replace the prefix with the new language
            comment=$(echo $comment | sed "s/^#[A-Z]\{2\}-/#${languagePrefix}-/")
            # Delete everything after the second dash
            comment=$(echo "$comment" | sed 's/\(^#[A-Z]\{2\}-[0-9]*-\).*/\1/')
            
            echo "$comment" >> "$parentDirectory/${languagePrefix}_${filesNames}.txt"
        done

    done

}

function deleteLanguage {
    clear -x
    

    loadAvailableLanguages
    
    echo 'Which language do you want to delete?'

    # We iterate the languages ​​to show the options
    for ((i=0; i<${#availableLanguages[@]}; i++))
    do
        echo "$i)${availableLanguages[$i]}"
    done

    echo
    read languageIdx

    # We check the selection
    until [[ $languageIdx -ge 0 && $languageIdx -le ${#availableLanguages[@]}-1 ]]
    do
        echo 'The selected option is not correct.'
        echo 'Which language do you want to delete?'
        read languageIdx
    done
    
    local selection=${availableLanguages[$languageIdx]}
    # I am going to delete the line that has the exact match
    sed -i "/^#$selection$/d" $0

    clear -x

    echo "The language $selection has been deleted."

}

function selectLanguage {
    clear -x    

    loadAvailableLanguages

    echo 'With which language do you want to perform the action?'

    # We iterate the languages ​​to show the options
    for ((i=0; i<${#availableLanguages[@]}; i++))
    do
        echo "$i) ${availableLanguages[$i]}"
    done

    read languageIdx

    # We check the selection
    # If it is less than 0 the index should not be correct. Although it works too :D. If it is greater than len-1 it is out of range.
    until [[ $languageIdx -ge 0 || $languageIdx -le ${#availableLanguages[@]}-1 ]]
    do
        echo 'The selected option is not correct.'
        echo 'With which language do you want to perform the action?'
        read languageIdx
    done
    
    local selection=${availableLanguages[$languageIdx]}
    # I choose only the prefix in front (Shell parameter expansion)
    language=${selection:0:2}

    # Just for information purposes I show you the prefix and the full name (internally I only work with the prefix)
    echo "The language you will work with is: $selection"

}

# REFERENCES ############################################# ###########

function swapComments {

    selectLanguage

    clear -x

    findScriptFiles

    

    # Indicator that the process is running

    for file in "${scriptFiles[@]}"
    do
        local parentDirectory=$(dirname "$file")
        local filesNames=$(basename "$file")
        local translationFile="${parentDirectory}/${language}_${filesNames}.txt" # This is the translation file for this script file

        

        if [ ! -f "$translationFile" ]
        then
            echo "Cannot swap comments. Translation file not found: $translationFile"
            continue
        fi

        # We ONLY exchange comments WITH references
        findComments $file -R
        findEchoes $file -R
        

        # ------- Comments --------------------------
        counter=1 # To show progress

        echo "Swapping comments for: $file"

        for lineAndComment in "${commentsFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            echo -ne "Progress (${counter}/${#commentsFound[@]})\r"
            counter=$((counter+1))
    
            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # Extracting data from the reference
            withoutPrefix=${comment#*#[A-Z]*-}
            number="${withoutPrefix%%-*}"
            text="${withoutPrefix#"$number"}"

            # I look within the translations file for the one with that number. Just the first match
            translation=$(grep -m1 -E "${language}-${number}" $translationFile)

            escapedComment=$(escapeSed "$comment")
            escapedCommentWithReference=$(escapeSed "$translation")

            # I replace the old comment with the translation in the specific line.
            if [ -z "$translation" ]
            then
                # If the translation was not found, insert it empty
                sed -E -i "${numLine}s@$escapedComment@#${language}-${number}-@" $file
            else
                # If it exists, modify the previous one with the translated one
                sed -E -i "${numLine}s@${escapedComment}@${escapedCommentWithReference}@" $file
            fi

        done

        # ------ Echoes ------------------------------------
        counter=1 # To show progress

        echo "Swapping echos for: $file"

        for lineAndEcho in "${echoesFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            echo -ne "Progress (${counter}/${#lineAndEcho[@]})\r"
            counter=$((counter+1))
    
            IFS=':' read -r numLine echoArgs <<< "$lineAndEcho"

            local pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$echoArgs")

            while IFS= read -r m
            do
                # El fichero de traduccion tiene un formato diferente. XX-000-"el comentario" <- Pudiendo ser comillas dobles o simples!
                
                # 1. Sacar la referencia del comentario
                # Extraer el prefijo actual
                prefijo_numeracion=$(echo "$m" | grep -oE "##[A-Z]+-[0-9]+-")

                # Si NO existe prefijo, significa que NO debe ser swapeado. 
                # Si se desea, se tiene primero que re-referenciar y lugeo podra hacerse la traduccion.
                if [[ -z "$prefijo_numeracion" ]]
                then
                    continue
                fi

                # Sacamos number, por si encontramos numeracion sin su traduccion en el fichero (ver mas abajo si no se encuentra "$echoTexto")
                # 1) Quita todo hasta el último guión para quedarte con "360-"
                tmp=${prefijo_numeracion##*-}    # -> "360-"
                # 2) Quita el guión final para quedarte solo con el número
                number=${tmp%-}   

                # Modifico el prefijo del lenguaje por el seleccionado por el usuario
                prefijo_buscado=$(echo "$prefijo_numeracion" | sed -E "s/[A-Z]+/${language}/")
                
                # 2. En el fichero de traduccion, todo lo que vaya a continuación de ##XX-0000-
                # Las lineas con comentarios dobles del estilo ##Com1##Com2##Com3 se gestionan mas adelante. Confia!
                # La siguiente parte se gestiona en el siguiente $m !!!!!!!!! Simplemente vamos quitando todo lo que vaya detras del primer comentario!
                # 1 línea: busca todo desde el prefijo hasta fin de línea
                # 1) cojo la línea completa
                echoTraducido=$(grep -m1 -Eo "$prefijo_buscado.*" "$translationFile")
                # 2) quito el prefijo para quedarme solo con el "cuerpo"
                rest=${echoTraducido#"$prefijo_buscado"}
                # 3) recorto todo lo que venga desde el siguiente "##"
                rest=${rest%%##*}
                # 4) lo vuelvo a unir con el prefijo
                echoTraducido="${prefijo_buscado}${rest}"

                # 3. Transformamos el comentario para insertar dentro de las comillas la referencia!
                # Voy a quitar primero el prefijo
                echoTexto=${echoTraducido#"$prefijo_buscado"}

                # Quito primero la primera comilla y la guardo en una varible para ser usada despues
                # 1) Extrae la primera comilla (no la saco de echoText ahi no va la saco directamente del match!)
                quoteChar=${m:0:1}
                # 2) Extraigo el contenido interior quitando la primera y la última comilla
                inner=${echoTexto:1:${#echoTexto}-2}
                # 3) Inserto el prefijo dentro de ese contenido
                inner=${prefijo_buscado}${inner}
                # 4) Reconstruyo el literal con una única apertura y cierre
                echoTexto="${quoteChar}${inner}${quoteChar}"

                # Reemplazamos el match viejo por la coincidencia encontrada del fichero de traduccion                 
                # Primero escapamos todo lo que necesitemos para el sed
                escapedOriginal=$(escapeSed "$m")
                escapedTranslated=$(escapeSed "$echoTexto")

                # I replace the old echo with the translation in the specific line.
                # -----------------------------------------------
                # ChatGPT. Para manejar los echos multilinea, a veces no está en la linea que creo sino las anteriores.
                # Itero con un bucle hacia atrás hasta realizar la susitución. Lo compruebo con un grep.
                 if [ -z "$echoTexto" ]; then
                    # --- Fallback: Insertamos sólo la referencia vacía, retrocediendo si no se aplica ---
                    current_line=$numLine
                    fallback="#${language}-${number}-"
                    escaped_fallback=$(escapeSed "$fallback")
                    while (( current_line > 0 )); do
                        sed -E -i "${current_line}s@${escapedOriginal}@${escaped_fallback}@" "$file"
                        if grep -qF "$fallback" "$file"; then
                            break  # salió bien
                        else
                            (( current_line-- ))
                        fi
                    done
                else
                    # --- Reemplazo normal con traducción, con fallback retrocediendo sobre líneas multilinea ---
                    current_line=$numLine
                    while (( current_line > 0 )); do
                    sed -E -i "${current_line}s@${escapedOriginal}@${escapedTranslated}@" "$file"
                    if grep -qF "${echoTexto}" "$file"; then
                        break
                    else
                        (( current_line-- ))
                    fi
                    done
                fi
                # ----------------------------------------------

                # # DEBUG ###########
                # echo "----------"
                # echo "\$m: $m" # El match
                # echo "\$prefijo_numeracion: $prefijo_numeracion"
                # echo "\$prefijo_buscado: $prefijo_buscado"
                # echo "\$echoTraducido: $echoTraducido"
                # echo "\$echoTexto: $echoTexto"
                # echo "\$escapedTranslated: $escapedTranslated"
                # echo "\$quoteChar: $quoteChar"
                # echo "sed -E -i \"${numLine}s@${escapedOriginal}@${escapedTranslated}@\" $file"
                # ###################

            done <<< "$matches"

        done
        
    done

    clear -x

    echo 'Comments have been replaced successfully'

}

function deleteReferences {
    clear -x    

    findScriptFiles
    
    # Indicator that the process is running

    for file in "${scriptFiles[@]}"
    do
        # Informative message; to know which files have been modified
        echo "Deleting references from: $file"
        # CUIDADO CON EL ORDEN! Es importante primero este y luego el otro.
        sed -i -e 's/##\([A-Z]\{1,\}-[0-9]*\)-//g' $file # Delete references echo
        sed -i -e 's/#\([A-Z]\{1,\}-[0-9]*\)-/#/g' $file # Delete references comments       
    done

    clear -x

    echo 'Comments have been deleted successfully'

}

function createReferences {
    clear -x


    echo 'WARNING! This option deletes all translation files and generates them empty except for the selected language.'
    echo 'Are you sure you want to proceed with this action? (Y/n)'

    read sn

    # Confirmation
    if [[ $sn != "Y" && $sn != "y" ]]
    then
        referencesMenu
        exit 0
    fi

    selectLanguage

    clear -x

    deleteReferences
    findScriptFiles


    # Iterate each file and generate its .txt
    for file in "${scriptFiles[@]}"
    do

        # Generar referencias de comentarios numerados --------------------------------------------

        findComments $file
        numeration=10 # Comment counter for each file


        # Iterate each comment
        echo "Generating references for: $file"
        for lineAndComment in "${commentsFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            counter=$((numeration/10))
            echo -ne "Progress (${counter}/${#commentsFound[@]})\r"

            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # To work with paths
            parentDirectory=$(dirname "$file")
            filesNames=$(basename "$file")

            for i in "${availableLanguages[@]}"
            do
                # i is XX-NameLanguage I have. I'm going to transform i into the prefix
                i=${i:0:2}

                # The complete path of the files generated for each language
                path="${parentDirectory}/${i}_${filesNames}.txt"

                # Delete possible previous files. Only in the first iteration
                if [[ $numeration -eq 10 && -f "$path" ]]
                then
                    rm "$path"
                fi


                # If the iterated language is the selected language, dump the comments there
                if [ $i = $language ]
                then
                    # Change the # to #NUMBER
                    commentWithReference=${comment/'#'/"#${i}-${numeration}-"}

                    escapedComment=$(escapeSed "$comment")
                    escapedCommentWithReference=$(escapeSed "$commentWithReference")

                    sed -E -i "${numLine}s@${escapedComment}@${escapedCommentWithReference}@" $file
                    echo "$commentWithReference" >> "$path"

                # If the language is not selected, only generate the reference without the comment
                else
                    echo "#${i}-${numeration}-" >> "$path"
                fi

            done

            # Increase numbering
            numeration=$((numeration+10))
        done


        # Generar referencias de echos numerados --------------------------------------------

        # Buscamos todos los echos
        findEchoes $file

        # Reiniciar numeracion para cada ficheor de echos
        numeration=10

        # Iteramos los echos (son lineas de varios comentarios separados por distintos tipos de comillas)
        for echoLineAndArg in "${echoesFound[@]}"
        do
            # Mostrar progreso al usuario
            counter=$((numeration / 10))
            echo -ne "Progress (${counter}/${#echoesFound[@]})\r"

            IFS=':' read -r echoLine echoArg <<< "$echoLineAndArg" # Separar número de línea del argumento del echo

            # Necesario para encontrar el fichero de traduccion
            parentDirectory=$(dirname "$file")
            filesNames=$(basename "$file")

            # Por cada lenguaje disponible hay que hacer un tratamiento
            for i in "${availableLanguages[@]}"
            do
                # !CUIDADO! !COSAS RARAS!
                # Esta lógica es un poco chuga. La mantengo aquí por cambiar lo mínimo el código
                # En vez de sacar el contador fuera, lo manejo aqui para cambiar lo mínimo posible
                local numeracionInterna=$numeration

                i=${i:0:2} # Prefijo de idioma
                path="${parentDirectory}/${i}_${filesNames}.txt" # Fichero de traduccion

                # Sacamos todos los argumentos pasados a echo entre distinto tipo de comillas
                local pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
                matches=$(grep -oE "$pattern" <<< "$echoArg")

                # En caso de no encontrar ningun match, es un echo sin strings u otro tipo de linea mal atrapadas.
                # Simplemente las ignoro y ya estaría.
                if [[ -z "$matches" ]]
                then
                    continue
                fi

                argsLane="" # Lo usamos para componer la linea final a insertar en el archivo
                # Iteramos cada match, y en funcion decidimos si agregar numeracion solo o más el string (solo para lenguaje seleccionado)
                while IFS= read -r m
                do
                    if [ "$i" = "$language" ]
                    then
                        # ----- Caso especial --------
                        # En ocasiones tendremos echos sin argumentos o solo con variables $var , es decir vienen vacios!
                        # En este caso ignora este match. No hace falta hacer nada
                        if [[ ! -n "$m" ]]
                        then
                            continue
                        fi
                        # ---------------------------

                        # 1) Elimina las comillas al principio y al final (extraer contenido interior)
                        quoteChar="${m:0:1}"   # Saber si es '' o ""
                        innerContent="${m:1:-1}"  # corta el primer y último carácter (comillas)

                        # ------ OJO!!!!! ---------------- Chapuza incoming!
                        # 2) Prepara el nuevo contenido, con la referencia DENTRO de las comillas
                        # !CUIDADO! Las estoy convirtiendo en comillas dobles siempre!!!!!!!!!!!!!!!!
                        echoWithReference="${quoteChar}##${i}-${numeracionInterna}-${innerContent}${quoteChar}"
                        # --------------------------------

                        # 3) Escapa ambos para sed
                        escapedEchoArg=$(escapeSed "$m") # m aún tiene las comillas
                        escapedEchoArgWithReference=$(escapeSed "$echoWithReference")

                        
                        # 4) Sustitución en el archivo, AHORA utilizando el número de línea
                        # ¡CUIDADO! Puede ser un echo con los textos pasados en varias lineas. En ese caso hay que
                        # modificar mas de una linea.
                        #
                        # ¿Como lo hago?
                        # Si se ha sustituido algo entonces esta todo ok, pero en caso de que no, es que está en OTRA ¡linea!
                        # Estará en la linea anterior por como he ido guardando los comentarios en el foundEchoes.
                        # He ido creando los echos que van en "multilinea" (los que acabn con \ ) sumando todas las lineas
                        # en una sola grande.
                        # Si el `sed` no ha conseguido modificar nada, es que el texto a modificar esta en la linea anterior.
                        # sed -E -i "${echoLine}s@${escapedEchoArg}@${escapedEchoArgWithReference}@" "$file"

                        # ------------------
                        # Esto me lo ha hecho ChatGPT, me daba pereza.
                        current_line=$echoLine
                        escaped_old=$(escapeSed "$m") # Duplicado!
                        escaped_new=$(escapeSed "$echoWithReference") # Duplicado!

                        while (( current_line > 0 )); do
                            # intentamos en la línea current_line
                            sed -E -i "${current_line}s@${escaped_old}@${escaped_new}@" "$file"

                            # comprobamos si la referencia ya está en el archivo
                            if grep -qF "$echoWithReference" "$file"; then
                                # éxito: salimos del bucle
                                break
                            else
                                # no encontrado: probamos en la línea anterior
                                (( current_line-- ))
                            fi
                        done
                        # -----------------------

                        argsLane+="##${i}-${numeracionInterna}-${m}"
                    else
                        argsLane+="##${i}-${numeracionInterna}-"
                    fi
                    # Para cada match incrementamos la numeracion
                    numeracionInterna=$((numeracionInterna + 10))
                done <<< "$matches"

                echo "$argsLane" >> "$path"
            done

            # Solo una vez por echoArg, reseteamos el contador externo con el incremento de cada 'string' encontrado.
            numeration=$((numeracionInterna))

        done

    done

}

function addAdditionalReferences {    
    clear -x    

    findScriptFiles

    for file in "${scriptFiles[@]}"
    do
        # To work with paths
        parentDirectory=$(dirname "$file")
        filesNames=$(basename "$file")
        
        findComments "$file" -R
        findEchoes "$file" -R

        # --------- Comments ----------------------------------------------------------------------

        counter=1 # To show progress

        # Iterate each comment
        echo "Adding additional references to: $file"
        for lineAndComment in "${commentsFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            echo -ne "Progress (${counter}/${#commentsFound[@]})\r"
            counter=$((counter+1))

            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # Extracted data from the reference
            prefix=${comment:1:2}
            withoutPrefix=${comment#*#[A-Z]*-}
            number="${withoutPrefix%%-*}"
            text="${withoutPrefix#"$number"}"

            # For each language there is its own translation file
            for i in "${availableLanguages[@]}"
            do
                languagePrefix=${i:0:2}

                # The complete path of the files generated for each language
                translationPath="${parentDirectory}/${languagePrefix}_${filesNames}.txt"
                
                # Verificamos si el archivo existe y es válido
                if [ ! -f "$translationPath" ]
                then
                    echo "Cannot add references. Translation file not found: $translationPath"
                    continue # Saltamos a la siguiente iteración si no existe el archivo de traduccion
                fi

                # I check if the numbering exists in the translation files. Only the first one matches
                reference=$(grep -m1 -E "#${languagePrefix}-${number}-" "$translationPath" )

                if [ -z "$reference" ]
                then

                    # What I am going to do is look for the immediately preceding number and insert this comment right in front of it in the translation files.
                    # To find the previous one I am going to decrease the number until it matches something.

                    # We initialize a counter to decrement the number
                    previousNumber=$((number - 1))
                    
                    while [ $previousNumber -ge 0 ]
                    do
                        referencia_anterior=$(grep -m1 -E "#${languagePrefix}-${previousNumber}-" "$translationPath")

                        # If we find a previous reference, we insert the new comment right after it
                        if [ -n "$referencia_anterior" ]
                        then
                            # Check if the language of the comment in the script matches the file. In that case you have
                            # insert the full comment
                            if [ $prefix = $languagePrefix ]
                            then
                                sed -E -i "/#${languagePrefix}-${previousNumber}-/a\\${comment}" "$translationPath"
                                break
                            # Otherwise simply insert the reference without the text
                            else
                                sed -E -i "/#${languagePrefix}-${previousNumber}-/a\\#${languagePrefix}-${number}-" "$translationPath"
                                break
                            fi
                        fi
                        
                        # We decrement the counter to find the next previous reference
                        previousNumber=$((previousNumber - 1))
                    done
                fi


            done            
        done

        # ---- Echoes -----------------------------------------------------------------------------

        # !!!!!!! VERSION CUTRE!!!!!!! POR ahora se inserta en una nueva linea. Esto habia que cambiarlo para insertarse ne la misma linea que el resto de args del echo.

        counter=1 # To show progress

        # Iterate each comment
        echo "Adding echoes references to: $file"
        for lineAndEchoArg in "${echoesFound[@]}"
        do
            #Show progress (this slows down the speed of the script)
            echo -ne "Progress (${counter}/${#echoesFound[@]})\r"
            counter=$((counter+1))

            IFS=':' read -r numLine arg <<< "$lineAndEchoArg"


            local pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$arg")

            # Los echo args pueden ser varios! Vamos a iterar cada uno.
            while IFS= read -r m
            do

                # El fichero de traduccion tiene un formato diferente. XX-000-"el comentario" <- Pudiendo ser comillas dobles o simples!
                
                # 1. Sacar la referencia del comentario
                # Extraer el prefijo actual
                prefijo_numeracion=$(echo "$m" | grep -oE "##[A-Z]+-[0-9]+-")

                # Si NO existe prefijo, significa que NO debe ser swapeado. 
                # ¡Solo se swapean las referenciadas!
                if [[ -z "$prefijo_numeracion" ]]
                then
                    continue
                fi

                # Sacamos number, por si encontramos numeracion sin su traduccion en el fichero (ver mas abajo si no se encuentra "$echoTexto")
                # 1) Quita todo hasta el último guión para quedarte con "360-"
                # Quita el prefijo hasta el primer guion (queda "600-")
                tmp="${prefijo_numeracion#*-}"      # "600-"
                tmp="${tmp%-}"                      # "600"
                number="$tmp"

                inner=$(echo "$m" | sed -E "s/##[A-Za-z]+-[0-9]+-//")
                echoTexto="${prefijo_numeracion}${inner}"


                # For each language there is its own translation file
                for i in "${availableLanguages[@]}"
                do
                    languagePrefix=${i:0:2}

                    # The complete path of the files generated for each language
                    translationPath="${parentDirectory}/${languagePrefix}_${filesNames}.txt"
                    
                    # I check if the numbering exists in the translation files. Only the first one matches
                    reference=$(grep -m1 -Eo "##${languagePrefix}-${number}-" "$translationPath" )


                    if [ -z "$reference" ]
                    then

                        # What I am going to do is look for the immediately preceding number and insert this comment right in front of it in the translation files.
                        # To find the previous one I am going to decrease the number until it matches something.

                        # We initialize a counter to decrement the number
                        previousNumber=$((number - 1))
                        
                        while [ $previousNumber -ge 0 ]
                        do
                            referencia_anterior=$(grep -m1 -E "^\s*##${languagePrefix}-${previousNumber}-" "$translationPath")

                            # If we find a previous reference, we insert the new arg right after it
                            if [ -n "$referencia_anterior" ]
                            then
                                # # DEBUG!!! ----
                                # echo "-------------"
                                # echo "$\prefijo_numeracion $prefijo_numeracion"
                                # echo "$\languagePrefix $languagePrefix"
                                # echo "$\prefix $prefix"
                                # echo "$\previousNumber $previousNumber"
                                # echo "\$referencia_anterior $referencia_anterior"
                                # echo "\$m $m"
                                # echo "\$echoTexto $echoTexto"
                                # echo "\$quoteChar $quoteChar"
                                # echo "\$inner $inner"
                                # break
                                # # -------------

                                # Check if the language of the arg in the script matches the file. In that case you have
                                # insert the full arg
                                if [ $prefix = $languagePrefix ]
                                then
                                    sed -E -i "/##${languagePrefix}-${previousNumber}-/a\\${echoTexto}" "$translationPath"
                                    break
                                # Otherwise simply insert the reference without the text
                                else
                                    sed -E -i "/##${languagePrefix}-${previousNumber}-/a\\##${languagePrefix}-${number}-" "$translationPath"
                                    break
                                fi
                            fi
                            
                            # We decrement the counter to find the next previous reference
                            previousNumber=$((previousNumber - 1))
                        done
                    fi

                done

            done <<< "$matches"
          
        done

    done

    clear -x

    echo 'Additional comments and echoes had been added'
}

function renumerateReferences {
    clear -x

    findScriptFiles    

    for file in "${scriptFiles[@]}"
    do
        # The comment reference of each file must start at 10.
        loopNumeration=10

        # I will ONLY renumber comments that already HAVE a reference.
        # If they don't have references I don't have to renumber anything. Until this comment exists, it is left AS IS.
        findComments "$file" -R
        findEchoes "$file" -R

        # ---- Comments ---------------------------------------------------------------------------

        # Iterate each comment
        echo "Renumerating comments references in: $file"
        for lineAndComment in "${commentsFound[@]}"
        do
            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # Extract data from the reference
            prefix=${comment:1:2}
            withoutPrefix=${comment#*#[A-Z]*-}
            number="${withoutPrefix%%-*}"
            text="${withoutPrefix#"$number"}"            

            # The comment reference number must match the numbering variable
            # which I use in the loop. If not, it means it is a reference.
            # which has been modified (or some comments are missing)
            if [[ $loopNumeration -eq $number ]]
            then
                # If it matches, you do NOT have to do anything. Everything is correct.
                # Skip to next comment

                loopNumeration=$(( loopNumeration + 10 ))
                # Jump to next iteration.
                continue
            fi
            

            # This is the case that in reference number != loopnumber
            # The numbering in the script must be updated to the new number.
            # Also the translation files.

            # 1- Modify the old number in the original script with the new one that I have in the variable
            sed -i "${numLine}s/#${prefix}-${number}-/#${prefix}-${loopNumeration}-/" $file
            
            # Search for all translation files that have that numbering
            for i in "${availableLanguages[@]}"
            do
                # Pillar prefix
                i=${i:0:2}

                # To work with paths
                parentDirectory=$(dirname "$file")
                filesNames=$(basename "$file")
                translationPath="${parentDirectory}/${i}_${filesNames}.txt"

                # Verificamos si el archivo existe y es válido
                if [ ! -f "$translationPath" ]
                then
                    echo "Cannot renumerate references. Translation file not found: $translationPath"
                    continue # Saltamos a la siguiente iteración si no existe el archivo de traduccion
                fi
                
                # First I locate the line number in which said reference is.
                # On the other hand, it may also be the case that once one line has been changed, the next one has the same numbering.
                # For example. Line 15 becomes line 20 and the next line is line 20. By specifying the line I avoid this problem.
                # To solve this problem I am going to choose the number that matches starting from the back.
                
                numLineaUltima=$(grep -n "#${i}-${number}-" "$translationPath" | tac | head -n 1)
                numLineaUltima=${numLineaUltima%%:*}

                # If a line was found, modify that specific line.
                if [[ -n $numLineaUltima ]]
                then
                    sed -i "${numLineaUltima}s/#${i}-${number}-/#${i}-${loopNumeration}-/" "$translationPath"
                fi

            done

            loopNumeration=$(( loopNumeration + 10 ))
        done


        # --- Echoes ------------------------------------------------------------------------------

        # The comment reference of each file must start at 10.

        # ............
        # Keep it simple, stupid!
        # Voy a contar los comentarios totales. total*10 será la nuemeracion máxima.
        # A partir de ahi voy reemplazando desde el final hasta el principio decrementando hasta terminar.
        # ¿Por que?
        # Por que si itero hacia adelante puedo encontrarme con el siguiente caso;
        # numeracion 105 pasa a ser la 110, la sobreescribimos, pero la siguiente es la 110 también. ¿Que hacemos aqui?
        # Para evitar esto, iteramos desde el último sabiendo que será el más grande siempre.
        # cantidadEchoes=$(grep -E '##[A-Za-z]+-[0-9]+' ES_mio.sh.txt | wc -l)
        # ............................

        # Cuidado! Usa el -o para sacar cada ocurrencia por separado, porque hay lineas con varias coindicendias!
        cantidadEchoes=$(grep -Eo '##[A-Za-z]+-[0-9]+' "$file" | wc -l)
        loopNumeration=$(( cantidadEchoes * 10 ))

        mapfile -t reversedEchoes < <(printf '%s\n' "${echoesFound[@]}" | tac)

        # Iterate each comment
        echo "Renumerating echoes references in: $file"
        for lineAndArg in "${reversedEchoes[@]}"
        do

            # echo "-> $lineAndArg"
            IFS=':' read -r numLine arg <<< "$lineAndArg"


            # Por cada linea pueden haber varias referencias en este caso
            # Lo sacamos con un grep
            local pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            # matches=$(grep -oE "$pattern" <<< "$arg") # WooouUU!!! Mira el final del bucle siguiente!


            while IFS= read -r m
            do
                prefijo_numeracion=$(echo "$m" | grep -oE "##[A-Z]+-[0-9]+-")

                

                # Si NO existe prefijo, significa que NO debe ser swapeado. 
                # Si se desea, se tiene primero que re-referenciar y lugeo podra hacerse la traduccion.
                if [[ -z "$prefijo_numeracion" ]]
                then
                    continue
                fi
                # --- Parsear referencias, textos y formatear para el archivo ------

                number=${prefijo_numeracion#*-}
                number=${number%-}
                # Modifico el prefijo del lenguaje por el seleccionado por el usuario
                prefijo_buscado=$(echo "$prefijo_numeracion" | sed -E "s/[A-Z]+/${language}/")
                
                # 2. En el fichero de traduccion, todo lo que vaya a continuación de ##XX-0000-
                # Las lineas con comentarios dobles del estilo ##Com1##Com2##Com3 se gestionan mas adelante. Confia!
                # La siguiente parte se gestiona en el siguiente $m !!!!!!!!! Simplemente vamos quitando todo lo que vaya detras del primer comentario!
                # 1 línea: busca todo desde el prefijo hasta fin de línea
                # 1) cojo la línea completa
                
                echoTraducido=$(grep -m1 -Eo "$prefijo_buscado.*" "$file")
                # 2) quito el prefijo para quedarme solo con el "cuerpo"
                rest=${echoTraducido#"$prefijo_buscado"}
                # 3) recorto todo lo que venga desde el siguiente "##"
                rest=${rest%%##*}
                # 4) lo vuelvo a unir con el prefijo
                echoTraducido="${prefijo_buscado}${rest}"

                # 3. Transformamos el comentario para insertar dentro de las comillas la referencia!
                # Voy a quitar primero el prefijo
                echoTexto=${echoTraducido#"$prefijo_buscado"}

                # Quito primero la primera comilla y la guardo en una varible para ser usada despues
                # 1) Extrae la primera comilla (no la saco de echoText ahi no va la saco directamente del match!)
                quoteChar=${m:0:1}
                # 2) Extraigo el contenido interior quitando la primera y la última comilla
                inner=${echoTexto:1:${#echoTexto}-2}
                # 3) Inserto el prefijo dentro de ese contenido
                inner=${prefijo_buscado}${inner}
                # 4) Reconstruyo el literal con una única apertura y cierre
                echoTexto="${quoteChar}${inner}${quoteChar}"        

                # ------- Fin del parseo de datos ----------------------

                # echo "---------"
                # echo "\$m -> $m"
                # echo "\$tmp -> $tmp"
                # echo "\$prefijo_numeracion -> $prefijo_numeracion"
                # echo "\$prefijo_buscado -> $prefijo_buscado"
                # echo "\$echoTraducido -> $echoTraducido"
                # echo "\$echoTexto -> $echoTexto"
                # echo "\$rest -> $rest"
                # echo "\$prefix -> $prefix"
                # echo "\$numLine -> $numLine"
                # echo "\$number -> $number"
                # echo "\$loopNumeration -> $loopNumeration"
                # echo "sed -> ${numLine}s/##${prefix}-${number}-/##${prefix}-${loopNumeration}-/"

                # The comment reference number must match the numbering variable
                # which I use in the loop. If not, it means it is a reference.
                # which has been modified (or some comments are missing)
                if [[ $loopNumeration -eq $number ]]
                then
                    # If it matches, you do NOT have to do anything. Everything is correct.
                    # Skip to next comment

                    loopNumeration=$(( loopNumeration - 10 ))
                    # Jump to next iteration.
                    continue
                fi
                

                # This is the case that in reference number != loopnumber
                # The numbering in the script must be updated to the new number.
                # Also the translation files.


                # 1- Modify the old number in the original script with the new one that I have in the variable
                sed -i "${numLine}s/##${prefix}-${number}-/##${prefix}-${loopNumeration}-/" "$file"
                # echo '----'
                echo "sed original file -> ${numLine}s/##${prefix}-${number}-/##${prefix}-${loopNumeration}-/" "$file"
                
                # Search for all translation files that have that numbering
                for i in "${availableLanguages[@]}"
                do
                    # Pillar prefix
                    i=${i:0:2}

                    # To work with paths
                    parentDirectory=$(dirname "$file")
                    filesNames=$(basename "$file")
                    translationPath="${parentDirectory}/${i}_${filesNames}.txt"
                    
                    # First I locate the line number in which said reference is.
                    # On the other hand, it may also be the case that once one line has been changed, the next one has the same numbering.
                    # For example. Line 15 becomes line 20 and the next line is line 20. By specifying the line I avoid this problem.
                    # To solve this problem I am going to choose the number that matches starting from the back.
                    
                    numLineaUltima=$(grep -n "##${i}-${number}-" "$translationPath" | tac | head -n 1)
                    numLineaUltima=${numLineaUltima%%:*}

                    # echo "\$i -> $i"

                    # If a line was found, modify that specific line.
                    if [[ -n $numLineaUltima ]]
                    then
                        echo "sed translation -> ${numLineaUltima}s/#${i}-${number}-/#${i}-${loopNumeration}-/"
                        sed -i "${numLineaUltima}s/#${i}-${number}-/#${i}-${loopNumeration}-/" "$translationPath"
                    fi

                done

                loopNumeration=$(( loopNumeration - 10 ))


            
            done < <(grep -oE "$pattern" <<< "$arg" | tac)
        done




    done

    clear -x

    echo 'A new numbering has been generated'
}

# MENUS ############################################# #################

function referencesMenu {
    clear -x

    local opcion=0

    #validation
    until ([[ $opcion > 0 && $opcion < 7 ]])
    do
        echo '1) Generate references for comments and extract them to translation files'
        echo '2) Swap language of referenced comments'
        echo '3) Add new referenced comments to translation file'
        echo '4) Delete existing references'
        echo '5) Re-number references'
        echo '6) Back'


        read opcion
    done 

    case "$opcion" in 
        '1') createReferences;;
        '2') swapComments;;
        '3') addAdditionalReferences;;
        '4') deleteReferences;;
        '5') renumerateReferences;;
        '6') 
            
            mainMenu
        ;;
    esac
}

function menuIdiomas {
    clear -x    

    local opcion=0

    #validation
    until ([[ $opcion > 0 && $opcion < 5 ]])
    do
        echo '1) Add language'
        echo '2) Delete language'
        echo '3) View available languages'
        echo '4) Back'


        read opcion
    done 

    case "$opcion" in 
        '1') addLanguage;;
        '2') deleteLanguage;;
        '3') showAvailableLenguages;;
        '4') 
            clear -x
            mainMenu
        ;;
    esac
}

function mainMenu {
    echo '----------------------------'

    local opcion=0

    # Validation that a correct option has been chosen
	until ([[ $opcion > 0 && $opcion < 4 ]])
    do
        echo '1) Comments'
        echo '2) Languages'
        echo '3) Exit'


        read opcion
	done

    # Menu options
    case "$opcion" in
        '1') referencesMenu;;
        '2') menuIdiomas;;
        '3') exit 0;;
    esac

    mainMenu
}

############################################### #######################
# Start of script execution
############################################### #######################

# Execution
loadAvailableLanguages
mainMenu

##############################
## Available languages
## You can but SHOULD NOT add and remove from the same script.
## DO NOT insert manually! Because it would NOT generate the
## necessary translation files.
## THERE MUST BE A LINE FREAK AT THE END OF THE LAST LANGUAGE, IF NOT, IT DOES NOT WORK.
##############################
#EN-English
#ES-Español
#FR-Français
