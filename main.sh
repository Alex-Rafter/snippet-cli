#!/usr/bin/env bash

#-------------------------------------------------------
#1 Global Variables
#2 Global Functions
#3 Help
#4 Main Funcs
#5 Conditional Function Calls
#-------------------------------------------------------

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

#-------------------------------------------------------
# 3 Help : START
#-------------------------------------------------------
# shellcheck source=help.sh
source help.sh

#-------------------------------------------------------
# 4 Main Funcs : START
#-------------------------------------------------------
# shellcheck source=push_to_db.sh
source push_to_db.sh
# shellcheck source=pull_from_db.sh
source pull_from_db.sh
# shellcheck source=update_from_db.sh
source update_from_db.sh
# shellcheck source=delete_from_db.sh
source delete_from_db.sh

#-------------------------------------------------------
# 5 Conditional Function Calls : START
#-------------------------------------------------------

while getopts "o:duh" option; do
    case $option in
    o) # display Help
        mainPull "${@:2}"
        exit
        ;;
    d) # display Help
        mainDelete "$@"
        exit
        ;;
    u) # display Help
        mainUpdate "$@"
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

noResults() {
    echo "No results. Pass -h?"
}

if [[ -z $1 ]]; then
    noResults
else
    mainPush "$@"
fi
