## Note for Drush users: Update to Drush 8.1.12

Versions of [Drush]() earlier than 8.1.12 will not work with Drupal 8.4.x.
Update Drush to 8.1.12 before using it to update Drupal core or you will
encounter fatal errors.

## New stable modules

The following modules, previously considered experimental, are now stable and
safe for use on production sites, with full backwards compatibility and upgrade
paths from 8.4.0 to future releases:

### Datetime Range

The [Datetime Range module](https://www.drupal.org/node/2893128) provides a
field type that allows end dates to support contributed modules like
[Calendar](https://www.drupal.org/project/calendar).

### Media

The [Media module]() provides an API for reusable media entities and references
based on the contributed [Media entity module](). The API and data model are
stable, so developers and expert site builders can add Media as a dependency.
However, the module has numerous user experience issues, so it is *hidden*
and will not appear on the 'Extend' (module administration) page. (Enabling a
contributed module that depends on the Media module will also enable the
Media automatically.) The module will be displayed to site builders normally
once the user experience issues are resolved in a future release.

## REST and API-first improvements

## Developer experience improvements

## Automated testing improvements

## Third-party library updates

* [Drupal's Symfony dependency has been updated from Symfony 2.8 to Symfony
  3.2](https://www.drupal.org/node/2712647). This major version update is
  necessary because Symfony 2.8 support will end around the release of Drupal
  8.6.0 next year. [See the change record for information about Symfony 3 BC
  breaks that affected Drupal core](https://www.drupal.org/node/2743809).
  [Drupal 8 also requires Symfony 3.2.8](https://www.drupal.org/node/2871253)
  because of a bug in Symfony 3.2.7.
* [zendframework/zend-diactoros has been updated from 1.3.10 to 1.4.0](https://www.drupal.org/node/2874817).

## Experimental modules

(Move sections up to "new stable modules" if they become stable.)

### Migrate

### Migrate Drupal

### Migrate Drupal UI

### Workflows and Content Moderation

### Layout Discovery and Field Layout

### Settings Tray

### Place Block
