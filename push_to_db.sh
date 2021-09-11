#!/usr/bin/env bash
# This script is for pushing data to the database

mainPush() {

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

	#-------------------------------------------------------
	# Conditional Function Calls
	#-------------------------------------------------------

	if [[ -z $1 ]]; then
		echo "No arguments provided"
		help
	elif [[ "$OPTARG" == '-1' ]]; then
		oneLinerInDB "$@" exit
	elif [[ "$OPTARG" == '-f' ]]; then
		fileInDB "$@"
		exit
	else
		oneLinerInDB '-1' "$@"
	fi

}
