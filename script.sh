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


# Log de errores ####################################################
ERROR_LOG="error.log"
: > "$ERROR_LOG" # Forma curiosa de cargarme el antiguo y recrearlo.
exec 2>>"$ERROR_LOG" # Redirige todos los errores (stderr)
#####################################################################


# Variables globales :( #############################################
language='EN' # Default language to work with

declare -a availableLanguages 
declare -a scriptFiles
declare -a commentsFound
declare -a echoesFound
#####################################################################


# AUXILIARY #########################################################

# Function to load the scripts with which we are going to work
function findScriptFiles {
    # Search by extension and I ignore this file.
    readarray -d '' scriptFiles < <(find "./" -type f -name "*.sh" ! -wholename "$0" -print0)
}

# By parameters the file where to search and accept another parameter -R that will make it ONLY search for referenced comments
function findComments {
    local file=$1
    local onlyReferenced=""

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
        local nextC=""
        toTrim=()

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
            local insideDoubleQuotes=""
            local insideSimpleQuotes=""
            local estaDentroComillasInvertidas=0
            local estaDentroComandoParentesis=0         # $(...)
            local estaDentroLlave=0     # ${...}
            local nivelAritmeticaParen=0      # ((...))
            local nivelCondicionalBracket=0   # [[...]]
            

            # Iterate the line character by character
            for (( j=0; j<${#line}; j++ ))
            do
                # The iterated character
                c="${line:j:1}"
                nextC="${line:j+1:1}"

                # ================================
                # Manejar comillas '' "" ``
                # ================================

                # If it is a DOUBLE quote
                if [[ "$c" == "\"" && "$previousC" != '\' ]]
                then
                    if [[ -z "$insideDoubleQuotes" ]]
                    then
                        insideDoubleQuotes="1"
                    else
                        insideDoubleQuotes=""
                    fi
                fi

                # If it is a SINGLE quote
                if [[ "$c" == "'" && "$previousC" != '\' ]]
                then
                    if [[ -z "$insideSimpleQuotes" ]]
                    then
                        insideSimpleQuotes="1"
                    else
                        insideSimpleQuotes=""
                    fi
                fi


                # Comillas invertidas
                if [ "$c" = "\`" ] && [ "$previousC" != '\' ]
                then
                    estaDentroComillasInvertidas=$((1 - estaDentroComillasInvertidas))
                    continue
                fi


                # ================================
                # Manejar contextos especiales $() (()) [[]] []
                # ================================

                # #################
                # Primero manejo los casos de los dobles, porque colisionan con los casos de los de 1 solo caracter
                if [[ "${line:j:2}" == "]]" ]]
                then
                    (( nivelCondicionalBracket-- ))
                    (( j+=1 ))      # consumimos ambos paréntesis
                    previousC="]"   # para el siguiente ciclo
                    continue
                fi


                if [[ "${line:j:2}" == "))" ]]
                then
                    (( nivelAritmeticaParen-- ))
                    (( j+=1 ))      # consumimos ambos paréntesis
                    previousC=")"   # para el siguiente ciclo
                    continue
                fi

                ################
                # A partir de aqui ya el caso de abrir y cerrar los simples.

                # Detectar $(
                if [ "$c" = "$" ] && [ "$nextC" = "(" ]
                then
                    ((estaDentroComandoParentesis++))
                    previousC="$c"
                    continue
                fi

                # Detectar ${
                if [ "$c" = "$" ] && [ "$nextC" = "{" ]
                then
                    ((estaDentroLlave++))
                    previousC="$c"
                    continue
                fi

                # Detectar [[
                if [ "$c" = "[" ] && [ "$nextC" = "[" ]
                then
                    ((nivelCondicionalBracket++))
                    previousC="$c"
                    continue
                fi

                # Detectar ((
                if [ "$c" = "(" ] && [ "$nextC" = "(" ]
                then
                    ((nivelAritmeticaParen++))
                    previousC="$c"
                    continue
                fi

                # Cierres
                if [ "$c" = ")" ]
                then
                    if [ "$previousC" != ")" ]
                    then 
                        ((estaDentroComandoParentesis--))
                    fi
                fi

                if [ "$c" = "}" ]
                then
                    ((estaDentroLlave--))
                fi

                #############################################

                # If this is true, FINISH searching
                if [ "$c" = "#" ] && \
                    [ -z "$insideSimpleQuotes" ] && \
                    [ -z "$insideDoubleQuotes" ] && \
                    [ "$estaDentroComillasInvertidas" -eq 0 ] && \
                    [ "$estaDentroComandoParentesis" -eq 0 ] && \
                    [ "$estaDentroLlave" -eq 0 ] && \
                    [ "$nivelAritmeticaParen" -eq 0 ] && \
                    [ "$nivelCondicionalBracket" -eq 0 ] && \
                    [ "$previousC" != '\' ]
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
    local continuedLine="" # For multilanes, will be a concatenation of every lane with break till last.
    local lineNumber=0
    local onlyReferenced=""

    # Check if the flag has been passed to search only for references
    if [[ $* == *-R* ]]
    then
        onlyReferenced="1"
    fi

    echo "Extracting echoes from: $file"
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
            resto="$(printf '%s' "$resto" \
               | sed -E 's/\s+[|;&<>]{1,2}\s.*//')"

            # Quitar los flags -e -n -N y posibles combinaciones. Mínimo 1 a 3 caracteres porque existe el -name
            # quitamos todas las posibles apariciones con /g
            # \b → límite de palabra, para evitar que capture cosas como -name o -extra. What????
            resto=$(echo "$resto" | sed -E 's/\s*-([enE]{1,3})\b//g')

            # Añadir a array con el número de línea
            echoesFound+=("$lineNumber:$resto")
        fi


    done <<< "$(cat "$1")"

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
    while read -r line
    do
        if [[ $line =~ '##' ]]
        then
            break
        fi

        # Remove the # from the prefix
        line=${line:1}

        availableLanguages+=("$line")

    # Agrupa cat y echo como un único bloque. Truco para evitar necesitar agregar el ultimo salto de linea.
    # Si solo quieres hacer `tac ./script.sh` necesitaría tener un salto de linea al final.
    done < <( tac ./script.sh)
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

    read -r languagePrefix
    

    # Validation
    local pattern='^[A-Z]{2}$'
    until [[ $languagePrefix =~ $pattern ]]
    do
        echo 'The provided format is incorrect.'
        echo 'The format should be 2 uppercase letters.'
        read -r languagePrefix
    done

    # Requesting name
    echo 'Give me the full name of the new language:'

    read -r languageName

    # Validation
    local pattern='^[A-Za-z]+$'
    until [[ $languageName =~ $pattern ]]
    do
        echo 'The provided format is incorrect.'
        echo 'The name can only contain letters.'
        read -r languageName
    done

    # Saving language
    local name="${languagePrefix}-${languageName}"
    echo "#$name" >> "$0"

    clear -x

    echo "Language: $name created successfully"


    ########## Generate new translation files ###########

    findScriptFiles

    for file in "${scriptFiles[@]}"
    do
        # Necessary to work with paths
        local fileContent=()
        local parentDirectory
        local filesNames
        local translationFilename="$parentDirectory/${languagePrefix}_${filesNames}.txt"      

        parentDirectory=$(dirname "$file")
        filesNames=$(basename "$file")

        findComments "$file" -R
        findEchoes "$file" -R

        echo "Generating new translation files for: $name" "$file"
        # COMENTARIOS
        local numeration=10
        for lineAndComment in "${commentsFound[@]}"
        do
            
            fileContent+=("#${languagePrefix}-${numeration}-")

            numeration=$((numeration+10))
        done
        
        # ECHOES
        local numeration=10
        for echoLineAndArg in "${echoesFound[@]}"
        do

            IFS=':' read -r echoLine echoArg <<< "$echoLineAndArg"
            echoArg="${echoArg//$'\r'/}"

            # Sacamos los strings literales del argumento de echo
            pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$echoArg")

            if [[ -z "$matches" ]]
            then
                continue
            fi

            # Dentro de cada echo encontrado puede haber varios argumentos
            # A cada argumento le numeramos por separado.
            while IFS= read -r m
            do
                numeration=$((numeration+10))
                fileContent+=("##${languagePrefix}-${numeration}-")
            done <<< "$matches"


        done

        unset 'fileContent[-1]' # POR LO QUE SEA me genera una linea de más. CHAPUZA LA BORRO Y PISTA
        printf "%s\n" "${fileContent[@]}" > "$translationFilename"


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
    read -r languageIdx

    # We check the selection
    until [[ $languageIdx -ge 0 && $languageIdx -le ${#availableLanguages[@]}-1 ]]
    do
        echo 'The selected option is not correct.'
        echo 'Which language do you want to delete?'
        read -r languageIdx
    done
    
    local selection=${availableLanguages[$languageIdx]}
    # I am going to delete the line that has the exact match
    sed -i "/^#$selection$/d" "$0"

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

    read -r languageIdx

    # We check the selection
    # If it is less than 0 the index should not be correct. Although it works too :D. If it is greater than len-1 it is out of range.
    until [[ $languageIdx -ge 0 || $languageIdx -le ${#availableLanguages[@]}-1 ]]
    do
        echo 'The selected option is not correct.'
        echo 'With which language do you want to perform the action?'
        read -r languageIdx
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
        local lines
        local fileContent

        mapfile -t lines < "$file"

        local parentDirectory
        local filesNames
        local translationFile

        parentDirectory=$(dirname "$file")
        filesNames=$(basename "$file")
        translationFile="$parentDirectory/${language}_${filesNames}.txt"   
        

        if [ ! -f "$translationFile" ]
        then
            echo "Cannot swap comments. Translation file not found: $translationFile" >&2 # Hace append, mira arriba el exec 2>>ERROR_LOG
            continue
        fi

        # We ONLY exchange comments WITH references
        findComments "$file" -R
        findEchoes "$file" -R
        

        # ------- Comments --------------------------

        echo "Swapping comments for: $file"
        for lineAndComment in "${commentsFound[@]}"
        do

            local modified_line
    
            IFS=':' read -r numLine comment <<< "$lineAndComment"

            # Extracting data from the reference
            withoutPrefix=${comment#*#[A-Z]*-}
            number="${withoutPrefix%%-*}"

            # I look within the translations file for the one with that number. Just the first match
            translation=$(grep -m1 -E "${language}-${number}" "$translationFile")

            index=$((numLine - 1))
            original_line="${lines[$index]}"

            # I replace the old comment with the translation in the specific line.
            if [ -z "$translation" ]
            then
                # If the translation was not found, insert it empty
                # sed -E -i "${numLine}s@$escapedComment@#${language}-${number}-@" "$file"
                modified_line="${original_line/"$comment"/"#${language}-${number}-"}"

            else
                # If it exists, modify the previous one with the translated one
                # sed -E -i "${numLine}s@${escapedComment}@${escapedCommentWithReference}@" "$file"
                modified_line="${original_line/"$comment"/"$translation"}"
            fi

            lines[index]="$modified_line"


        done

        # ------ Echoes ------------------------------------

        echo "Swapping echos for: $file"

        for lineAndEcho in "${echoesFound[@]}"
        do
            IFS=':' read -r numLine echoArgs <<< "$lineAndEcho"

            local pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$echoArgs")

            while IFS= read -r m
            do
                prefijo_numeracion=$(echo "$m" | grep -oE "##[A-Z]+-[0-9]+-")
                if [[ -z "$prefijo_numeracion" ]]; then
                    continue
                fi

                tmp=${prefijo_numeracion##*-}
                number=${tmp%-}
                prefijo_buscado=$(echo "$prefijo_numeracion" | sed -E "s/[A-Z]+/${language}/")

                echoTraducido=$(grep -m1 -Eo "$prefijo_buscado.*" "$translationFile")
                rest=${echoTraducido#"$prefijo_buscado"}
                rest=${rest%%##*}
                echoTraducido="${prefijo_buscado}${rest}"

                echoTexto=${echoTraducido#"$prefijo_buscado"}

                quoteChar=${m:0:1}
                inner=${echoTexto:1:${#echoTexto}-2}
                inner=${prefijo_buscado}${inner}
                echoTexto="${quoteChar}${inner}${quoteChar}"

                # Buscamos desde la línea actual hacia atrás por si está en multilinea
                echoEncontrado=false
                current_line=$((numLine - 1))
                while (( current_line >= 0 )); do
                    original_line="${lines[$current_line]}"
                    if [[ "$original_line" == *"$m"* ]]; then
                        # Sustitución en memoria
                        lines[current_line]="${original_line/"$m"/"$echoTexto"}"
                        echoEncontrado=true
                        break
                    fi
                    (( current_line-- ))
                done

                # Si no se encontró, insertamos la referencia vacía
                if ! $echoEncontrado; then
                    fallback="#${language}-${number}-"
                    current_line=$((numLine - 1))
                    while (( current_line >= 0 )); do
                        original_line="${lines[$current_line]}"
                        if [[ "$original_line" == *"$m"* ]]; then
                            lines[current_line]="${original_line/"$m"/"$fallback"}"
                            break
                        fi
                        (( current_line-- ))
                    done
                fi

            done <<< "$matches"

        done

         # 👉 Finalmente, reconstruimos el archivo con el contenido modificado
        printf "%s\n" "${lines[@]}" > "$file"
        
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
        sed -i -e 's/##\([A-Z]\{1,\}-[0-9]*\)-//g' "$file" # Delete references echo
        sed -i -e 's/#\([A-Z]\{1,\}-[0-9]*\)-/#/g' "$file" # Delete references comments       
    done

    clear -x

    echo 'Comments have been deleted successfully'

}

function createReferences {
    clear -x


    echo 'WARNING! This option deletes all translation files and generates them empty except for the selected language.'
    echo 'Are you sure you want to proceed with this action? (Y/n)'

    read -r sn

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
        local lines
        local fileContent
        local -A arrayContentTraducciones

        mapfile -t lines < "$file"

        # Inicializar el array de ficheros de traduccion para cada idioma y crear fichero de traduccion
        for i in "${availableLanguages[@]}"
        do
            # i is XX-NameLanguage I have. I'm going to transform i into the prefix
            i=${i:0:2}
            arrayContentTraducciones[i]=""

            parentDirectory=$(dirname "$file")
            out="${parentDirectory}/${i}_$(basename "$file").txt"
            : > "$out"
        done


        # Generar referencias de comentarios numerados --------------------------------------------

        findComments "$file"
        local numeration=10 # Comment counter for each file


        # Iterate each comment
        echo "Generating references for comments in: $file"
        for lineAndComment in "${commentsFound[@]}"
        do
            IFS=':' read -r numLine comment <<< "$lineAndComment"

            parentDirectory=$(dirname "$file")
            filesNames=$(basename "$file")

            for i in "${availableLanguages[@]}"
            do
                i=${i:0:2}
                path="${parentDirectory}/${i}_${filesNames}.txt"

                if [[ $numeration -eq 10 && -f "$path" ]]
                then
                    rm "$path"
                fi

                if [ "$i" = "$language" ]
                then
                    commentWithReference=${comment/'#'/"#${i}-${numeration}-"}

                    index=$((numLine - 1))
                    original_line="${lines[$index]}"
                    modified_line="${original_line/"$comment"/"$commentWithReference"}"
                    lines[index]="$modified_line"


                    arrayContentTraducciones[$i]+="$commentWithReference"$'\n'
                else
                    arrayContentTraducciones[$i]+="#${i}-${numeration}-"$'\n'
                fi
            done

            numeration=$((numeration+10))
        done



        # Generar referencias de echos numerados --------------------------------------------



        # Reiniciar numeracion para cada fichero de echos
        numeration=10

        # Buscamos todos los echos
        findEchoes "$file"
        

        # Iteramos los echos encontrados
        echo "Generating references for echoes in: $file"
        for echoLineAndArg in "${echoesFound[@]}"
        do

            IFS=':' read -r echoLine echoArg <<< "$echoLineAndArg"
            echoArg="${echoArg//$'\r'/}"

            # Sacamos los strings literales del argumento de echo
            pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$echoArg")

            if [[ -z "$matches" ]]
            then
                continue
            fi

            # Para cada literal, modificamos la línea correspondiente
            numeracionInterna="$numeration"
            while IFS= read -r m
            do
                quoteChar="${m:0:1}"
                innerContent="${m:1:-1}"
                echoWithRefTranslation="##${language}-${numeracionInterna}-${quoteChar}${innerContent}${quoteChar}"
                echoWithRefScript="${quoteChar}##${language}-${numeracionInterna}-${innerContent}${quoteChar}"

                # Buscamos en TODAS las líneas de `lines` cuál contiene este literal m,
                # y parcheamos SOLO esa línea.
                for idx in "${!lines[@]}"; do
                if [[ "${lines[idx]}" == *"$m"* ]]; then
                    # hallado: parcheamos
                    
                    line_idx=$((echoLine - 1))
                    original_line="${lines[$line_idx]}"
                    lines[line_idx]="${original_line/"$m"/"$echoWithRefScript"}"

                    # echo "###########"
                    # echo "idx: $idx"
                    # echo "echoLine: $echoLine"
                    # echo "m: $m"
                    # echo "echoWithRefScript: $echoWithRefScript"

                    # una vez parcheada, salimos del for idx
                    break
                fi
                done

                # Acumulamos la traducción para todos los idiomas
                for lang_full in "${availableLanguages[@]}"
                do
                    lang=${lang_full:0:2}
                    if [[ "$lang" == "$language" ]]
                    then
                        arrayContentTraducciones[$lang]+="$echoWithRefTranslation"$'\n'
                    else
                        arrayContentTraducciones[$lang]+="##${lang}-${numeracionInterna}-"$'\n'
                    fi
                done

                (( numeracionInterna += 10 ))
            done <<< "$matches"

            (( numeration = numeracionInterna ))
        done


        #  ─────────────────────────────────────────────────────────
        #  Finalmente, volcamos fileContent de nuevo al archivo:
        #  ─────────────────────────────────────────────────────────
        # Reconstruir fileContent con los cambios realizados
        fileContent=$(printf "%s\n" "${lines[@]}")

        # Finalmente, volcamos fileContent de nuevo al archivo
        printf "%s" "$fileContent" > "$file"

        #  ─────────────────────────────────────────────────────────
        #  Y volcamos los archivos de traducción:
        #  ─────────────────────────────────────────────────────────
        for lang_full in "${availableLanguages[@]}"
        do
            lang=${lang_full:0:2}
            out="${parentDirectory}/${lang}_$(basename "$file").txt"
            printf "%s" "${arrayContentTraducciones[$lang]}" > "$out"
        done
    done

}

function addAdditionalReferences {
    clear -x

    findScriptFiles

    for file in "${scriptFiles[@]}"
    do
        local lines
        local -A arrayContentTraducciones

        mapfile -t lines < "$file"

        for i in "${availableLanguages[@]}"
        do
            i=${i:0:2}
            arrayContentTraducciones[$i]=""
        done

        parentDirectory=$(dirname "$file")
        filesNames=$(basename "$file")

        findComments "$file" -R
        findEchoes "$file" -R

        # --------- Comments ----------------------------------------------------------------------

        echo "Adding additional comments references to: $file"
        for lineAndComment in "${commentsFound[@]}"
        do
            IFS=':' read -r numLine comment <<< "$lineAndComment"
            prefix=${comment:1:2}
            withoutPrefix=${comment#*#[A-Z]*-}
            number="${withoutPrefix%%-*}"

            for i in "${availableLanguages[@]}"
            do
                languagePrefix=${i:0:2}
                translationPath="${parentDirectory}/${languagePrefix}_${filesNames}.txt"

                if [ ! -f "$translationPath" ]; then
                    echo "Cannot add references. Translation file not found: $translationPath" >&2
                    continue
                fi

                mapfile -t translationLines < "$translationPath"
                referenceFound=$(printf "%s\n" "${translationLines[@]}" | grep -m1 -E "^#${languagePrefix}-${number}-")

                if [ -z "$referenceFound" ]; then
                    previousNumber=$((number - 1))
                    while [ $previousNumber -ge 0 ]; do
                        for idx in "${!translationLines[@]}"; do
                            if [[ "${translationLines[$idx]}" =~ ^#${languagePrefix}-${previousNumber}- ]]; then
                                newContent=("${translationLines[@]:0:$((idx+1))}")
                                if [ "$prefix" = "$languagePrefix" ]; then
                                    newContent+=("$comment")
                                else
                                    newContent+=("#${languagePrefix}-${number}-")
                                fi
                                newContent+=("${translationLines[@]:$((idx+1))}")
                                translationLines=("${newContent[@]}")
                                previousNumber=-1
                                break
                            fi
                        done
                        previousNumber=$((previousNumber - 1))
                    done
                fi

                printf "%s\n" "${translationLines[@]}" > "$translationPath"
            done
        done

        # ---- Echoes -----------------------------------------------------------------------------

        echo "Adding additional echoes references to: $file"
        for lineAndEchoArg in "${echoesFound[@]}"
        do
            IFS=':' read -r numLine arg <<< "$lineAndEchoArg"
            pattern="\"([^\"\\\\]|\\\\.)*\"|'[^']*'"
            matches=$(grep -oE "$pattern" <<< "$arg")

            while IFS= read -r m
            do
                prefijo_numeracion=$(echo "$m" | grep -oE "##[A-Z]+-[0-9]+-")
                if [[ -z "$prefijo_numeracion" ]]; then continue; fi

                tmp="${prefijo_numeracion#*-}"
                tmp="${tmp%-}"
                number="$tmp"

                inner=$(echo "$m" | sed -E "s/##[A-Za-z]+-[0-9]+-//")
                echoTexto="${prefijo_numeracion}${inner}"

                for i in "${availableLanguages[@]}"
                do
                    languagePrefix=${i:0:2}
                    translationPath="${parentDirectory}/${languagePrefix}_${filesNames}.txt"

                    if [ ! -f "$translationPath" ]; then
                        echo "Cannot add references. Translation file not found: $translationPath" >&2
                        continue
                    fi

                    mapfile -t translationLines < "$translationPath"
                    referenceFound=$(printf "%s\n" "${translationLines[@]}" | grep -m1 -Eo "^##${languagePrefix}-${number}-")

                    if [ -z "$referenceFound" ]; then
                        previousNumber=$((number - 1))
                        while [ $previousNumber -ge 0 ]; do
                            for idx in "${!translationLines[@]}"; do
                                if [[ "${translationLines[$idx]}" =~ ^##${languagePrefix}-${previousNumber}- ]]; then
                                    newContent=("${translationLines[@]:0:$((idx+1))}")
                                    if [ "$prefix" = "$languagePrefix" ]; then
                                        newContent+=("$echoTexto")
                                    else
                                        newContent+=("##${languagePrefix}-${number}-")
                                    fi
                                    newContent+=("${translationLines[@]:$((idx+1))}")
                                    translationLines=("${newContent[@]}")
                                    previousNumber=-1
                                    break
                                fi
                            done
                            previousNumber=$((previousNumber - 1))
                        done
                    fi

                    printf "%s\n" "${translationLines[@]}" > "$translationPath"
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
            sed -i "${numLine}s/#${prefix}-${number}-/#${prefix}-${loopNumeration}-/" "$file"
            
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
                    echo "Cannot renumerate references. Translation file not found: $translationPath" >&2 # Hace append, mira arriba el exec 2>>ERROR_LOG
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
        loopNumeration=10
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

                    # Verificamos si el archivo existe y es válido
                    if [ ! -f "$translationPath" ]
                    then
                        echo "Cannot reenumerate references. Translation file not found: $translationPath" >&2 # Hace append, mira arriba el exec 2>>ERROR_LOG
                        continue # Saltamos a la siguiente iteración si no existe el archivo de traduccion
                    fi
                    
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
    until [[ $opcion -gt 0 && $opcion -lt 7 ]]
    do
        echo '1) Generate references for comments and extract them to translation files'
        echo '2) Swap language of referenced comments'
        echo '3) Add new referenced comments to translation file'
        echo '4) Delete existing references'
        echo '5) Re-number references'
        echo '6) Back'


        read -r opcion
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
    until [[ $opcion -gt 0 && $opcion -lt 5 ]]
    do
        echo '1) Add language'
        echo '2) Delete language'
        echo '3) View available languages'
        echo '4) Back'


        read -r opcion
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
	until [[ $opcion -gt 0 && $opcion -lt 4 ]]
    do
        echo '1) Comments'
        echo '2) Languages'
        echo '3) Exit'


        read -r opcion
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

# findEchoes './test/script.sh'

##############################
## Available languages
## You can but SHOULD NOT add and remove from the same script.
## DO NOT insert manually! Because it would NOT generate the
## necessary translation files.
##############################
#EN-English
#ES-Español
#FR-Français
