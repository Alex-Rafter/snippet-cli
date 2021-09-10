#!/usr/bin/env bash


#-------------------------------------------------------
# 2 Global Funcs : START
#-------------------------------------------------------
reFormatQuotedStrings() {
	echo "${1/qu\@/\"/}"
}

SQLQuery() {
	local mode
	local queryStatement="$2"
	local headers

	if [[ -n $1 ]]; then mode="$1"; fi
	[[ $3 == "off" ]] && headers='.headers off' || headers='.headers on'

	sqlite3.exe "${dbConnection}" <<EOF
$headers
$mode
$queryStatement
EOF
}

FormatSnippetForDBInput() {
	regex="^.*\.[a-z]{2,4}$"
	if [[ $1 =~ $regex ]]; then
		cat "$1" | sed -e '1d' -e 's/\"/qu@/g' | xargs -0
	else
		echo "$1" | sed 's/\"/qu@/g' | xargs -0
	fi
}

searchDBByChosenId() {
	chosenID="$1"
	IDsToPass=$(echo "$2" | awk 'BEGIN { FS="|"}; {if (NR>3) print $2}' | tr -d '\n' | sed -e 's/\s\s/,/g' -e 's/\s//g')
	[[ $chosenID == "-a" ]] && chosenID="$IDsToPass"
	searchDBByID '-i' "$chosenID"
}

logSummaryThenCode() {
	summaryResult=$(SQLQuery '.mode list' "SELECT id,description,tags FROM scripts WHERE ID=\"${IDToSearch}\"" 'off')
	codeResult=$(SQLQuery '.mode quote' "SELECT code FROM scripts WHERE ID=\"${IDToSearch}\"" 'off')
	printf "\n${noColour}%s\n\n${hiColour}%s\n" "$summaryResult" "$(reFormatQuotedStrings "$codeResult")"
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
	read -r answer

	if [[ $answer == "n" ]]; then
		exit
	else
		searchDBByChosenId "$answer" "$summaryDetails"
	fi
}


#-------------------------------------------------------
# 2 Global Funcs : END
#-------------------------------------------------------


