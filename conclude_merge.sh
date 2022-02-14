#!/bin/bash

echo -e "Enter the remote name (blank for origin):"
read remote

if [ -z $remote ] ; then
  remote='origin'
fi

# Look through all the local git branches.
declare -a all_branches
IFS=$'\n' read -r -d '' -a all_branches < <( git branch && printf '\0' )

# Scan for z.y.x-security branches.
branch_re="^[ ]*(\* )?([0-9]+)\.([0-9]+)(\.([0-9]+))?(\-security)[ ]*$"

# Create a list of matching security tags and corresponding branches.
i=0
declare -a major
declare -a minor
declare -a patch
declare -a base
declare -a releases
declare -a branches
declare -a devbranches
declare -a next
for branch in "${all_branches[@]}" ; do
    if [[ $branch =~ $branch_re ]] ; then
	i=$((i + 1))
	major[$i]="${BASH_REMATCH[2]}"
	minor[$i]="${BASH_REMATCH[3]}"
	patch[$i]="${BASH_REMATCH[5]}"
	base[$i]="${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
	releases[$i]="${base[$i]}.${BASH_REMATCH[5]}"
	branches[$i]="${base[$i]}.x"
	devbranches[$i]="${branches[$i]}-dev"
	next[$i]="${base[$i]}.$(( ${patch[$i]} + 1 ))"
    fi
done

for i in "${!releases[@]}"; do
    release="${releases[$i]}"
    git checkout "${branches[$i]}"
    rm -rf vendor
    composer install --no-progress --no-suggest -n -q
    COMPOSER_ROOT_VERSION="${devbranches[$i]}" composer update drupal/core*
    git commit --amend -am "Merge $release, resolve merge conflicts, and update lockfile and dev versions." --no-verify
    git branch -D "$release"-security
done

branch_list=$(IFS=' ' ; echo ${branches[*]})
tag_list=$(IFS=' ' ; echo ${releases[*]})

echo -e "\n\n ==== Check each branch, tag, and commit carefully before pushing! ====\n"
echo -e "To push, use:\n\n"
echo -e "git push $remote $tag_list"
echo -e "\nThen, create the release nodes to begin packaging."
echo -e "Once the release nodes have tarballs, then push the full branch data:"
echo -e "\ngit push $remote $branch_list"
echo -e "\n"
