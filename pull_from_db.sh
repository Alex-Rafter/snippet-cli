#!/usr/bin/env bash
# This script is for pulling data from the database

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

searchDBByDescription() {
	if [[ -z "$2" ]]; then
		echo "Description search (single word is best)"
		read -r descriptionWordsToSearch
	else
		descriptionWordsToSearch="$2"
	fi

	sedDescriptionWordsToSearch=$(echo "$descriptionWordsToSearch" | sed -r 's/(^|$)/\%/g')
	result=$(
		sqlite3.exe ./db/scripts_n_snips.db <<EOF
.headers on
.mode table
SELECT ID,description,tags FROM scripts WHERE description LIKE "${sedDescriptionWordsToSearch}"
EOF
	)

	seddy=$(echo "$result" | sed -e 's/qu\@/\"/g' -e 's/;//g')
	printResults "$seddy"

}

printResults() {
	if [[ ! $1 ]]; then
		echo "No results found"
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
		sqlite3.exe ./db/scripts_n_snips.db <<EOF
.headers on
.mode table
SELECT ID,description,tags FROM scripts WHERE tags LIKE "${sedTags}"
EOF
	)
	seddy=$(echo "$result" | sed -e 's/qu\@/\"/g' -e 's/;//g')
	printResults "$seddy"
}

allDB() {
	result=$(
		sqlite3.exe ./db/scripts_n_snips.db <<EOF
.mode list
SELECT * FROM scripts
EOF
	)
	sedRes=$(echo "$result" | sed 's/qu\@/\"/g')
	echo "$sedRes"
}

searchDBByID () {
	   IDToSearch="$1"
   result=$(
      sqlite3.exe ./db/scripts_n_snips.db <<EOF
.mode line
SELECT * FROM scripts WHERE ID="${IDToSearch}"
EOF
   )
   	sedRes=$(echo "$result" | sed 's/qu\@/\"/g')
	echo "$sedRes"
}

while getopts ":aodh" option; do
	case $option in
	a) # display Help
		allDB
		exit
		;;
	o) # display Help
		outDB "$@"
		exit
		;;
	d) # display Help
		searchDBByDescription "$@"
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
	searchDBByID "$@"
fi

