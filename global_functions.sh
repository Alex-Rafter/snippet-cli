#!/usr/bin/env bash
#-------------------------------------------------------
#1 Global Variables : START
#-------------------------------------------------------
# shellcheck source=global_vars.sh
source 'C:/Users/rafte/snippet/global_vars.sh'


reFormatQuotedStrings() {
	echo "${1//qu\@/\"}"
}

SQLQuery() {

	local mode
	if [[ -n $1 ]]; then mode="$1"; fi

	local queryStatement="$2"

	local headers
	[[ $3 == "off" ]] && headers='.headers off' || headers='.headers on'

	sqlite3.exe "${dbConnection}" <<EOF
$headers
$mode
$queryStatement
EOF
}

FormatSnippetForDBInput() {
	local regex="^.*\.[a-z]{2,4}$"
	if [[ $1 =~ $regex ]]; then
		cat "$1" | sed -e '1d' -e 's/\"/qu@/g' | xargs -0
	else
		echo "$1" | sed 's/\"/qu@/g' | xargs -0
	fi
}

# Search by ID : START
searchDBByID() {
	local IdArgs
	IdArgs=$(echo "${@:2}" | awk -F, '{for(i=1; i<=NF; i++) printf $i ","}' | sed 's/,$//')
	local codeResult
	codeResult=$(SQLQuery '.mode json' "SELECT id,description,code FROM scripts WHERE ID IN (${IdArgs})" 'off')
	local jqEditedCodeResult
	jqEditedCodeResult=$(echo "$codeResult" | jq ' .[] | .ID, .description, .code' | sed -e 's/\\n/\n/g' -e 's/^\([0-9]\)/\n\n\1/g')
	reFormatQuotedStrings "$jqEditedCodeResult"
}


# Search by ID : END

searchDBByChosenId() {
	local chosenID="$1"
	local IDsToPass
	IDsToPass=$(echo "$2" | awk 'BEGIN { FS="|"}; {if (NR>3) print $2}' | tr -d '\n' | sed -e 's/\s\s/,/g' -e 's/\s//g')
	[[ $chosenID == "-a" ]] && chosenID="$IDsToPass"
	searchDBByID '-i' "$chosenID"
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

checkIfNowRenderSnippet() {
	local summaryDetails="$1"

	echo 'code? id, -a, or n'
	local answer
	read -r answer

	if [[ $answer == "n" ]]; then
		exit
	else
		searchDBByChosenId "$answer" "$summaryDetails"
	fi
}
