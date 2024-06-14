#!/bin/bash

language='EN' # Default language to work with

declare -a availableLanguages 
declare -a scriptFiles
declare -a commentsFound

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
    echo "Generating new translation files for the language: $name"

    findScriptFiles

    for file in "${scriptFiles[@]}"
    do
        # Necessary to work with paths
        local parentDirectory=$(dirname "$file")
        local filesNames=$(basename "$file")

        # Generating the file for each script
        touch "$parentDirectory/${languagePrefix}_${filesNames}.txt"

        findComments "$file" -R
        
        for lineAndComment in "${commentsFound[@]}"
        do
            # Informative message; to know which files have been modified
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
    clear -x

    selectLanguage
    findScriptFiles
    
    echo 'Swapping comments'

    # Indicator that the process is running

    for file in "${scriptFiles[@]}"
    do
        local parentDirectory=$(dirname "$file")
        local filesNames=$(basename "$file")
        local translationFile="${parentDirectory}/${language}_${filesNames}.txt" # This is the translation file for this script file

        clear -x

        if [ ! -f "$translationFile" ]
        then
            echo "Translation file not found: $translationFile"
            continue
        fi

        # We ONLY exchange comments WITH references
        findComments $file -R

        for lineAndComment in "${commentsFound[@]}"
        do
            # Informative message; to know which files have been modified

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
    done

    echo 'Comments have been replaced successfully'

}

function deleteReferences {
    clear -x

    # INFO message about files found
    echo 'All references in script files will be deleted.'

    findScriptFiles
    
    # Indicator that the process is running

    for file in "${scriptFiles[@]}"
    do
        # Informative message; to know which files have been modified
        echo "Deleting references from: $file"
        sed -i -e 's/#\([A-Z]\{1,\}-[0-9]*\)-/#/g' $file        
    done

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

    deleteReferences
    findScriptFiles 



    # Iterate each file and generate its .txt
    for file in "${scriptFiles[@]}"
    do
        echo "Generating references for: $file"

        findComments $file

        numeration=10 # Comment counter for each file

        # Iterate each comment
        for lineAndComment in "${commentsFound[@]}"
        do
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

        # Iterate each comment
        for lineAndComment in "${commentsFound[@]}"
        do
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
    done

    echo 'Additional comments have been added'
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

        # Iterate each comment
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
    done

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
            clear -x
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

    local opcion=0

    # Validation that a correct option has been chosen
	until ([[ $opcion > 0 && $opcion < 4 ]])
    do
        clear -x
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
