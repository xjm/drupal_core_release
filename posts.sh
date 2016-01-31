#!/bin/sh

# Date of the next scheduled minor; update as needed.
MINOR="Wednesday, April 20"

# Format a Y-m-d date as (e.g.) 'Wednesday, February 3' in a Mac-friendly way.
function word_date() {
    echo "$(date -jf "%Y-%m-%d" "$1" +"%A, %B %d")"
}

# Get the current directory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Fetch CLI arguments.
while [ $# -gt 0 ]; do
    case "$1" in
        -g)
            g=TRUE
            ;;
        -f)
            f=TRUE
            ;;
        -r)
            r=TRUE
            ;;
        -d)
            d=TRUE
            ;;
        -s)
            s=TRUE
            ;;
        *)
            echo -e "Invalid option: $1.\nUsage: -g Generate g.d.o/core announcement.\n-r Generate release notes.\n-f Generate frontpage post.\n-d Override dates.\n-s Security window instead of a patch window.\nSee the README.md for details." >&2
            exit 1
    esac
    shift
done

# Require exactly one post type.
if [[ (! $g && ! $f && ! $r) || ($g && $f) || ($g && $r) || ($r && $f) ]] ; then
    echo -e "Specify one and only one of the following: -g -r -f\nSee the README.md for details."
    exit
fi

# Dates are only used in g.d.o/core announcements in advance of the window.
if [[ $d && ($f || $r) ]] ; then
    echo -e "The -d option is only valid with -g.\nSee the README.md for details."
    exit
fi

# -r and -f are not supported yet.
# @todo Remove this once the options are supported.
if [[ $r || $f ]] ; then
    echo -e "-r and -f aren't actually supported yet; sorry!"
    exit
fi

# Prompt for release numbers.
# No release numbers are needed for patch release window announcements.
# @todo Add input validation.
if [[ $f || $r ! $s ]] ; then
    echo -e "Enter the D8 release number:"
    read VERSION8
    echo -e "Enter the D7 release number (blank for none):"
    read VERSION7
fi

# Let the user override this patch release date. (N/A for security windows.)
if [[ $d && ! $s ]] ; then
    echo -e "Enter the release window as yyyy-mm-dd\n(blank for the upcoming first Wednesday of the month):"
    read date_ymd
fi

# Calculate the next upcoming patch release window if one was not provided.
# Give up and use PHP to use strtotime, because the Mac date command sucks.
if [ -z "$date_ymd" ] ; then
    if [ $s ] ; then
        date_ymd=$(date +"%Y-%m-%d")
    else
        date_ymd="$(php $DIR/window_dates.php 1)"
    fi
fi

# Format the upcoming patch release date and its year.
DATE="$(word_date $date_ymd)"
YEAR=$(date -jf "%Y-%m-%d" "$date_ymd" +"%Y")

# Let the user override the following security and patch release window dates.
if [ $d ] ; then
    echo -e "Enter the upcoming security release window as yyyy-mm-dd\n(blank for the next third Wednesday after $DATE):"
    read sec_ymd
    echo -e "Enter the following patch release window as yyyy-mm-dd\n(blank for the next first Wednesday after $DATE):"
    read next_patch_ymd
fi

# Calculate the following security and patch windows if none were provided.
if [ -z "$next_patch_ymd" ] ; then
  next_patch_ymd="$(php $DIR/window_dates.php 1 $date_ymd)"
fi
if [ -z "$sec_ymd" ] ; then
  sec_ymd="$(php $DIR/window_dates.php 3 $date_ymd)"
fi

# Format those windows for display.
NEXT_PATCH="$(word_date $next_patch_ymd)"
NEXT_SECURITY="$(word_date $sec_ymd)"

# Import the correct post template based on the user input.
if [ $s ] ; then
    text=`cat sec_gdo.txt`
elif [ ! -z "$VERSION7" ] ; then
    text=`cat patch_gdo_d8d7.txt`
else
    text=`cat patch_gdo_d8.txt`
fi

# Replace the placeholders in the templates.
# @todo This is ugly.
output="${text//VERSION8/$VERSION8}"
output="${output//DATE/$DATE}"
output="${output//YEAR/$YEAR}"
output="${output//MINOR/$MINOR}"
output="${output//NEXT_PATCH/$NEXT_PATCH}"
output="${output//NEXT_SECURITY/$NEXT_SECURITY}"

# If a Drupal 7 version is included, replace that placeholder too.
if [ ! -z "$VERSION7" ] ; then
    output="${output/VERSION7/$VERSION7}"
fi

# Echo with quotes to display newlines.
echo "$output"

# Copy it to the clipboard.
echo "$output" | pbcopy
