#!/usr/bin/env bash
# This script is for pushing data to the database

# *******************************
# HELP LOGIC
# *******************************
dbConnection='/c/Users/rafte/snippet/db/scripts_n_snips.db'

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
	descriptionToAdd="$2"
	tagsToAdd="$3"
	editedCodeToAdd=$(cat "$4" | sed -e '1d' -e 's/\"/qu@/g' | xargs -0)

	sqlite3.exe "${dbConnection}" <<EOF
INSERT into scripts (description,code,tags)
VALUES("$descriptionToAdd","$editedCodeToAdd","$tagsToAdd");
EOF
}

oneLinerInDB() {

	mainFunc() {
		descriptionToAdd="$2"
		tagsToAdd="$3"
		echo "Paste 1 liner."
		read -r codeToAdd
		editedCodeToAdd=$(echo "$codeToAdd" | sed 's/\"/qu@/g' | xargs -0)

		sqlite3.exe "${dbConnection}" <<EOF
INSERT into scripts (description,code,tags)
VALUES("$descriptionToAdd","$editedCodeToAdd","$tagsToAdd");
EOF
	}

	argsOnlyToDB() {
		descriptionToAdd="$2"
		tagsToAdd="$3"
		codeToAdd="$4"
		editedCodeToAdd=$(echo "$codeToAdd" | sed 's/\"/qu@/g' | xargs -0)
		echo "Args are $2, $3, $4,"

		sqlite3.exe "${dbConnection}" <<EOF
INSERT into scripts (description,code,tags)
VALUES("$descriptionToAdd","$editedCodeToAdd","$tagsToAdd");
EOF
	}

	if [[ "$#" -lt 3 ]]; then
		echo "Provide more args. Or run -h"
	elif [[ "$#" -eq 3 ]]; then
		mainFunc "$@"
	elif [[ "$#" -gt 3 ]]; then
		argsOnlyToDB "$@"
	fi

}
# if [[ $2 == "" ]]; then
# 	echo "Provide more args. Or run -h"
# else
# 	mainFunc "$@"
# fi

# }

# *******************************
# CONDITIONAL TRIGGERS FROM FLAGS
# *******************************

while getopts ":h1pf" option; do
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
