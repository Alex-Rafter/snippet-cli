#!/usr/bin/env bash
#-------------------------------------------------------
#1 Global Variables : START
#-------------------------------------------------------
# shellcheck source=global_vars.sh
source global_vars.sh

#-------------------------------------------------------
# 2 Global Funcs : START
#-------------------------------------------------------
# shellcheck source=global_functions.sh
source global_functions.sh

mainUpdate() {

    updateItemFromDB() {

        local idOfItemToUpdate="$2"

        confirmUpdateQ() {
            printf "\nUpdate snippet %s Y/N?\n" "${idOfItemToUpdate}"
        }

        local result
        result=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToUpdate}\"")
        local codeResult
        codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToUpdate}\"" 'off')
        local sedRes="${codeResult//qu\@/\"}"

        if [[ -z $result ]]; then
            echo "Does not exist"
            exit
        fi

        confirmUpdateQ
        printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$result" "$sedRes"

        local updateBool
        read -r updateBool

        if [[ $updateBool == "y" ]]; then

            updateSQL="$(printf "SET %s = '%s'" "$3" "$4")"
            sqlite3.exe "${dbConnection}" <<EOF
UPDATE scripts 
${updateSQL}
WHERE id=${idOfItemToUpdate};
EOF

            # Log out updated version of snippet
            printf "\n Done! Snippet %s Now:\n" "${idOfItemToUpdate}"

            local updatedResult
            updatedResult=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToUpdate}\"")
            local updatedCodeResult
            updatedCodeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToUpdate}\"" 'off')
            local sedRes="${updatedCodeResult//qu\@/\"}"

            printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$updatedResult" "$sedRes"

        else

            exit
        fi
    }

    #-------------------------------------------------------
    # Conditional Function Calls
    #-------------------------------------------------------

    if [[ -z $4 ]]; then
        echo 'Set $3 as column and $4 as value'
        exit
    else
        updateItemFromDB "$@"
        exit
    fi

}
