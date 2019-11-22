#!/bin/bash

echo -e "Enter the D8 release number (e.g. 8.0.6 or 8.1.0-beta2):"
read v

re="^([0-9]*)\.([0-9]*)\.([0-9]*)$"

if [[ $v =~ $re ]] ; then
  base="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  calc_n="$base.$(( ${BASH_REMATCH[3]} + 1 ))"
  calc_p="$base.$(( ${BASH_REMATCH[3]} - 1 ))"
  calc_b="$base.x"
  echo -e "Enter the previous D8 release (blank for $calc_p):"
  read p
  if [ -z "$p" ] ; then
    p=$calc_p
  fi
  echo -e "Enter the next stable release (blank for $calc_n):"
  read n
  if [ -z "$n" ] ; then
    n=$calc_n
  fi
  # Ideally we dont need this, but it's added safety.
  # Well, it also makes the script not work for pre-release milestones, so comment it
  # out for now.
  # echo -e "Enter the current branch (blank for $calc_b):"
  # read b
  #  if [ -z "$b" ] ; then
  #    b=$calc_b
  #  fi
else
  echo -e "Enter the previous D8 release (e.g. 8.0.5 or 8.1.0-beta1):"
  read p
  echo -e "Enter the next stable release (e.g. 8.0.7 or 8.1.0):"
  read n
  # Ideally we dont need this, but it's added safety.
  # echo -e "Enter the current branch (e.g. 8.8.x or 9.1.x):"
  # read b
fi

echo "Composer installing."
rm -rf vendor
composer install --no-progress --no-suggest -n -q

grep -q "[0-9\.]*-dev" core/lib/Drupal.php
if [ ! $? -eq 0 ] ; then
  echo -e "Cannot match version constant. The release must be tagged manually."
  exit 1
fi

sed -i '' -e "s/VERSION = '[0-9\.]*-dev'/VERSION = '$v'/1" core/lib/Drupal.php

# Update the version strings in the metapackages
echo "Updating metapackage versions to ${v} and tagging."

# COMPOSER_ROOT_VERSION causes an error when building metapackages for an RC.
# COMPOSER_ROOT_VERSION="${b}-dev" composer update --lock --no-progress --no-suggest -n -q
composer update --lock --no-progress --no-suggest -n -q
git commit -am "Drupal $v"
git tag -a "$v" -m "Drupal $v"

sed -i '' -e "s/VERSION = '$v'/VERSION = '$n-dev'/1" core/lib/Drupal.php
echo "Restoring metapackage versions back to ${b}-dev"

# COMPOSER_ROOT_VERSION causes an error when building metapackages for an RC.
# COMPOSER_ROOT_VERSION="${b}-dev" composer update --lock --no-progress --no-suggest -n -q
composer update --lock --no-progress --no-suggest -n -q
git commit -am "Back to dev."

if hash pbcopy 2>/dev/null; then
    drush rn "$p" `git rev-parse --abbrev-ref HEAD` | pbcopy
    echo -e "\n** Your releases notes have been copied to the clipboard. **\n"
else
    drush rn "$p" `git rev-parse --abbrev-ref HEAD`
fi
echo -e "To push use:\n"
echo -e "git push && sleep 10 && git push origin $v"
echo -e "\n"
