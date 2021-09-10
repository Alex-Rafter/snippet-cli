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
	colsToLog='ID,description,tags'
	modeToUse='table'

	if [[ -z "$2" ]]; then
		echo "Description search (single word is best)"
		read -r descriptionToSearch
	else
		descriptionToSearch="$2"
	fi


	formattedDescriptionToSearch=$(formatForLIKESQuerySQL "$descriptionToSearch")
	result=$(SQLQuery ".mode $modeToUse" "SELECT $colsToLog FROM scripts WHERE description LIKE \"${formattedDescriptionToSearch}\"")
	formattedResult=$(reFormatQuotedStrings "$result")
	printResults "$formattedResult"
	checkIfNowRenderSnippet "$formattedResult"

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
	checkIfNowRenderSnippet "$formattedResult"

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
