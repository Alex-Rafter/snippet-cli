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

mainDelete() {

    deleteItemFromDB() {
        local idOfItemToDelete="$2"
        confirmDeleteQ() {
            printf "\nDelete snippet %s Y/N?\n" "${idOfItemToDelete}"
        }

        local result
        result=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${idOfItemToDelete}\"")
        local codeResult
        codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${idOfItemToDelete}\"" 'off')
        local sedRes="${codeResult/qu\@/\"/}"

        # Messages to screen : START
        if [[ -z $result ]]; then
            printf "Does not exist\nYou passed id: %s" "$2"
            exit
        fi

        confirmDeleteQ
        printf "\n${noColour}%s\n\n${hiColour}%s\n\n${noColour}" "$result" "$sedRes"
        local deleteBool
        read -r deleteBool
        # Messages to screen : END

        if [[ $deleteBool == "y" ]]; then
            SQLQuery '' "DELETE from scripts WHERE id=${idOfItemToDelete}"
            printf "\nDone baby!"
        else
            exit
        fi
    }

    #-------------------------------------------------------
    # Conditional Function Calls
    #-------------------------------------------------------

    # Search ALL if No Args
    if [[ -z $2 ]]; then
        echo 'Pass ID of item to delete'
        exit
    else
        deleteItemFromDB "$@"
        exit
    fi
}
