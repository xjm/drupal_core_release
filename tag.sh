#!/bin/bash

#
# Build the change log in html.
#
# @param $1
#   Release version.
# @param $2
#   Next stable release.
# @param $3
#   Filename for the changelog.
#
function build_changelog() {
# The builtin command 'mapfile' is available since Bash 4.
if hash mapfile 2>/dev/null; then
  mapfile -t log < <(git log --format='<li><a href=%x22https://git.drupalcode.org/project/drupal/commit/%H%x22>%s</a></li>%n' "$1"^..."$2")
else
  OIFS="$IFS"
  IFS=$'\n' read -r -d '' -a log < <( git log --format='<li><a href=%x22https://git.drupalcode.org/project/drupal/commit/%H%x22>%s</a></li>%n' "$1"^..."$2" && printf '\0' )
  IFS=$OIFS
fi

# Output each log entry as an item in an unsorted list.
echo -e '<ul>\n\n' > "$3"
for i in "${log[@]}"
do
  # Do not interpret backslash escapes in the git log message.
  echo "$i" >> "$3"
  echo -e "\n" >> "$3"
done
echo -e '</ul>\n\n' >> "$3"
}

# @param $1
#   Replacement pattern
# @param $2
#   File path.
function portable_sed() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -e "$1" "$2"
  else
    sed -i -e "$1" "$2"
  fi
}

# @param $1
#   The Drupal version to set.
# @param $2
#   The major version.
# @param $3
#   The minor version.
function set_version() {
  if [[ $2 -ge 10 ]] || [[ $2 -eq 9 && $3 -gt 0 ]] ; then
    echo -e "\n\n Setting version with Composer for 9.1+ \n"
    php -r "include 'vendor/autoload.php'; \Drupal\Composer\Composer::setDrupalVersion('.', '$1');"
  else
    grep -q "[0-9\.]*-dev" core/lib/Drupal.php
    if [ ! $? -eq 0 ] ; then
	echo -e "Cannot match version constant. The release must be tagged manually."
	exit 1
    fi

    echo -e "\n\n Setting version with sed for 9.0 and earlier \n"
    portable_sed "s/VERSION = '[0-9\.]*-dev'/VERSION = '$1'/1" "core/lib/Drupal.php"

  fi
}

echo -e "Enter the release version (e.g. 9.3.6 or 9.4.0-beta2):"
read v

re="^([0-9]+)\.([0-9]+)\.([0-9]+)(-[A-Za-z0-9]+)?$"

if [[ $v =~ $re ]] ; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  suffix="${BASH_REMATCH[4]}"
  if [ -z "$suffix" ] ; then
    calc_n="$major.$minor.$(( $patch + 1 ))"
    calc_p="$major.$minor.$(( $patch - 1 ))"
  else
    calc_n="$major.$minor.$patch"
    calc_p="$major.$(( $minor - 1 )).0"
  fi
  echo -e "Enter the previous release version (blank for $calc_p):"
  read p
  if [ -z "$p" ] ; then
    p=$calc_p
  fi
  echo -e "Enter the next stable release (blank for $calc_n):"
  read n
  if [ -z "$n" ] ; then
    n=$calc_n
  fi
else
  echo -e "Unrecognized version. The release must be tagged manually."
  exit 1
fi

echo "Composer installing."
rm -rf vendor
composer install --no-progress --no-suggest -n -q

set_version "$v" "$major" "$minor"

# Update the version strings in the metapackages
echo "Updating metapackage versions to ${v} and tagging."

# Update the path repository versions in the lock file
COMPOSER_ROOT_VERSION="$v" composer update drupal/core*

git commit -am "Drupal $v" --no-verify
git tag -a "$v" -m "Drupal $v"

# Revert the composer.lock change in the last commit
git revert HEAD --no-commit

# Put the version back to dev
set_version "${n}-dev" "$major" "$minor"
echo "Restoring metapackage versions back to ${major}.${minor}.x-dev"

git commit -am "Back to dev." --no-verify

# Create the 'All changes since' changelog.
changelog=$(mktemp)
build_changelog "$v" "$p" "$changelog"
notes=$(cat "$changelog")
rm "$changelog"

if hash pbcopy 2>/dev/null; then
    echo "$notes" | pbcopy
    echo -e "\n** Your releases notes have been copied to the clipboard. **\n"
else
    echo "$notes"
fi
echo -e "To push use:\n"
echo -e "git push origin $v ${major}.${minor}.x"
echo -e "\n"
