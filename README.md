# drupal_core_release
Set of scripts for preparing a Drupal core release.

Usage
=====

Release tagging script: `tag.sh`
----------------------------------

See https://www.drupal.org/core/maintainers/create-core-release for complete
instructions on creating core releases. Use at your own risk!

Execute this script from your local git repository, either by adding it to your
path or by using the full path to the script.

1. Check out the correct branch and ensure you have the latest changes:
   `git checkout 8.1.x; git pull`
2. Run the script:
   `/path/to/core_release/tag.sh`
3. Your drush rn output will be copied to the clipboard if you have pbcopy
   (Mac), or output directly otherwise. Add it to your release notes.
4. Make sure the script did the right things:
   `git show`
   `git log`
5. Push your tags and commits manually:
   `git push --tags origin HEAD`

Post generation script: `posts.sh`
----------------------------------

With each command, markup for the post is printed to `stdout` and copied to the clipboard with `pbcopy`.

`-g` Generate g.d.o/core announcement.

`-r` Generate release notes.

`-f` Generate frontpage post.

`-s` Security window instead of a patch window.

`-m` Minor release, beta, or RC instead of a patch window.

`-d` Override dates for a release window announcement.

### Release window announcements for g.d.o/core

Post these announcements a few days in advance of the release window.

#### `./posts.sh -g`

Generate a post for http://groups.drupal.org/core about an upcoming patch release window. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).

The normal release window dates are used for the next upcoming patch release window. See: https://www.drupal.org/core/release-cycle-overview#dates

#### `./posts.sh -g -d`

Override one or more release window dates for the upcoming post (this patch release window, the following security release window, or the following patch release window).

#### `./posts.sh -g -s`

Generate a g.d.o/core post for an upcoming security release window instead of a patch release window.

#### `./posts.sh -g -s -d`

Generate a g.d.o/core post for an upcoming security release window instead of a patch release window, overriding dates.

### Release notes (Drupal 8 only)

The release notes automatically incorporate lists of issues in `rn_issues.txt` if it is available. To generate this with the [Core issue metrics sandbox](https://www.drupal.org/sandbox/xjm/core_metrics) sandbox:

1. Update `src/triage/QueryBuilder.php` in the metrics project as needed.
2. Execute the query set on staging: 
   `bash build_run_queries.sh core_release`
3. Run the PHP script provided in the core metrics project to build the release notes and place it within the root of this project: 
   `php /path/to/core_metrics/core_release/core_release.php > ./rn_issues.txt`

#### `./posts.sh -r`

Generate a template for the release notes for the patch release (Drupal 8 only). You will be prompted to enter the release number for Drupal 8.

#### `./posts.sh -r -s`

Generate a template for the release notes for a security release. The template is the same for all versions.

#### `./posts.sh -r -m`

Generate a template for the release notes of a minor release, beta, or release candidate (Drupal 8 only). You will be prompted to enter the release number for Drupal 8. For betas and RCs, enter the minor version number only (e.g. '8.1.0' for 8.1.0-beta1).

### Release announcements for the Drupal.org frontpage

Post these announcements after the releases are created.

#### `./posts.sh -f`

Generate a frontpage announcement for https://www.drupal.org about the patch release. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).

#### `./posts.sh -f -s`

Generate a frontpage announcement for https://www.drupal.org about the security release. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).

Release note query generation script: `generate_queries.sh`
------------------------------------------------

This script generates SQL queries against the Drupal.org database to fetch lists of issues for the release notes. You will be prompted to enter the D8 version number. The generated queries are printed to `stdout` and copied to the clipboard.

You can also use the [Core issue metrics sandbox](https://www.drupal.org/sandbox/xjm/core_metrics) to generate these queries and fetch their data (or ask xjm).

