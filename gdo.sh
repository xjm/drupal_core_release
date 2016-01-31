#!/bin/sh
# @todo Add input validation.

function word_date() {
    # Mac dates, ugh.
    echo "$(date -jf "%Y-%m-%d" "$1" +"%A, %B %d")"
}

# Get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [ $# -gt 0 ]; do
    case "$1" in
        -d)
            d=TRUE
            ;;
        -s)
            s=TRUE
            ;;
        *)
            echo -e "Invalid option: $1.\nUsage: -d to override dates. -s for security window instead of a patch window. See the README.md for details." >&2
            exit 1
    esac
    shift
done

# Patch release
if [ ! $s ] ; then
    echo -e "Enter the D8 release number:"
    read VERSION8
    echo -e "Enter the D7 release number (blank for none):"
    read VERSION7
fi

if [[ $d && ! $s ]] ; then
    echo -e "Enter the release window as yyyy-mm-dd\n(blank for the upcoming first Wednesday of the month):"
    read date_ymd
fi

# Calculate the next upcoming patch release window.
# Give up and use PHP to use strtotime, because the Mac date command sucks.
if [ -z "$date_ymd" ] ; then
    if [ $s ] ; then
        date_ymd=$(date +"%Y-%m-%d")
    else
        date_ymd="$(php $DIR/window_dates.php 1)"
    fi
fi

DATE="$(word_date $date_ymd)"
YEAR=$(date -jf "%Y-%m-%d" "$date_ymd" +"%Y")

if [ $d ] ; then
    echo -e "Enter the upcoming security release window as yyyy-mm-dd\n(blank for the next third Wednesday after $DATE):"
    read sec_ymd
    echo -e "Enter the following patch release window as yyyy-mm-dd\n(blank for the next first Wednesday after $DATE):"
    read next_patch_ymd
fi

# Calculate the following securiy and patch windows after this one.
if [ -z "$next_patch_ymd" ] ; then
  next_patch_ymd="$(php $DIR/window_dates.php 1 $date_ymd)"
fi
if [ -z "$sec_ymd" ] ; then
  sec_ymd="$(php $DIR/window_dates.php 3 $date_ymd)"
fi

NEXT_PATCH="$(word_date $next_patch_ymd)"
NEXT_SECURITY="$(word_date $sec_ymd)"

if [ $s ] ; then
    text=`cat sec_gdo.txt`
elif [ ! -z "$VERSION7" ] ; then
    text=`cat patch_gdo_d8d7.txt`
else
    text=`cat patch_gdo_d8.txt`
fi

output="${text//VERSION8/$VERSION8}"
output="${output//DATE/$DATE}"
output="${output//YEAR/$YEAR}"
output="${output//NEXT_PATCH/$NEXT_PATCH}"
output="${output//NEXT_SECURITY/$NEXT_SECURITY}"

if [ ! -z "$VERSION7" ] ; then
    output="${output/VERSION7/$VERSION7}"
fi

# Echo with quotes to display newlines.
echo "$output"
# Copy it to the clipboard.
echo "$output" | pbcopy
