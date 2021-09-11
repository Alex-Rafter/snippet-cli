#!/usr/bin/env bash
# This script is for pulling data from the database

mainPull() {

	# Search by ID : START
	searchDBByID() {
		local IdArgs
		IdArgs=$(echo "${@:2}" | tr "," "\n")
		for indvID in $IdArgs; do
			IDToSearch="$indvID"
			logSummaryThenCode
		done
	}

	# Search by ID : END

	# Search by DESCRIPTION : START
	searchDBByDescription() {
		local colsToLog
		local modeToUse
		local descriptionToSearch
		local formattedDescriptionToSearch
		local result
		local formattedResult

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
		local tagsToSearch
		local fomattedTags
		local result
		local formattedResult


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
	elif [[ "$OPTARG" == '-t' ]]; then
		searchDBByTag "$@"
		exit
	elif [[ "$OPTARG" == '-d' ]]; then
		searchDBByDescription "$@"
		exit
	fi

}
