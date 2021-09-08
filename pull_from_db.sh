#!/usr/bin/env bash
# This script is for pulling data from the database

# *******************************
# HELP LOGIC
# *******************************
dbConnection='/c/Users/rafte/snippet/db/scripts_n_snips.db'
NC='\033[0m'
hiColour='\033[0;36m'

# Global Funcs
searchDBByChosenId() {
	echo 'id or -a'
	read -r chosenID
	IDsToPass=$(echo "$seddy" | awk 'BEGIN { FS="|"}; {if (NR>3) print $2}' | tr -d '\n' | sed -e 's/\s\s/,/g' -e 's/\s//g')
	[[ $chosenID == "-a" ]] && chosenID="$IDsToPass"
	searchDBByID '-i' "$chosenID"
}

logSummaryThenCode() {
	result=$(
		sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT id,description,tags FROM scripts WHERE ID="${IDToSearch}"
EOF
	)
	codeResult=$(
		sqlite3.exe "${dbConnection}" <<EOF
.mode quote
SELECT code FROM scripts WHERE ID="${IDToSearch}"
EOF
	)

	sedRes=$(echo "$codeResult" | sed 's/qu\@/\"/g')
	printf "\n${NC}$result\n\n${hiColour}$sedRes\n"
}

# Global Funcs : END

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

searchDBByID() {
	IdArgs=$(echo "${@:2}" | tr "," "\n")
	for indvID in $IdArgs; do
		IDToSearch="$indvID"
		logSummaryThenCode
	done
}

searchDBByDescription() {
	if [[ -z "$2" ]]; then
		echo "Description search (single word is best)"
		read -r descriptionWordsToSearch
		colsToLog='ID,description,tags'
		modeToUse='table'
	else
		descriptionWordsToSearch="$2"
		colsToLog='ID,description,tags'
		modeToUse='table'
	fi

	sedDescriptionWordsToSearch=$(echo "$descriptionWordsToSearch" | sed -r 's/(^|$)/\%/g')
	result=$(
		sqlite3.exe "${dbConnection}" <<EOF
.headers on
.mode $modeToUse
SELECT $colsToLog FROM scripts WHERE description LIKE "${sedDescriptionWordsToSearch}"
EOF
	)

	seddy=$(echo "$result" | sed -e 's/qu\@/\"/g' -e 's/;//g')
	printResults "$seddy"
	echo 'code? y/n'
	read answer
	if [[ $answer == "y" ]]; then
		searchDBByChosenId

	else
		exit
	fi

}

printResults() {
	if [[ ! $1 ]]; then
		echo "No results found"
		exit
	else
		echo "$1"
	fi
}

outDB() {
	if [[ -z "$2" ]]; then
		echo "Tags to search"
		read -r tagsToSearch
	else
		tagsToSearch="$2"
	fi

	sedTags=$(echo "$tagsToSearch" | sed -r 's/(^|$)/\%/g')
	result=$(
		sqlite3.exe "${dbConnection}" <<EOF
.headers on
.mode table
SELECT ID,description,tags FROM scripts WHERE tags LIKE "${sedTags}"
EOF
	)
	seddy=$(echo "$result" | sed -e 's/qu\@/\"/g' -e 's/;//g')
	printResults "$seddy"

	echo 'code? y/n'
	read answer
	if [[ $answer == "y" ]]; then
		searchDBByChosenId
		# IDsToPass=$(echo "$seddy" | awk 'BEGIN { FS="|"}; {if (NR>3) print $2}' | tr -d '\n' | sed -e 's/\s\s/,/g' -e 's/\s//g')
		# searchDBByID '-i' "$IDsToPass"
	else
		exit
	fi

}

allDB() {
	result=$(
		sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT * FROM scripts
EOF
	)
	sedRes=$(echo "$result" | sed 's/qu\@/\"/g')
	echo "$sedRes"
}

while getopts ":aitdh" option; do
	case $option in
	a) # display Help
		allDB
		exit
		;;
	t) # display Help
		outDB "$@"
		exit
		;;
	d) # display Help
		searchDBByDescription "$@"
		exit
		;;
	i) # display Help
		searchDBByID "$@"
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
	allDB
	# echo "No arguments provided"
	# help
else
	allDB
fi
