#!/bin/bash

 if [[ -z $1 ]] ; then
   echo -e "Usage: ./sec.sh 8.5.1 8.4.6 7.58"
   echo -e "(List the releases that will be tagged.)"
   exit 1
 fi

# @param $1
#   Version string.
function validate_version() {

  # We only support D7 through D9 for now.
  # Kind of a Y2K bug for Drupal versions.
  re="^[ ]*([7-9])\.([1-9][0-9]*)(\.([1-9][0-9]*))?[ ]*$"

  message="\n$1 can't be tagged automatically. To use $1, tag the release manually."

  if [[ ! $1 =~ $re ]] ; then
    echo -e "$message"
    exit 1
  fi

  # D7 must only have major.patch.
  if [[ ${BASH_REMATCH[1]} = 7 ]] ; then
    if [[ ! -z ${BASH_REMATCH[4]} ]] ; then
      echo -e "$message"
      exit 1
    fi
  else
    # Later branches must have major.minor.patch.
    if [[ -z ${BASH_REMATCH[4]} ]] ; then
      echo -e "$message"
      exit 1
    fi
  fi
}

# @param $1
#   The major branch.
function includes_file() {

  includes_file=''

  if [[ $1 = 7 ]] ; then
    includes_file="includes/bootstrap.inc"
  else
    includes_file="core/lib/Drupal.php"
  fi
}

# @param $1
#   The version constant to use.
# @param $2
#   The old version constant.
# @param $3
#   The major version.
function update_constant() {
  # Update the version constant.

  includes_file "$3"

  find=''
  replace=''
  if [[ "$3" = 7 ]] ; then
    # @todo D7 also needs the CHANGELOG update.
    find="'VERSION', '$2'"
    replace="'VERSION', '$1'"

  else
    find="VERSION = '$2'"
    replace="VERSION = '$1'"
  fi

  grep -q "$find" "$includes_file"
  if [ ! $? -eq 0 ] ; then
    echo -e "Cannot match version constant $2. The release must be tagged manually."
    exit 1
  fi
  sed -i '' -e "s/$find/$replace/1" "$includes_file"
}

versions=( "$@" )

echo -e "Enter the remote name (blank for origin):"
read remote

if [ -z $remote ] ; then
  remote='origin'
fi

echo -e "\nEnter the number for the SA (e.g. 2018-002):"
read -e sa
echo -e "\nEnter the list of contributors, separated by commas (blank for none):"
read -e contributors

# @todo soet it so the oldest tag/branch is first.
declare -a base
declare -a major
declare -a branches
declare -a previous
declare -a next
declare -a patches

for i in "${!versions[@]}"; do
  v="${versions[$i]}"

  validate_version "$v" || ! $? -eq 0

  if [[ -z ${BASH_REMATCH[4]} ]] ; then
    major[$i]="${BASH_REMATCH[1]}"
    base[$i]="${BASH_REMATCH[1]}"
    previous[$i]="${base[$i]}.$(( ${BASH_REMATCH[2]} - 1 ))"
    next[$i]="${base[$i]}.$(( ${BASH_REMATCH[2]} + 1 ))"
  else
    major[$i]="${BASH_REMATCH[1]}"
    base[$i]="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
    previous[$i]="${base[$i]}.$(( ${BASH_REMATCH[4]} - 1 ))"
    next[$i]="${base[$i]}.$(( ${BASH_REMATCH[4]} + 1 ))"
  fi

  branches[$i]="${base[$i]}.x"

  patch=''
  if [ -z "$patches" ]; then
    echo -e "\nPath to the ${branches[$i]} patch (tab completion works but not '~'):"
    read -e patch

    # This will be empty on the first pass because it is initialized above.
    # Thereafter it will be whatever was entered for the last branch (based on
    # input order, not version order).
    if [ -z $patch ] ; then
      echo -e "\nYou must specify at least one patch name:"
      read -e patch
    fi
  else
    echo -e "\nPath to the ${branches[$i]} patch (blank to use the last patch):"
    read -e patch
  fi

  if [[ -s "$patch" ]] ; then
    patches[$i]=$patch
  else
    if [[ -z "$patch" ]] ; then
      patches[$i]="${patches[$i-1]}"
    else
      echo -e "\nNo valid filename was supplied."
      exit 1
    fi
  fi

done

# Prepare the commit message
commit_message="SA-CORE-$sa"
if [ ! -z "$contributors" ] ; then
  commit_message="$commit_message by $contributors"
fi

# Loop over version list.
for i in "${!versions[@]}"; do
  version="${versions[$i]}"
  p="${previous[$i]}"
  n="${next[$i]}"
  f="${patches[$i]}"
  branch="${branches[$i]}"
  includes_file "${major[$i]}" || ! $? -eq 0

  git checkout -b "$version"-security "$p"
  if [ ! $? -eq 0 ] ; then
    echo -e "Error: Could not create a working branch."
    exit 1
  fi

  git apply --index "$f"

  if [ ! $? -eq 0 ] ; then
    echo -e "Error: Could not apply the specified patch $f."
    exit 1
  fi

  git commit -am "$commit_message" --no-verify

  # Update the version constant.
  update_constant "$version" "$p" "${major[$i]}"

  git commit -am "Drupal $version" --no-verify
  git tag -a "$version" -m "Drupal $version"

  # Merge the changes back into the main branch.
  git checkout "$branch"
  # We expect a merge conflict here.
  git merge --no-ff "$version" 1> /dev/null

  # Fix it by checking out the HEAD version and updating that.
  # @todo This is also version-specific.
  git checkout HEAD -- "$includes_file"
  git commit -m "Merged $version."
  update_constant "$n-dev" "$version-dev" "${major[$i]}"
#  sed -i '' -e "s/VERSION = '[0-9\.]-dev'/VERSION = '$n-dev'/1" core/lib/Drupal.php
  git add "$includes_file"
  git commit -am "Back to dev."

  git branch -D "$version"-security
done

branch_list=$(IFS=' ' ; echo ${branches[*]})
tag_list=$(IFS=' ' ; echo ${versions[*]})

echo -e "To push use:\n"
echo -e "git push $remote $branch_list && sleep 10 && git push $remote $tag_list"
echo -e "\n"
