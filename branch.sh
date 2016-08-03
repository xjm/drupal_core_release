#!/bin/bash

echo -e "Enter the new branch name (e.g. 8.3.x):"
read b
echo -e "Enter the original branch name (e.g. 8.2.x):"
read pb

n=${b/x/0}
cn=${b/.x/}
p=${pb/x/0}
cp=${pb/.x/}

git checkout "$pb"
git pull
git checkout -b "$b"
sed -i '' -e "s/VERSION = '[0-9\.]*-dev'/VERSION = '$n-dev'/1" core/lib/Drupal.php
sed -i '' -e "s/\"drupal\/core\": \"~$cp\"/\"drupal\/core\": \"~$cn\"/1" composer.json
composer self-update
composer update --lock
git commit -am "Drupal $b-dev"


