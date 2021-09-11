#!/usr/bin/env bash


help() {

local hiColour
hiColour=$(printf '\033[0;36m')
local noColour
noColour=$(printf '\033[0m')

	cat <<HEREDOC
*******************************
${hiColour}OPTIONS${noColour}
        -h: help
        -1: one-liner 
	-o -a: show all
	-o -t: search by tag
	-o -d: search by description
	-d: delete
	-u: update snippet

${hiColour}EXAMPLES
${noColour}
PUSH: snip 'red body copy' 'css' '.red {color: red;}'

PUSH FILE: snip -f 'update values in db' 'awk,parasol' example.sh

PUSH VIA READ IN: snip -1 'update values in db' 'awk,parasol'

PULL BY TAG: snip -o -t 'css'

PULL BY DESCRIPTION: snip -o -d 'not live'

PULL ALL: snip -o -a

DELETE BY ID: snip -d '74'

UPDATE TAG: snip -u '64' 'tags' 'css'

UPDATE DESCRIPTION: snip -u '27' 'description' 'Function call based on window width'
HEREDOC
}

# help

