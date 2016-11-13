#!/bin/bash

echo -e "Enter the D8 release number (e.g. 8.0.6 or 8.1.0-beta2):"
read v

re="^([0-9]*)\.([0-9]*)\.([0-9]*)$"

if [[ $v =~ $re ]] ; then
  base="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  calc_n="$base.$(( ${BASH_REMATCH[3]} + 1 ))"
  calc_p="$base.$(( ${BASH_REMATCH[3]} - 1 ))"
  if [ ${BASH_REMATCH[3]} = 0 ] ; then
    echo -e "Enter the previous D8 release (e.g. 8.1.0-rc2):"
    read p
  else
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
  fi
else
  echo -e "Enter the previous D8 release (e.g. 8.0.5 or 8.1.0-beta1):"
  read p
  echo -e "Enter the next stable release (e.g. 8.0.7 or 8.1.0):"
  read n
fi

grep -q "[0-9\.]*-dev" core/lib/Drupal.php
if [ ! $? -eq 0 ] ; then
  echo -e "Cannot match version constant. The release must be tagged manually."
  exit 1
fi

sed -i '' -e "s/VERSION = '[0-9\.]*-dev'/VERSION = '$v'/1" core/lib/Drupal.php
git commit -am "Drupal $v"
git tag -a "$v" -m "Drupal $v"

sed -i '' -e "s/VERSION = '$v'/VERSION = '$n-dev'/1" core/lib/Drupal.php
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
