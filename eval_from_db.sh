#!/usr/bin/env bash
# This script is for evaluating data from the database

# *******************************
# HELP LOGIC
# *******************************
dbConnection='/c/Users/rafte/snippet/db/scripts_n_snips.db'

help() {
   cat <<HEREDOC

*******************************
EVALUATE WITH SNIPPET FROM DB
*******************************

options: 
    -h: help

EVALUATE WITH SNIPPET
ID, ['stdin' OR 'file.sh']

PASS STDIN
example: eval_from_db.sh '1' 'test:one:two:three'
OR
example: eval_from_db.sh '1' "$(paste)"

PASS FILE
example: eval_from_db.sh '1' example.sh

HEREDOC
}

seddy=''
evalFromDB() {
   IDToSearch="$1"
   result=$(
      sqlite3.exe "${dbConnection}" <<EOF
.mode list
SELECT code FROM scripts WHERE ID="${IDToSearch}"
EOF
   )
   seddy=$(echo "$result" | sed -e 's/qu\@/\"/g' -e 's/;//g')

   if [[ $2 =~ \.[a-z]{2,4}$ ]]; then
      eval "$seddy $2"
   else
      eval "echo $2 | $seddy"
   fi

}

while getopts ":h" option; do
   case $option in
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
   evalFromDB "$@"
fi
