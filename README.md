# drupal_core_release
Set of scripts for preparing a Drupal core release.

Usage
=====

With each command, markup for the post is printed to `stdout` and copied to the clipboard with `pbcopy`.

Release window announcements for g.d.o/core
-------------------------------------------

Post these announcements a few days in advance of the release window.

`bash ./posts.sh -g`

Generate a post for http://groups.drupal.org/core about an upcoming patch release window. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).

The normal release window dates are used for the next upcoming patch release window. See: https://www.drupal.org/core/release-cycle-overview#dates

`bash ./posts.sh -g -d`

Override one or more release window dates for the upcoming post (this patch release window, the following security release window, or the following patch release window).

`bash ./posts.sh -g -s`

Generate a g.d.o/core post for an upcoming security release window instead of a patch release window.

`bash ./posts.sh -g -s -d`

Generate a g.d.o/core post for an upcoming security release window instead of a patch release window, overriding dates.

Release notes (Drupal 8 only)
-----------------------------

`bash ./posts.sh -r`

Generate a template for the release notes for the patch release (Drupal 8 only). You will be prompted to enter the release number for Drupal 8.

`bash ./posts.sh -r -s`

Generate a template for the release notes for a security release. The template is the same for all versions.

Release announcements for the Drupal.org frontpage
--------------------------------------------------

Post these announcements after the releases are created.

`bash ./posts.sh -f`

Generate a frontpage announcement for https://www.drupal.org about the patch release. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).

`bash ./posts.sh -f -s`

Generate a frontpage announcement for https://www.drupal.org about the security release. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional).
