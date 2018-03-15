#!/bin/bash

 if [[ -z $1 ]] ; then
   echo -e "Usage: ./sec.sh 8.2.8 8.3.1"
   echo -e "(List the releases that will be tagged.)"
   exit 1
 fi

versions=( "$@" )

echo -e "Enter the remote name (blank for origin):"
read remote

if [ -z $remote ] ; then
  remote='origin'
fi

echo -e "\nEnter the number for the SA (e.g. 2017-002):"
read -e sa
echo -e "\nEnter the list of contributors, separated by commas (blank for none):"
read -e contributors

re="^[ ]*([0-9]*)\.([0-9]*)\.([0-9]*)[ ]*$"

# @todo soet it so the oldest tag/branch is first.
declare -a branches
declare -a previous
declare -a next
declare -a patches

for i in "${!versions[@]}"; do
  v="${versions[$i]}"

  if [[ ! $v =~ $re ]] ; then
    echo -e "\nInvalid version number $v. To use $v, tag the release manually."
    exit 1
  fi

  base=''
  patch=''
  last_patch=''
  branch=''
  contents=''

  base="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  previous[$i]="$base.$(( ${BASH_REMATCH[3]} - 1 ))"
  next[$i]="$base.$(( ${BASH_REMATCH[3]} + 1 ))"
  branch="$base.x"
  branches[$i]=$branch

  if [ -z "$patches" ]; then
    echo -e "\nPath to the $branch patch (tab completion works but not '~'):"
    read -e patch
    if [ -z $patch ] ; then
      echo -e "\nYou must specify at least one patch name:"
      read -e patch
    fi
  else
    echo -e "\nPath to the $branch patch (blank to cherry-pick the last patch):"
    read -e patch
  fi

  if contents="$(cat $patch)" ; then
    patches[$i]=$contents
  else
    if [ -z patch ] ; then
      patches[$i]=$patches[$i-1]
    else
      exit 1
    fi
  fi

done

# Commit the fix for the SA.
commit_message="SA-CORE-$sa"
if [ ! -z "$contributors" ] ; then
  commit_message="$commit_message by $contributors"
fi

# Loop over version list.
for i in "${!versions[@]}"; do
  v="${versions[$i]}"
  p="${previous[$i]}"
  n="${next[$i]}"
  f="${patches[$i]}"
  branch="${branches[$i]}"
  git checkout -b "$v"-security "$p"
  if [ ! $? -eq 0 ] ; then
    echo -e "Error: Could not create a working branch."
    exit 1
  fi

  echo "$f" | git apply --index -

  if [ ! $? -eq 0 ] ; then
    echo -e "Error: Could not apply the specified patch."
    exit 1
  fi
  git commit -am "$commit_message" --no-verify

  # Update the changelog and version constant.
  grep -q "VERSION = '$p'" core/lib/Drupal.php
  if [ ! $? -eq 0 ] ; then
    echo -e "Cannot match version constant. The release must be tagged manually."
    exit 1
  fi
  sed -i '' -e "s/VERSION = '$p'/VERSION = '$v'/1" core/lib/Drupal.php

  git commit -am "Drupal $v" --no-verify
  git tag -a "$v" -m "Drupal $v"

  # Merge the changes back into the main branch.
  git checkout "$branch"
  # We expect a merge conflict here.
  git merge --no-ff "$v" 1> /dev/null

  # Fix it by checking out the HEAD version and updating that.
  git checkout HEAD -- core/lib/Drupal.php
  git commit -m "Merged $v."
  sed -i '' -e "s/VERSION = '[0-9\.]*-dev'/VERSION = '$n-dev'/1" core/lib/Drupal.php
  git add core/lib/Drupal.php
  git commit -am "Back to dev."

  git branch -D "$v"-security
done

branch_list=$(IFS=' ' ; echo ${branches[*]})
tag_list=$(IFS=' ' ; echo ${versions[*]})

echo -e "To push use:\n"
echo -e "git push $remote $branch_list && sleep 10 && git push origin $tag_list"
echo -e "\n"
