# drupal_core_release
Set of scripts for preparing a Drupal core release.

- `tag.sh`: Tags a core release
- `sec.sh`: Creates a core security release
- `manual_merge.sh` and `conclude_merge.sh`: Create a security release that requires a manual merge (e.g., for dependency updates)
- `branch.sh`: Creates a new core branch for a new minor version

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

   You will be prompted to enter the release number, as well as the previous and
   next release numbers if it is not a normal patch release,
   
3. A list of the commits since the last release you entered  will be copied to
   the clipboard if you have pbcopy (Mac), or output directly otherwise. Add
   it to your release notes.

4. Make sure the script did the right things:

   `git show`
   
   `git log`

5. Push your tags and commits manually using the command the script displays. The
   command includes a `sleep` to avoid a race condition on packaging, so expect it
   to sit doing nothing for a bit.

Security release script: `sec.sh`
----------------------------------

See https://www.drupal.org/core/maintainers/create-core-security-release for
complete instructions on creating security releases. Only create security
releases in collaboration with the security team and do not share any
information (including whetherthere will be a release) outside the security
team. (See the
[security team disclosure policy](https://www.drupal.org/drupal-security-team/security-team-procedures/drupal-security-team-disclosure-policy-for-security)
for more information.)

Execute this script from your local git clone of Drupal core, either by
adding it to your system path or by using the full path to the script.

1. Check out the correct branch(es) and ensure you have the latest changes:

   `git checkout 8.1.x; git pull`
   
2. Run the script, with the tag(s) to create as arguments:

   `/path/to/core_release/manual_merge_sec.sh 8.6.4 8.5.9`

   You will be prompted to enter information about the SA and the path(s) to patches for each branch. You can tag D7 and D8 releases at the same time with a single command.

3. Make sure the script did the right things:

   `git show`

   `git log`
   
   `git diff 8.1.6 8.1.7`
   
4. Only push your tags and commits using the command the script displays, and
    only after you have approval from the security team.

Security release with manual merge conflict resolution: `manual_merge_sec.sh` and `conclude_merge.sh`
-----------------------------------------------------------------------------
1. Check out the correct branch(es) and ensure you have the latest changes:

   `git checkout 9.1.x; git pull`

2. Run the script, with the tag(s) to create as arguments:

   `/path/to/core_release/sec.sh 9.1.3 9.0.11 8.9.13`

   The script will prompt you for information about the SA, then apply the
   patches and create working branches. It will stop before merging the tags
   and output instructions for merging the tags manually.

3. Follow the instructions to merge the tags after reviewing
   [how to manually resolve the expected merge conflicts](https://www.drupal.org/core/maintainers/create-core-security-release/dep-update#release).

4. Run `/path/to/cor_release/conclude_merge.sh`.

5. Make sure the script did the right things:

   `git show`

   `git log`

   `git diff 9.1.3 9.1.2`

6. Only push your tags and commits using the command the script displays, and
    only after you have approval from the security team.


Core branching script: `branch.sh`
----------------------------------

1. Follow the prompts.
2. Manually push the new branch once it is created.
3. Be sure to configure automated testing.
4. Ask drumm to run any needed issue migrations and to update api.d.o.
