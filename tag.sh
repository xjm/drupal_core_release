#!/bin/bash

echo -e "Enter the D8 release number (e.g. 8.0.6 or 8.1.0-beta2):"
read v
echo -e "Enter the previous D8 release (e.g. 8.0.5 or 8.1.0-beta1):"
read p
echo -e "Enter the next stable release (e.g. 8.0.7 or 8.1.0):"
read n

sed -i '' -e "s/[0-9\.]*-dev/$v/1" core/lib/Drupal.php
git commit -am "Drupal $v"
git tag -a "$v" -m "Drupal $v"
git checkout HEAD^ -- core/lib/Drupal.php
sed -i '' -e "s/[0-9\.]*-dev/$n-dev/1" core/lib/Drupal.php
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
