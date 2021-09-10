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
    confirmDeleteQ() {
        printf "\nDelete snippet %s Y/N?\n" "${idOfItemToDelete}"
    }

    result=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToDelete}\"")
    codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToDelete}\"" 'off')
    sedRes="${codeResult/qu\@/\"/}"

    # Messages to screen : START
    if [[ -z $result ]]; then
        printf "Does not exist\nYou passed id: %s" "$2"
        exit
    fi

    confirmDeleteQ
    printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$result" "$sedRes"
    read -r deleteBool
    # Messages to screen : END

    if [[ $deleteBool == "y" ]]; then
        SQLQuery '' "DELETE from scripts WHERE id=${idOfItemToDelete}"
        printf "\nDone baby!"
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
