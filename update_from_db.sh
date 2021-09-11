#!/usr/bin/env bash
# This script is for pulling data from the database

mainUpdate() {

    updateItemFromDB() {
        idOfItemToUpdate="$2"
        confirmUpdateQ() {
            printf "\nUpdate snippet %s Y/N?\n" "${idOfItemToUpdate}"
        }

        result=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToUpdate}\"")
        codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToUpdate}\"" 'off')
        sedRes="${codeResult/qu\@/\"/}"

        if [[ -z $result ]]; then
            echo "Does not exist"
            exit
        fi

        confirmUpdateQ
        printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$result" "$sedRes"

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
            result=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToUpdate}\"")
            codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToUpdate}\"" 'off')
            sedRes="${codeResult/qu\@/\"/}"
            printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$result" "$sedRes"

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
