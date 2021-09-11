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
			local codeToAdd
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
		exit
	elif [[ "$OPTARG" == '-1' ]]; then
		oneLinerInDB "$@"
		exit
	elif [[ "$OPTARG" == '-f' ]]; then
		fileInDB "$@"
		exit
	else
		oneLinerInDB '-1' "$@"
		exit
	fi

}
