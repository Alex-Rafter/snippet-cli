Snippet CLI
Problem
Managing a library of snippets and one-liners using a plain text file is not ideal. And while there are useful way to access and filter history using Bash's shortcuts and / or piping output to other programmes like grep, there is a still a lack of convenience to features like tagging, grouping, updating, entries; and listing related items, when compared to using a dedicated tool.

Goals
Build a clipboard manager / snippet tool that can be used directly from the command line.
Use a solution that allows for tagging and listing multiple entries, based on different aspects of the snippet or its description.
Use this as a vehicle to delve deeper into Bash scripting.

Intro
Snippet Cli provides  a convenient way to manage a library of snippets and one-liners without needing to leave the command line. It provides useful tools like tagging, listing multiple stored items, and editing library items all from the terminal. No need to rely on a plain text file, or to use a separate GUI app, and no need to trawl through your Bash history. 

Features
SQLite backed terminal clipboard manager written in Bash
Snippet-CLI uses tagging to easily group, and retrieve snippets by category such as programming language, or function
Perform CRUD operations on your snippet library quickly from your terminal
Invoke help for all operations from the command line with -h option

How to Use Snippet CLI
Creating a snippet
push: 

snip 'red body copy' 'css' '.red {color: red;}'
push file: 

snip -f 'update values in db' 'awk,parasol' example.sh
push via read in: 

snip -1 'update values in db' 'awk,parasol'
Reading a snippet
pull by tag: 

snip -o -t 'css'
pull by description: 

snip -o -d 'not live'
pull all: 

snip -o -a
Updating a snippet
update tag: 

snip -u '64' 'tags' 'css'
update description: 

snip -u '27' 'description' 'function call based on window width'
Deleting a snippet
delete by id: 

snip -d '74'
portfolio
bash


