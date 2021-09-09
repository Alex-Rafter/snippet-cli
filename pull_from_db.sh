#!/usr/bin/env bash
# This script is for pulling data from the database

#-------------------------------------------------------
#1 Global Variables
#2 Global Functions
#3 Main Functaionality: Serach by tag, description, etc
#4 Conditional function calls (based on flags passed)
#-------------------------------------------------------

#-------------------------------------------------------
#1 Global Variables : START
#-------------------------------------------------------
dbConnection='/c/Users/rafte/snippet/db/scripts_n_snips.db'
NC='\033[0m'
hiColour='\033[0;36m'
#-------------------------------------------------------
#1 Global Variables : END
#-------------------------------------------------------

#-------------------------------------------------------
# 2 Global Funcs : START
#-------------------------------------------------------

reFormatQuotedStrings() {
	echo "$1" | sed 's/qu\@/\"/g'
}

SQLQuery() {
	# Args: $1 = .mode, $2 = query statement $3 = .headers (optional)
	[[ $3 == "off" ]] && headers='.headers off' || headers='.headers on'
	sqlite3.exe "${dbConnection}" <<EOF
$headers
$1
$2
EOF
}

searchDBByChosenId() {
	echo 'id or -a'
	read -r chosenID
	IDsToPass=$(echo "$1" | awk 'BEGIN { FS="|"}; {if (NR>3) print $2}' | tr -d '\n' | sed -e 's/\s\s/,/g' -e 's/\s//g')
	[[ $chosenID == "-a" ]] && chosenID="$IDsToPass"
	searchDBByID '-i' "$chosenID"
}

logSummaryThenCode() {
	summaryResult=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${IDToSearch}\"" 'off')
	codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${IDToSearch}\"")
	printf "\n${NC}%sn\n${hiColour}%s\n" "$summaryResult" "$(reFormatQuotedStrings "$codeResult")"
}

formatForLIKESQuerySQL() {
	echo "$1" | sed -r 's/(^|$)/\%/g'
}

printResults() {
	if [[ ! $1 ]]; then
		echo "No results found"
		exit
	else
		echo "$1"
	fi
}

#-------------------------------------------------------
# 2 Global Funcs : END
#-------------------------------------------------------

#-------------------------------------------------------
#3 Main Script Functionality : START
#-------------------------------------------------------

# Log Out HELP : START
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
# Log Out HELP : END

# Search by ID : START
searchDBByID() {
	IdArgs=$(echo "${@:2}" | tr "," "\n")
	for indvID in $IdArgs; do
		IDToSearch="$indvID"
		logSummaryThenCode
	done
}

# Search by ID : END

# Search by DESCRIPTION : START
searchDBByDescription() {
	if [[ -z "$2" ]]; then
		echo "Description search (single word is best)"
		read -r descriptionToSearch
		colsToLog='ID,description,tags'
		modeToUse='table'
	else
		descriptionToSearch="$2"
		colsToLog='ID,description,tags'
		modeToUse='table'
	fi

	formattedDescriptionToSearch=$(formatForLIKESQuerySQL "$descriptionToSearch")
	result=$(SQLQuery ".mode $modeToUse" "SELECT $colsToLog FROM scripts WHERE description LIKE \"${formattedDescriptionToSearch}\"")
	formattedResult=$(reFormatQuotedStrings "$result")
	printResults "$formattedResult"

	echo 'code? y/n'
	read -r answer

	if [[ $answer == "y" ]]; then
		searchDBByChosenId "$formattedResult"
	else
		exit
	fi

}
# Search by DESCRIPTION : END

# Search by TAG : START
searchDBByTag() {
	if [[ -z "$2" ]]; then
		echo "Tags to search"
		read -r tagsToSearch
	else
		tagsToSearch="$2"
	fi

	fomattedTags=$(formatForLIKESQuerySQL "$tagsToSearch")
	result="$(SQLQuery '.mode table' "SELECT ID,description,tags FROM scripts WHERE tags LIKE \"${fomattedTags}\"")"
	formattedResult="$(reFormatQuotedStrings "$result")"
	printResults "$formattedResult"

	echo 'code? y/n'
	read -r answer

	if [[ $answer == "y" ]]; then
		searchDBByChosenId "$formattedResult"
	else
		exit
	fi

}
# Search by TAG : END

# Seach ALL in DB : START
allFromDB() {
	result=$(SQLQuery '.mode list' 'SELECT * FROM scripts')
	reFormatQuotedStrings "$result"
}
# Seach ALL in DB : END

#-------------------------------------------------------
#3 Main Script Functionality : START
#-------------------------------------------------------

#-------------------------------------------------------
# 4 Conditional Flags : START
#-------------------------------------------------------
while getopts ":aitdh" option; do
	case $option in
	a) # display Help
		allFromDB
		exit
		;;
	t) # display Help
		searchDBByTag "$@"
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

# Search ALL if No Args
if [[ -z $1 ]]; then allFromDB; fi

#-------------------------------------------------------
# 4 Conditional Flags : END
#-------------------------------------------------------
