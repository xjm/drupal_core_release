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
#   The Drupal 7 version.
function update_changelog() {
  # This assumes the D7 changelog location, because D8 does not maintain a
  # list of releases in a changelog.
  date=$(date +"%Y-%m-%d")
  changelog="Drupal $1, $date\n-----------------------\n- Fixed security issues:\n"
  for advisory in "${advisories[@]}" ; do
    changelog="$changelog   - $advisory\n"
  done

  # @todo The merge later resolves this in a silly way, with this entry above
  # rather than below the release notes added after the last tag.
  echo -e "$changelog\n$(cat CHANGELOG.txt)" > CHANGELOG.txt
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

echo -e "How many advisories will be included in the release?"
read advisory_count

echo -e "First SA number in this release (e.g. '3' if SA-CORE-2019-003 is next):"
read first_advisory

year=$(date +%Y)
declare -a advisories
declare -a advisory_contributors

for i in $( eval echo {1..$advisory_count} )
do
  advisory_number=$(( $i + $first_advisory - 1 ))
  advisory_name=$(printf '%03d' $advisory_number)
  advisories[$i]="SA-CORE-$year-$advisory_name"
done

for sa in "${!advisories[@]}"
do
  # @todo soet it so the oldest tag/branch is first.
  declare -a base
  declare -a major
  declare -a branches
  declare -a previous
  declare -a next

  echo -e "\n\n==== ${advisories[$sa]} ===="

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
    if [[ $i -eq 0 ]]; then
      echo -e "\nPath to the ${branches[$i]} patch for ${advisories[$sa]} (tab completion works but not '~'):"
      read -e patch

      # This will be empty on the first pass because it is initialized above.
      # Thereafter it will be whatever was entered for the last branch (based
      # on input order, not version order).
      if [ -z $patch ] ; then
        echo -e "\nYou must specify at least one patch name:"
        read -e patch
      fi
    else
      echo -e "\nPath to the ${branches[$i]} patch for ${advisories[$sa]} (blank to use the last patch):"
      read -e patch
    fi

    if [[ -s "$patch" ]] ; then
      # Use indirect expansion, because bash 3 doesn't support associative
      # arrays.
      declare patches_${sa}_${i}="$patch"
    else
      if [[ -z "$patch" ]] ; then
        last_index=$(( $i - 1 ))
        last_patch=patches_${sa}_${last_index}
        declare patches_${sa}_${i}=${!last_patch}
      else
        echo -e "\nNo valid filename was supplied."
        exit 1
      fi
    fi
  done

  echo -e "\nEnter the list of contributors for ${advisories[$sa]}, separated by commas (blank for none):"
  read -e contributors
  advisory_contributors[$sa]=$contributors
done

# Loop over version list.
for i in "${!versions[@]}"; do
  version="${versions[$i]}"
  p="${previous[$i]}"
  n="${next[$i]}"
  branch="${branches[$i]}"
  includes_file "${major[$i]}" || ! $? -eq 0

  git checkout -b "$version"-security "$p"
  if [ ! $? -eq 0 ] ; then
    echo -e "Error: Could not create a working branch."
    exit 1
  fi

  for sa in "${!advisories[@]}"; do
    varname=patches_${sa}_${i}
    f=${!varname}
    git apply --index "$f"

    if [ ! $? -eq 0 ] ; then
      echo -e "Error: Could not apply the specified patch $f."
      exit 1
    fi

    # Prepare the commit message
    commit_message="${advisories[$sa]}"
    if [ ! -z "${advisory_contributors[$sa]}" ] ; then
      commit_message="$commit_message by ${advisory_contributors[$sa]}"
    fi

    git commit -am "$commit_message" --no-verify
  done

  # Update the version constant.
  update_constant "$version" "$p" "${major[$i]}"

  # Only D7 uses a changelog now.
  if [[ "${major[$i]}" = 7 ]] ; then
    update_changelog "$version"
    git add CHANGELOG.txt
  fi

  git commit -am "Drupal $version" --no-verify
  git tag -a "$version" -m "Drupal $version"

  # Merge the changes back into the main branch.
  git checkout "$branch"
  # We expect a merge conflict here.
  git merge --no-ff "$version" 1> /dev/null

  # Fix it by checking out the HEAD version and updating that.
  git checkout HEAD -- "$includes_file"
  git commit -m "Merged $version." --no-verify
  update_constant "$n-dev" "$version-dev" "${major[$i]}"
  git add "$includes_file"
  git commit -am "Back to dev." --no-verify

  git branch -D "$version"-security
done

branch_list=$(IFS=' ' ; echo ${branches[*]})
tag_list=$(IFS=' ' ; echo ${versions[*]})

echo -e "To push use:\n"
echo -e "git push $remote $branch_list && sleep 10 && git push $remote $tag_list"
echo -e "\n"
