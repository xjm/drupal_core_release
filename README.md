# drupal_core_release
Set of scripts for preparing a Drupal core release.

Usage
=====

`bash ./gdo.sh`

Generate a post for http://groups.drupal.org/core about an upcoming patch release window. You will be promped to enter the release number for Drupal 8 (required) and Drupal 7 (optional). Markup for the post is printed to `stdout` and copied to the clipboard with `pbcopy`.

The normal release window dates are used for the next upcoming patch release window. See: https://www.drupal.org/core/release-cycle-overview#dates

`bash ./gdo.sh -d`

Override one or more release window dates for the upcoming post (this patch release window, the following security release window, or the following patch release window).

`bash ./gdo.sh -s`

Generate a g.d.o/core post for an upcoming security release window instead of a patch release window.
