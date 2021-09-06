#!/usr/bin/env bash
# This script is for pushing data to the database

# *******************************
# HELP LOGIC
# *******************************

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
	descriptionToAdd="$1"
	tagsToAdd="$2"
	editedCodeToAdd=$(cat "$3" | sed -e '1d' -e 's/\"/qu@/g' | xargs -0)

	sqlite3.exe ./db/scripts_n_snips.db <<EOF
INSERT into scripts (description,code,tags)
VALUES("$descriptionToAdd","$editedCodeToAdd","$tagsToAdd");
EOF
}

oneLinerInDB() {
	mainFunc () {
	descriptionToAdd="$2"
	tagsToAdd="$3"
	echo "Paste 1 liner."
	read -r codeToAdd
	editedCodeToAdd=$(echo "$codeToAdd" | sed 's/\"/qu@/g' | xargs -0)

	sqlite3.exe ./db/scripts_n_snips.db <<EOF
INSERT into scripts (description,code,tags)
VALUES("$descriptionToAdd","$editedCodeToAdd","$tagsToAdd");
EOF
	}

if [[ $2 == "" ]]; then
	echo "Provide more args. Or run -h"
else 
	mainFunc "$@"
fi

}

# *******************************
# CONDITIONAL TRIGGERS FROM FLAGS
# *******************************

while getopts ":h1" option; do
	case $option in
	1) # display Help
		oneLinerInDB "$@"
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
    help
else 
	fileInDB "$@"
fi


