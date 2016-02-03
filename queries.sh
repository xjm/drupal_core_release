#!/bin/bash

# Name of the current D8 branch; update as needed.
BRANCH8="8.0.x"

# Get the script directory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Prompt for release numbers.
# No release numbers are needed for patch release window announcements.
# @todo Add input validation.
echo -e "Enter the D8 release number:"
read VERSION8

criticals=`cat fixed_criticals.txt`
rn=`cat rn_mention.txt`
string=`cat string_change.txt`

output="\n\n------- CRITICALS -------- $criticals \n\n------- RELEASE NOTES -------- $rn \n\n------- STRING CHANGE -------- $string";

# Replace the placeholders in the templates.
# @todo This is ugly.
output="${output//VERSION8/$VERSION8}"
output="${output//BRANCH8/$BRANCH8}"

# Echo with quotes to display newlines.
echo -e "$output"

# Copy it to the clipboard.
echo -e "$output" | pbcopy
