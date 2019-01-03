#!/bin/bash

# Date of the next scheduled minor and current D8 branch; update as needed.
BRANCH8="8.6.x"
NEXTBRANCH="8.7.x"

# Get the script directory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the prepopulated list of issues, if any.
if [ -a $DIR/rn_issues.txt ] ; then
    AUTO_ISSUES="$(cat $DIR/rn_issues.txt)"
fi

# Fetch CLI arguments.
while [ $# -gt 0 ]; do
    case "$1" in
        -f)
            f=TRUE
            ;;
        -r)
            r=TRUE
            ;;
        -s)
            s=TRUE
            ;;
        -m)
            m=TRUE
            ;;
        *)
            echo -e "Invalid option: $1.\nUsage:\n-r Generate release notes.\n-f Generate frontpage post.\n-s Security window instead of a patch window.\n-m Minor release.\nSee the README.md for details." >&2
            exit 1
    esac
    shift
done

# Require exactly one post type.
if [[ (! $f && ! $r) || ($r && $f) ]] ; then
    echo -e "Specify one and only one of the following: -r -f\nSee the README.md for details."
    exit
fi

# Dates are only used in g.d.o/core announcements in advance of the window.
if [[ $m && ($f || $g) ]] ; then
    echo -e "The -m option is only valid with -r.\nSee the README.md for details."
    exit
fi

# Prompt for release numbers.
# No release numbers are needed for patch release window announcements.
# @todo Add input validation.
if [[ $f || $r || ! $s ]] ; then
    echo -e "Enter the D8 release number:"
    read VERSION8
    if [ ! $r ] ; then
        echo -e "Enter the D7 release number (blank for none):"
        read VERSION7
    else
      BLURB="$(cat $DIR/templates/patch_blurb.txt)"
      KNOWN_ISSUES="$(cat $DIR/templates/known_issues.txt)"

      if [ $m ] ; then
        # @todo We also need the minor version itself for pre-release
        # milestones in order to link the stuff correctly.
        # @todo Just parse this out of the version.
        echo -e "Enter 'alpha', 'beta', or 'rc' (blank for a full minor release):"
        read minor_release_type
        echo -e "Enter the tag of the last milestone (blank for none since the last branch)"
        read LAST_MILESTONE
        # @todo This isn't working.
        if [ -z "$LAST_MILESTONE" ] ; then
          LAST_MILESTONE=$BRANCH8
        elif [ ! $m ] ; then
          SEE_ALSO="$(cat $DIR/templates/see_also.txt)"
        fi
        if [ "$minor_release_type" = 'alpha' ] ; then
          BLURB="$(cat $DIR/templates/alpha_blurb.txt)"
        elif [ "$minor_release_type" = 'beta' ] ; then
          BLURB="$(cat $DIR/templates/beta_blurb.txt)"
        elif [ "$minor_release_type" = 'rc' ] ; then
          BLURB="$(cat $DIR/templates/rc_blurb.txt)"
        else
          BLURB="$(cat $DIR/templates/minor_blurb.txt)"
        fi
      fi

      FULL_NOTES="$(git log --right-only --cherry-pick $LAST_MILESTONE...$NEXTBRANCH --pretty='<li>%s</li>')"
      FULL_NOTES="$(echo $FULL_NOTES | sed -e 's/Issue #\([0-9]*\) /Issue <a href=\"https:\/\/www.drupal.org\/node\/\1\">#\1<\/a> /g')"
      FULL_NOTES="$(echo $FULL_NOTES | sed -e 's/<\/li>/<\/li>\'$'\n/g')"
    fi
fi

# Prompt for the SA number.
if [[ $s && ($f || $r) ]] ; then
    echo -e "Enter the number for the SA (e.g. 2016-001):"
    read SA_NUMBER
fi

# Import the correct post template based on the user input.
# Files are named according to a standard pattern.
if [ $s ] ; then
    prefix="sec"
else
    prefix="patch"
fi

if [ ! -z "$VERSION7" ] ; then
    suffix="d8d7"
else
    suffix="d8"
fi

if [ $r ] ; then
    if [ $s ] ; then
        text="$(cat $DIR/templates/sec_rn.txt)"
    elif [ $m ] ; then
        BRANCH8=$NEXTBRANCH
        text="$(cat $DIR/templates/minor_rn_d8.txt)"
        EXPERIMENTAL="$(cat $DIR/templates/experimental.txt)"
    else
        if [ ! -z "$AUTO_ISSUES" ] ; then
            text="$(cat $DIR/templates/patch_rn_\"${suffix}\"_auto_issues.txt)"
        else
            text="$(cat $DIR/templates/patch_rn_\"${suffix}\".txt)"
        fi
    fi
elif [ $f ] ; then
    text="$(cat $DIR/templates/"${prefix}"_frontpage_\"${suffix}\".txt)"
fi

# Replace the placeholders in the templates.
# @todo This is ugly.
output="${text//AUTO_ISSUES/$AUTO_ISSUES}"
output="${text//KNOWN_ISSUES/$KNOWN_ISSUES}"
output="${output//BLURB/$BLURB}"
output="${output//SEE_ALSO/$SEE_ALSO}"
output="${output//LAST_MILESTONE/$LAST_MILESTONE}"
output="${output//VERSION8/$VERSION8}"
output="${output//BRANCH8/$BRANCH8}"
output="${output//NEXTBRANCH/$NEXTBRANCH}"
output="${output//DATE/$DATE}"
output="${output//YEAR/$YEAR}"
output="${output//NEXT_PATCH/$NEXT_PATCH}"
output="${output//NEXT_SECURITY/$NEXT_SECURITY}"
output="${output//SA_NUMBER/$SA_NUMBER}"
output="${output//FULL_NOTES/$FULL_NOTES}"

# If a Drupal 7 version is included, replace that placeholder too.
if [ ! -z "$VERSION7" ] ; then
    output="${output//VERSION7/$VERSION7}"
fi

# Echo with quotes to display newlines.
echo "$output"

# Copy it to the clipboard.
echo "$output" | pbcopy
