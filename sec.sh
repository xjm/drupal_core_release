#!/bin/bash

# @todo Calculate this from the release number.
branch="8.2.x"

echo -e "Enter the number for the SA (e.g. 2016-003):"
read sa
echo -e "Enter the D8 security release number (e.g. 8.1.7):"
read v
echo -e "Enter the path to the patch for the SA:"
read f
echo -e "Enter the list of contributors, separated by commas:"
read contributors

# @todo Calculate these from the release number.
echo -e "Enter the previous D8 release (e.g. 8.1.6):"
read p
echo -e "Enter the next stable release (e.g. 8.1.8):"
read n

# Commit the fix for the SA.
git checkout -b "$v"-security "$p"
git apply --index "$f"
commit_message="SA-CORE-$sa by $contributors"
git commit -am "$commit_message"

# Update the changelog and version constant.
grep -q "VERSION = '$p'" core/lib/Drupal.php
if [ ! $? -eq 0 ] ; then
  echo -e "Cannot match version constant. The release must be tagged manually."
  exit 1
fi
sed -i '' -e "s/VERSION = '$p'/VERSION = '$v'/1" core/lib/Drupal.php

date=$(date +"%Y-%m-%d")
changelog="Drupal $v, $date\n------------------------\n- Fixed security issues. SA-CORE-$sa.\n"
echo -e "$changelog\n$(cat core/CHANGELOG.txt)" > core/CHANGELOG.txt

git commit -am "Drupal $v"
git tag -a "$v" -m "Drupal $v"

# Merge the changes back into the main branch.
git checkout "$branch"
git merge --no-ff "$v"

git checkout HEAD^ -- core/lib/Drupal.php
sed -i '' -e "s/VERSION = '[0-9\.]*-dev'/VERSION = '$n-dev'/1" core/lib/Drupal.php
git add core/lib/Drupal.php
git commit -am "Back to dev."

git branch -D "$v"-security

echo -e "To push use:\n"
echo -e "git push && sleep 10 && git push origin $v"
echo -e "\n"
