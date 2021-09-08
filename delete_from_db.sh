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

deleteItemFromDB() {
    idOfItemToDelete="$2"
    echo "Id is $idOfItemToDelete"
    confirmDeleteQ() {
        printf "\nDelete snippet %s Y/N?\n" "${idOfItemToDelete}"
    }
    result=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT id,description,tags FROM scripts WHERE ID="${idOfItemToDelete}"
EOF
    )
    codeResult=$(
        sqlite3.exe "${dbConnection}" <<EOF
.mode quote
SELECT code FROM scripts WHERE ID="${idOfItemToDelete}"
EOF
    )
    if [[ -z $result ]]; then
        echo "Does not exist"
        echo "you passed $1 $2"
        exit
    fi

    confirmDeleteQ
    sedRes=$(echo "$codeResult" | sed 's/qu\@/\"/g')
    printf "\n${NC}%s\n\n${hiColour}%s\n\n${NC}" "$result" "$sedRes"

    read deleteBool
    if [[ $deleteBool == "y" ]]; then
        sqlite3.exe "${dbConnection}" <<EOF
DELETE from scripts WHERE id=${idOfItemToDelete};
EOF
        printf "\n Done!"
    else
        exit
    fi
}

while getopts ":dh" option; do
    case $option in
    d) # display Help
        deleteItemFromDB "$@"
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

if [[ $1 == "" ]]; then
    echo "No arguments provided"
    # help
else
    deleteItemFromDB "$@"
fi
