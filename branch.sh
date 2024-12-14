#!/bin/bash

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

# Allow composer and yarn to run inside a container.
if [ "${DRUPAL_ENVIRONMENT}" == "ddev" ]
then
  CONTAINER_CMD='ddev exec'
fi

echo -e "Enter the new branch name (e.g. 10.2.x):"
read b
echo -e "Enter the original branch name (e.g. 10.1.x):"
read pb

n=${b/x/0}
cn=${b/.x/}
p=${pb/x/0}
cp=${pb/.x/}

git checkout "$pb"
git pull
rm -rf vendor

echo -e "Composer installing.\n"
${CONTAINER_CMD} composer install --no-progress --no-suggest -n -q
(cd core; rm -rf node_modules; ${CONTAINER_CMD} yarn install)
git checkout -b "$b"

# @todo Make it fail if the following don't make changes.
echo -e "\nUpdating version constant.\n"
portable_sed "s/VERSION = '[0-9\.]*-dev'/VERSION = '$n-dev'/1" core/lib/Drupal.php

echo -e "Updating templates.\n"
for file in `find composer/Template -name composer.json`
do
  portable_sed "s/\^$cp/\^$cn/g" $file
done

echo -e "\nUpdating metapackages.\n"
${CONTAINER_CMD} COMPOSER_ROOT_VERSION="$b-dev" composer update drupal/core* --no-progress --no-suggest -n -q
(cd core; rm -rf node_modules; ${CONTAINER_CMD} yarn install)
git commit -am "Drupal $b-dev"
