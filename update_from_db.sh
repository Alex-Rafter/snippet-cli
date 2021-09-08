#!/usr/bin/env bash
# This script is for pulling data from the database

# *******************************
# HELP LOGIC
# *******************************
dbConnection='/c/Users/rafte/snippet/db/scripts_n_snips.db'
NC='\033[0m'
hiColour='\033[0;36m'

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
    result=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT id,description,tags FROM scripts WHERE ID="${idOfItemToUpdate}"
EOF
    )
    codeResult=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode quote
SELECT code FROM scripts WHERE ID="${idOfItemToUpdate}"
EOF
    )
    if [[ -z $result ]]; then
        echo "Does not exist"
        exit
    fi

    confirmUpdateQ
    sedRes=$(echo "$codeResult" | sed 's/qu\@/\"/g')
    printf "\n${NC}%s\n\n${hiColour}%s\n\n${NC}" "$result" "$sedRes"

    read updateBool
    if [[ $updateBool == "y" ]]; then
        # printf "1:%s, 2%s:, 3:%s, 4:%s" "$1" "$2" "$3" "$4"
        updateSQL="$(printf "SET %s = '%s'" "$3" "$4")"
        # echo "${updateSQL}"

        sqlite3.exe "${dbConnection}" <<EOF
UPDATE scripts 
${updateSQL}
WHERE id=${idOfItemToUpdate};
EOF
        printf "\n Done! Snippet %s Now:\n" "${idOfItemToUpdate}"
            result=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT id,description,tags FROM scripts WHERE ID="${idOfItemToUpdate}"
EOF
    )
    codeResult=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode quote
SELECT code FROM scripts WHERE ID="${idOfItemToUpdate}"
EOF
    )
        sedRes=$(echo "$codeResult" | sed 's/qu\@/\"/g')
    printf "\n${NC}%s\n\n${hiColour}%s\n\n${NC}" "$result" "$sedRes"


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
