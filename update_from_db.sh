#!/usr/bin/env bash
# This script is for pulling data from the database

#-------------------------------------------------------
#1 Global Variables : START
#-------------------------------------------------------
# shellcheck source=global_vars.sh
source global_vars.sh

#-------------------------------------------------------
#1 Global Variables : END
#-------------------------------------------------------

#-------------------------------------------------------
# 2 Global Funcs : START
#-------------------------------------------------------
# shellcheck source=global_functions.sh
source global_functions.sh

#-------------------------------------------------------
# 2 Global Funcs : END
#-------------------------------------------------------

# *******************************
# HELP LOGIC
# *******************************

help() {

    cat <<HEREDOC

*******************************
LOG SNIPPET FROM DB
*******************************

options: 
    -h: help
	-a: show all
	-o: search by tag
	-d: search by description

SNIPPET TO STDOUT
[-a,-o,-d,-h]

SEARCH BY TAG
example: pull_from_db.sh -o

SEARCH BY DESCRIPTION
pull_from_db.sh -d

SEARCH ALL
example: pull_from_db.sh -a

HEREDOC

}

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

while getopts ":uh" option; do
    case $option in
    u) # display Help
        if [[ -z $4 ]]; then
            echo 'Set $3 as col and $4 value'
        else
            updateItemFromDB "$@"
        fi
        exit
        ;;
    h) # display Help
        help
        exit
        ;;
    \?) # Invalid option
        echo "Error: Invalid option"
        exit
        ;;
    esac
done
