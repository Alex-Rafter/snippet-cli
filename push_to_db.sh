#!/usr/bin/env bash
# This script is for pushing data to the database

# *******************************
# HELP LOGIC
# *******************************

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
PUSH SCRIPTS AND 1 LINERS TO DB
*******************************

options: 
    -h: help
    -1: one-liner 

SYNTAX
[-1,-h] description, tags, file.sh
example: args_to_db.sh 'update values in db' 'awk,parasol' example.sh

ONE-LINER
-1 description, tags
one-liner example: args_to_db.sh -1 'update values in db' 'awk,parasol'

HEREDOC
}

# *******************************
# MAIN SCRIPT LOGIC
# *******************************

fileInDB() {
	local descriptionToAdd="$2"
	local tagsToAdd="$3"
	local editedCodeToAdd

	editedCodeToAdd=$(FormatSnippetForDBInput "$4")
	SQLQuery '' "INSERT into scripts (description,code,tags) VALUES(\"$descriptionToAdd\",\"$editedCodeToAdd\",\"$tagsToAdd\");"
}

oneLinerInDB() {

	readInCodeToAdd() {
		echo "Paste 1 liner."
		read -r codeToAdd
	}

	mainFunc() {
		local descriptionToAdd="$2"
		local tagsToAdd="$3"
		local codeToAdd
		[[ $# -eq 3 ]] && readInCodeToAdd || codeToAdd="$4"
		local editedCodeToAdd

		editedCodeToAdd=$(FormatSnippetForDBInput "$codeToAdd")
		SQLQuery '' "INSERT into scripts (description,code,tags) VALUES(\"$descriptionToAdd\",\"$editedCodeToAdd\",\"$tagsToAdd\")"
	}

	if [[ "$#" -lt 3 ]]; then
		echo "Provide more args. Or run -h"
	else
		mainFunc "$@"
	fi

}

# *******************************
# CONDITIONAL TRIGGERS FROM FLAGS
# *******************************

while getopts ":h1f" option; do
	case $option in
	1) # display Help
		oneLinerInDB "$@"
		exit
		;;
	h) # display Help
		help
		exit
		;;
	f) # display Help
		fileInDB "$@"
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
	help
else
	oneLinerInDB '-1' "$@"
fi
