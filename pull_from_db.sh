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

mainPull() {

	# Search by DESCRIPTION : START
	searchDBByDescription() {
		local colsToLog='ID,description,tags'
		local modeToUse='table'

		local descriptionToSearch
		if [[ -z "$2" ]]; then
			echo "Description search (single word is best)"
			read -r descriptionToSearch
		else
			descriptionToSearch="$2"
		fi

		local formattedDescriptionToSearch
		formattedDescriptionToSearch=$(formatForLIKESQuerySQL "$descriptionToSearch")
		local result
		result=$(SQLQuery ".mode $modeToUse" "SELECT $colsToLog FROM scripts WHERE description LIKE \"${formattedDescriptionToSearch}\"")
		local formattedResult
		formattedResult=$(reFormatQuotedStrings "$result")
		printResults "$formattedResult"
		checkIfNowRenderSnippet "$formattedResult"

	}
	# Search by DESCRIPTION : END

	# Search by TAG : START
	searchDBByTag() {
		local tagsToSearch

		if [[ -z "$2" ]]; then
			echo "Tags to search"
			read -r tagsToSearch
		else
			tagsToSearch="$2"
		fi

		local fomattedTags
		fomattedTags=$(formatForLIKESQuerySQL "$tagsToSearch")
		local result
		result="$(SQLQuery '.mode table' "SELECT ID,description,tags FROM scripts WHERE tags LIKE \"${fomattedTags}\"")"
		local formattedResult
		formattedResult="$(reFormatQuotedStrings "$result")"
		printResults "$formattedResult"
		checkIfNowRenderSnippet "$formattedResult"

	}

	# Search by TAG : END

	# Seach ALL in DB : START
	allFromDB() {
		local result
		result=$(SQLQuery '.mode list' 'SELECT * FROM scripts')
		reFormatQuotedStrings "$result"
	}
	# Seach ALL in DB : END

	#-------------------------------------------------------
	# Conditional Function Calls
	#-------------------------------------------------------

	# Search ALL if No Args
	if [[ -z $1 ]]; then
		allFromDB
	elif [[ "$OPTARG" == '-a' ]]; then
		allFromDB
		exit
	elif [[ "$OPTARG" == '-i' ]]; then
		searchDBByID "$@"
		exit
	elif [[ "$OPTARG" == '-t' ]]; then
		searchDBByTag "$@"
		exit
	elif [[ "$OPTARG" == '-d' ]]; then
		searchDBByDescription "$@"
		exit
	fi

}
