Drupal 8.4.0, 2017-10-05
------------------------
### Drush users: Update to Drush 8.1.12

[Versions of Drush earlier than 8.1.12 will not work with Drupal
8.4.x](https://www.drupal.org/node/2874827). Update Drush to 8.1.12 or
higher **before using it to update to Drupal core 8.4.x** or you will
encounter fatal errors that prevent updates from running. (Drush 8.1.12
and 8.1.13 will successfully update Drupal 8.3.x to 8.4.0, but users may still
see [other error messages after updates have
run](https://www.drupal.org/node/2907224).)

### Updated browser requirements: Internet Explorer 9 and 10 no longer supported

In April 2017, Microsoft discontinued all support for Internet Explorer 9 and
10. Therefore, [Drupal 8.4 has as well](https://www.drupal.org/node/2842298).
Drupal 8.4 still mostly works in these browser versions, but bugs that affect
them only will no longer be fixed, and existing workarounds for them will
be removed beginning in Drupal 8.5.

Additionally, Drupal 8's [browser requirements documentation
page](https://www.drupal.org/docs/8/system-requirements/browser-requirements)
currently lists incorrect information regarding very outdated browser versions
such as Safari 5 and Firefox 5. [Clarifications to the browser policy and
documentation](https://www.drupal.org/node/2390621) are underway.

### Known Issues

* Drupal 8.4.0-alpha1 includes major version updates for two dependencies:
  Symfony 3.2 and jQuery 3. Both updates may introduce backwards compatibility
  issues for some sites or modules, so test carefully.
  For more information, see the "Third-party library updates" section below.
  Known issues related to the Symfony update include:
    * [Incompatibility with Drush 8.1.11 and earlier](https://www.drupal.org/node/2874827).
    * [Other error messages with Drush 8.1.12 and higher](https://www.drupal.org/node/2907224).
    * [Certain file uploads may fail silently](https://www.drupal.org/node/2906030)
      due to a Symfony 3 backwards compatibility break if they used the `$deep`
      parameter (which was already deprecated in Symfony 2.8 and is removed
      in Symfony 3.0. *Check any custom file upload code* that may have used
      the deprecated parameter and [update it according to the API change
      record](https://www.drupal.org/node/2743809).

### Important fixes since 8.3.x

Translators should take note of several [string additions and changes since the last release](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&issue_tags_op=%3D&issue_tags=String+change+in+8.4.0).

#### File usage tracking

Drupal 8 has several longstanding [file usage tracking
bugs](https://www.drupal.org/node/2821423). To prevent further data loss,
Drupal 8.4 has [disabled the automatic deletion of files with no known remaining usages](https://www.drupal.org/node/2801777).
This will result of the accumulation of unused files on sites, but ensures that
files erroneously reporting 0 usages are not deleted while in use. Additionally,
an issue with [validation errors when saving content referencing these
files](https://www.drupal.org/node/2896480) has also been resolved.

[The change record explains how sites can opt back into marking files temporary](https://www.drupal.org/node/2891902).
If you choose to enable the setting, you can also set "Delete orphaned files"
to "Never" on `/admin/config/media/file-system` to avoid permanent deletion of
the affected files.

While the files will no longer be deleted by default, file usage is still not
tracked correctly in several scenarios, regardless of the setting. Discussion
on [how to evolve the file usage tracking system](https://www.drupal.org/node/2821423)
is underway.

#### Configuration export sorting

* [#2361539: Config export key order is not predictable for sequences, add orderby property to config schema](https://www.drupal.org/node/2361539)
  resolves an issue where sequences in configuration were not sorted unless
  the code responsible for saving configuration explicitly performed a sort.
  This resulted in unpredictable changes in configuration ordering and
  confusing diffs even when nothing had changed. To resolve this issue, we've
  [added an `orderby` key to the config schema](https://www.drupal.org/node/2852566)
  that allows it to be sorted either by key or by value. Adding a preferred
  sort is strongly recommended.
* Two related issues remain open:
    * [#2860531: Add orderby key to third party settings](https://www.drupal.org/node/2860531)
      relates to unsorted sequences which result in unexpected discrepancies
      in configuration during a configuration import.
    * [#2885368: Config export key order for sequences: "orderedby" does not support cases where the order actually matters](https://www.drupal.org/node/2885368)
      relates to various sequences in core and contributed modules in which
      the source order is important.

#### Revision data integrity fixes

* Previously, data from draft revisions for [path aliases](https://www.drupal.org/node/2856363),
  [menus](https://www.drupal.org/node/2858434), and [books](https://www.drupal.org/node/2858431)
  could leak into the live site. Drupal 8.4.0-alpha1 hotfixes all three issues
  by preventing changes to this data from being saved on any revision that is
  not the default revision. These fixes improve revision support for both
  stable features and the experimental Content Moderation module.
* Correspondingly, [Content Moderation now avoids such scenarios with non-default revisions](https://www.drupal.org/node/2883868)
  by setting the 'default revision' flag earlier.
* Previously, [saving a revision of an entity translation could cause draft revisions to go "missing"](https://www.drupal.org/node/2766957).
  Drupal 8.4. prevents this by preventing the moderation state from being set
  to anything that would make the revision go "missing".
  [A similar but unrelated bug in Content Moderation](https://www.drupal.org/node/2862988)
  has also been fixed in this release.

#### Other critical improvements

* When nodes were deleted, Menu UI module deleted their menu items. However, menu
  items may exist even whenm Menu UI module is not enabled and can also be attached
  to entities other than nodes. Therefore, menu item cleanup on entity deletetion
  [is now performed by the Custom Menu Links module](https://www.drupal.org/node/2350797)
  instead, covering the previously missing cases. A related issue that [broke module uninstallation
  for some modules providing menu items for certain entity forms](https://www.drupal.org/node/2907654) has also been resolved.
* A race condition occured in the Batch API when using fastcgi. The Batch API now
  ensures that [the current batch state is written completely to the database before
  starting the next batch](https://www.drupal.org/node/2851111).
* When uninstalling modules, empty fields were left behind to be purged. However,
  without the field definitions, it was not possible to purge them anymore.
  [Empty field deletion is now performed immediately](https://www.drupal.org/node/2884202).

### New stable modules

The following modules, previously considered experimental, are now stable and
safe for use on production sites, with full backwards compatibility and upgrade
paths from 8.4.0 to future releases:

#### Datetime Range

The [Datetime Range module](https://www.drupal.org/node/2893128) provides a
field type that allows end dates to support contributed modules like
[Calendar](https://www.drupal.org/project/calendar). This stable release is
backwards-compatible with the 8.3.x experimental version and shares a
consistent API with other Datetime fields.

Future releases may improve Views support, usability, Datetime Range field
validation, and REST support. For bugs or feature requests for this
module, [see the core Datetime issue queue](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=Open&version%5B%5D=8.x&component%5B%5D=datetime.module&issue_tags_op=%3D).

#### Layout Discovery

The [Layout Discovery module](https://www.drupal.org/node/2834025) provides
an API for modules or themes to register layouts as well as five common
layouts. Providing this API in core enables
core and contributed layout solutions to be compatible with each other. This
stable release is backwards-compatible with the 8.3.x experimental version
and introduces [support for per-region attributes](https://www.drupal.org/node/2885877).

#### Media

The new core [Media module](https://www.drupal.org/node/2831274) provides an
API for reusable media entities and references. It is based on the contributed
[Media Entity module](https://www.drupal.org/project/media_entity).

Since there is a rich ecosystem of Drupal contributed modules built on Media
Entity, the top priority for this release is to
[provide a stable core API and data model](https://www.drupal.org/node/2895059)
for a smoother transition for these modules. Developers and expert
site builders can now add Media as a dependency. Work is underway to
[provide an update path for existing sites' Media Entity data](https://www.drupal.org/node/2880334)
and to [port existing contributed modules to the refined core API](https://www.drupal.org/node/2860796).

Note that **the core Media module is currently marked hidden** and will not
appear on the 'Extend' (module administration) page. (Enabling a contributed
module that depends on the core Media module will also enable Media
automatically.) The module will be displayed to site builders normally once
user experience issues with it are resolved in a future release.

Similarly, the REST API and normalizations for Media is not final and support
for decoupled applications will be improved in a future release.

#### Inline Form Errors

The [Inline Form Errors module](https://www.drupal.org/node/2897652) provides a
summary of any validation errors at the top of a form and places the individual
error messages next to the form elements themselves. This helps users
understand which entries need to be fixed, and how. Inline Form Errors was
provided as an experimental module from Drupal 8.0.0 on, but it is now stable
and polished enough for production use. See the core
[Inline Form Errors module issue queue](https://www.drupal.org/project/issues/drupal?text=&status=Open&priorities=All&categories=All&version=All&component=inline_form_errors.module)
for outstanding issues.

#### Workflows

The Workflows module provides an abstract system of states (like Draft,
Archived, and Published) and transitions between them. Workflows can be used by
modules that implement non-publishing workflows (such as for users or products)
as well as content publishing workflows.

Drupal 8.4 introduces a final significant backwards compatibility and data
model break for this module,
[moving responsibility for workflow states and transitions from the Workflow entity to the Workflow type plugin](https://www.drupal.org/node/2849827).
Read [Workflow type plugins are now responsible for state and transition schema](https://www.drupal.org/node/2897706)
for full details on the API and data model changes related to this fix. Now
that this change is complete, [the Workflows module became stable](https://www.drupal.org/node/2897130)!

While the module can be installed as-is, it is not useful in itself without
either Content Moderation and/or some other module that requires it.

### Content authoring and site administration improvements

* The "Save and keep (un)published" dropbutton has been replaced with [a "Published" checkbox and single "Save" button](https://www.drupal.org/node/2068063).
  The "Save and..." dropbutton was a new design in Drupal 8, but users found it
  confusing, so we have restored a design that is more similar to the user
  interface for Drupal 7 and earlier.
* Previously, deleting a field on a content type would also delete any views
  depending on the field. While the confirmation form did indicate that the
  view would be deleted, users did not expect the behavior and often missed the
  message, leading to data loss.
  [Now, the view is disabled instead](https://www.drupal.org/node/2468045). In
  the future, we intend to
  [notify users that configuration has been disabled](https://www.drupal.org/node/2832558)
  (as in this fix) as well as
  [give users clearer warnings for other highly destructive operations](https://www.drupal.org/node/2773205).
* The [Drupal toolbar no longer flickers](https://www.drupal.org/node/2542050)
  during page rendering, thus improving perceived front-end performance.
* Options in [timezones selector are now grouped by regions](https://www.drupal.org/node/2847651)
  and labeled by cities instead of timezone names, making it much easier for users to find and select the specific timezone they need.
* Both the ["Comments" administration page at `/admin/content/comment`](https://www.drupal.org/node/1986606)
  and the ["Recent log messages" report provided by dblog](https://www.drupal.org/node/2015149)
  are now configurable views. The "Comments" administration page also [has some
  default filters added](https://www.drupal.org/node/2898344).
* Useful meta information about a node's status is typically displayed at the
  top of the node sidebar. Previously, this meta information was provided by
  the Seven theme, so it was not available in other administrative themes.
  [This meta information is now provided by node.module itself](https://www.drupal.org/node/2803875)
  so other administration themes can access it.
* [Views now supports rendering computed fields](https://www.drupal.org/node/2852067).

### REST and API-first improvements

* Authenticated REST API performance increased by 15% by
  [utilizing the Dynamic Page Cache](https://www.drupal.org/node/2827797).
* POSTing entities [can now happen at `/node`, `/taxonomy/term` and so on](https://www.drupal.org/node/2293697),
  instead of `/entity/node`, `/entity/taxonomy_term`. Instead of confusingly
  different URLs, they therefore now use the URLs you'd expect. Backwards
  compatibility is maintained.
* There is now a dedicated resource for [resetting a user's password](https://www.drupal.org/node/2847708).
* Time fields now are [normalized to RFC3339 timestamps by default](https://www.drupal.org/node/2768651), fixing
  time ambiguity. Existing sites continue to receive UNIX timestamps, but can
  opt in. [See the change record for more information about backwards compatibility and on how to opt in](https://www.drupal.org/node/2859657).
* [Path alias fields now are normalized too](https://www.drupal.org/node/2846554).
  [See the change record for information about how this impacts API-first modules and other features relying on serialized entities](https://www.drupal.org/node/2856220).
* When denormalization fails, a [422 response is now returned](https://www.drupal.org/node/2827084)
  instead of a 400, per the HTTP specification.
* With CORS enabled to allow origins besides the site's own host,
  [submitting forms was broken](https://www.drupal.org/node/2853201) unless the
  site's own host was also explicitly allowed.
* Fatal errors and exceptions [now show a backtrace](https://www.drupal.org/node/2853300)
  for all non-HTML requests as well as HTML requests, which makes for easier
  debugging and better bug reports.
* Massive expansion of test coverage.

### Performance and scalability improvements

* Drupal 8 caches at various different levels for more effective caching. However, this
  resulted in exessively growing cache tables with tens or hundreds of thousands of
  entries, and gigabytes in size.
  [A new limit of 5000 rows per cache bin was introduced to limit this growth](https://www.drupal.org/node/2526150).
* The internal page cache now [has a dedicated cache bin](https://www.drupal.org/node/2889603)
  distinct from the rest of the render cache for improved scalability.
* The service collector pattern instantiates all services it collects, which is expensive, and unnecessary for some use cases.   For those use cases, a [new service ID collector](https://www.drupal.org/node/2472337)
  pattern was added. The theme negotiator was updated to use it.
  [See the change record for information about how to use the service ID collector](https://www.drupal.org/node/2598944) for improved performance.
* The maximum time in-progress forms are cached [is now customizable](https://www.drupal.org/node/1286154)
  rather than being limited to a default cache lifetime of 6 hours. Sites can
  decrease the lifetime to reduce cache footprint, or increase it if needed for
  a particular site's usecase.
  [See the change record to learn how to access this new setting](https://www.drupal.org/node/2886836).
* If there are no status messages, the corresponding rendering
  [is now skipped](https://www.drupal.org/node/2853509). On simple sites that use the
  Dynamic Page Cache (on by default), this can result in a 10% improvement when there are no messages!
* [Optimized the early Drupal installer](https://www.drupal.org/node/2872611)
  to check whether any themes are installed first before invoking an
  unnecessary function, which improves Drupal install time measurably for
  both sites and automated tests.

### Developer experience improvements

* [Adopted Airbnb JavaScript style guide 14.1](https://www.drupal.org/node/2815077) as the new baseline set of
  coding standards for Drupal core and contributed modules.
  [See the change record for information about how to configure your project for eslint](https://www.drupal.org/node/2873849).
* Field type definitions can now [enforce the cardinality of the field](https://www.drupal.org/node/2403703).
  [See the change record for information about how to specify a cardinality via the annotation](https://www.drupal.org/node/2869873).
* [Added new methods](https://www.drupal.org/node/2869809) to make getting
  typed configuration entity representations easier.
  [See the change record for more information about how to invoke these methods](https://www.drupal.org/node/2877282).
* The `html_tag` render element now [supports nested render arrays](https://www.drupal.org/node/2694535),
  enabling the creation of dynamic SVGs.
  [See the change record for information about how you can use this in your theme](https://www.drupal.org/node/2887146).
* [Added more helpful errors](https://www.drupal.org/node/2705037) when CSS
  is not properly nested under an existing category in asset libraries.
* Also see the [change records for the 8.4.x branch](https://www.drupal.org/list-changes/drupal/published?keywords_description=&to_branch=8.4.x&version=&created_op=%3E%3D&created%5Bvalue%5D=&created%5Bmin%5D=&created%5Bmax%5D=)
  for other changes for developers.

### Automated testing improvements

* [PHPUnit has been updated from 4.8.28 to 4.8.35](https://www.drupal.org/node/2850797)
  in order to incorporate a forward compatibility layer for PHPUnit 4.8, useful
  during a future migration to PHPUnit 5 or PHPUnit 6.
* Many former WebTestBase tests were converted to BrowserTestBase.
  [Track current progress](http://simpletest-countdown.org/).
* The default approach for testing deprecated code has changed to
  [require use of the Drupal core deprecation policy](https://www.drupal.org/node/2488860)
  (`@trigger_error()`) to mark code deprecated; otherwise a test error will
  be thrown.
  [See the change record for information about how to update `phpunit.xml` and how to test deprecated code](https://www.drupal.org/node/2811561).
* [Resolved random test failures](https://www.drupal.org/node/2866056) due to
  ResourceTestBase's HTTP client timeout of 30 seconds.

### Third-party library updates

* [Drupal's Symfony dependency has been updated from Symfony 2.8 to Symfony
  3.2](https://www.drupal.org/node/2712647). This major version update is
  necessary because Symfony 2.8 support will end around the release of Drupal
  8.6.0 next year. See the change record for information about [Symfony 3 backwards compatibility
  breaks that affected Drupal core](https://www.drupal.org/node/2743809).
  [Drupal 8 also requires Symfony 3.2.8](https://www.drupal.org/node/2871253)
  because of a bug in Symfony 3.2.7.
* [#2533498: Update jQuery to version 3](https://www.drupal.org/node/2533498).
  Now that jQuery 3.0 has been released, jQuery 2.x will only be receiving
  security updates, so Drupal 8.4.0 ships with this library update. jQuery 3
  features numerous improvements, including better error reporting. See the
  [jQuery Core 3.0 Upgrade Guide](https://jquery.com/upgrade-guide/3.0/) for
  information on jQuery 3 backwards compatibility breaks that might affect the
  JavaScript code in your modules, themes, and sites.
* The zurb/joyride library (used by the Tour module) has been
  [updated to a development version higher than 2.1.0.1](https://www.drupal.org/node/2898808)
  to resolve an upstream incompatibility with jQuery 3. We will update to Joyride 2.1.1 once
  it is available with the needed fix.
* [zendframework/zend-diactoros has been updated from 1.3.10 to 1.4.0](https://www.drupal.org/node/2874817).
* [jQuery UI has been updated from 1.11.4 to 1.12.1](https://www.drupal.org/node/2809427).
* [jQuery Once has been updated from 2.1.1 to 2.2.0](https://www.drupal.org/node/2899156).
* [CKEditor has been updated from 4.6.2 to 4.7.2](https://www.drupal.org/node/2904142).
* [asm89/stack-cors has been updated from 1.0 to 1.1](https://www.drupal.org/node/2853201).
* [The minimum phpsec/prophecy requirement is now 1.4](https://www.drupal.org/node/2900800).

### Experimental modules

#### Migrate ([beta stability](https://www.drupal.org/core/experimental#beta))

Migrate provides a general API for migrations. It will be considered completely
stable once all  issues tagged [Migrate critical](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=Open&version%5B%5D=8.x&issue_tags_op=%3D&issue_tags=Migrate+critical) are resolved.

* Renamed [`migration` process plugin to `migration_lookup`](https://www.drupal.org/node/2845486)
  and
  [`iterator` process plugin to `sub_process`](https://www.drupal.org/node/2845483)
  to better capture their purposes. (Backwards compatibility is provided for
  both process plugins since Migrate is in beta.)
* Added the ability to [provide the source module](https://www.drupal.org/node/2569805)
  to migrations.

#### Migrate Drupal and Migrate Drupal UI ([alpha stability](https://www.drupal.org/core/experimental#alpha))

Migrate Drupal module provides API support for Drupal-to-Drupal migrations, and
Migrate Drupal UI offers a simple user interface to run migrations from older
Drupal versions.

* This release adds [date](https://www.drupal.org/node/2566779) and
  [node reference](https://www.drupal.org/node/2814949) support for Drupal 6 to
  8 migrations.
* Core provides migrations for most Drupal 6 data and can be used for migrating
  Drupal 6 sites to Drupal 8, and the Drupal 6 to 8 migration path is nearing
  beta stability. Some gaps remain, such as for some internationalization data.
  ([Outstanding issues for the Drupal 6 to Drupal 8 migration](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=1&status%5B%5D=13&status%5B%5D=8&status%5B%5D=14&status%5B%5D=15&status%5B%5D=4&issue_tags_op=%3D&issue_tags=migrate-d6-d8))
* The Drupal 7 to Drupal 8 migration is incomplete but is suitable for
  developers who would like to help improve the migration and can be used to
  test upgrades especially for simple Drupal 7 sites. Most high-priority
  migrations are available.
  ([Outstanding issues for the Drupal 7 to Drupal 8 migration](https://www.drupal.org/node/2456259))
* Drush support for Migrate is currently only available in the
  [Drupal Upgrade](https://www.drupal.org/project/migrate_upgrade) contributed
  module. (See the
  [pull request to add support to Drush](https://github.com/drush-ops/drush/issues/2140).)
* [Renamed migration field plugins and classes](https://www.drupal.org/node/2683435)
  referring to custom fields provided by the Drupal 6 CCK module, which was
  replaced in Drupal 7 by the core Field API. [See the change record for more information about how this impacts your migration plugins](https://www.drupal.org/node/2751897).
  The migration [classes extending from CCKFieldPluginBase are also deprecated
  in favor of field migration classes](https://www.drupal.org/node/2833206).
* Field type mapping became easier with
  [default implementations of getFieldFormatterMap() and processFieldValues()](https://www.drupal.org/node/2896507).
* Conflicting text field processing settings [are now identified and logged](https://www.drupal.org/node/2842222).
  To support this change, [a new ProcessField plugin was added](https://www.drupal.org/node/2893061)
  to dynamically compute the migrated field type.
* [The field instance source plugin got refactored](https://www.drupal.org/node/2891935),
  resulting in changed migration template keys.
* Automatic redirects are now
  [added for node paths that are not valid anymore due to translation merges](https://www.drupal.org/node/2850085).
* @todo * [Migration for forum and article comments: duplicate comment types and incorrect comment_entity_statistics](https://www.drupal.org/node/2853872)
* @todo [File migration from D6 to D8 version using Migrate Drupal UI](https://www.drupal.org/node/2907233)

#### Content Moderation ([beta stability](https://www.drupal.org/core/experimental#beta))

Content Moderation allows workflows from the Workflows module to be applied to
content. Content Moderation has beta stability in 8.4.0-alpha1, but may become
stable in time for 8.4.0! Notable improvements in this release:

* Workflow states are now [selected from a select list, rather than under a drop-button](https://www.drupal.org/node/2753717), which represents a significant
  usability improvement.
* Now that workflows can be applied to any revisionable entity type, Content
  Moderation [adds entity type checkboxes to the workflow form](https://www.drupal.org/node/2843083).
  This allows site administrators to configure which entity types should have
  the workflow at the same time as they configure the workflow itself, for a
  more intuitive user experience.
* Content Moderation now [prevents the deletion of workflows that are currently in use](https://www.drupal.org/node/2830740)
  to prevent fatal errors and data integrity problems.
* The confusing terminology of
  ["forward revisions" has been replaced with that of "pending revisions"](https://www.drupal.org/node/2890364).
  If your contributed module refers to revisions that are not yet published, it
  should use this new term.

As per the experimental module process, there were some backwards incompatible
changes since Drupal 8.3.x. Experimental modules do not offer a supported
upgrade path, but [an unofficial upgrade path is being worked on](https://www.drupal.org/node/2896630).

#### Field Layout ([alpha stability](https://www.drupal.org/core/experimental#alpha))

This module provides the ability for site builders to rearrange fields on
content types, block types, etc. into new regions, for both the form and
display, on the same forms provided by the normal field user interface.  Field
Layout has had several bugfixes since 8.3.0, but no significant changes. See
the [entity display layout roadmap](https://www.drupal.org/node/2795833) for
the next steps for this module, which needs to become stable by 8.5.0 to remain
in Drupal core.

#### Settings Tray ([beta stability](https://www.drupal.org/core/experimental#beta))

The Settings Tray module allows configuring page elements such as blocks and
menus from the frontend of your site. Settings Tray has improved significantly
since Drupal 8.3.0. The module reached beta stability following completion of
[moving the off-canvas dialog renderer into a core component](https://www.drupal.org/node/2784443), and
[renaming the machine name of the module to settings_tray](https://www.drupal.org/node/2803375),
to match its user-facing name. We hope to make Settings Tray stable by 8.5.0.
To track progress, see the ["outside in" roadmap issue](https://www.drupal.org/node/2762505).

* [A CSS reset has been added to the Settings Tray](https://www.drupal.org/node/2826722) to improve the themer experience.
* Form validation messages now [appear in the Settings Tray instead of main page](https://www.drupal.org/node/2785047).
* [The toolbar background in Edit mode now matches the edit button](https://www.drupal.org/node/2894427),
  instead of the white background that many users found distracting or
  misunderstood to be an indication that something was broken.
* The block title field in the tray is now [labeled more clearly and only shown when the block title itself is shown](https://www.drupal.org/node/2882729).
* In the contextual links, ["Quick edit" is now listed before "Configure"](https://www.drupal.org/node/2784567),
  and the [custom blocks instead have a "Quick edit settings" link](https://www.drupal.org/node/2786193)
  (to distinguish them from the links provided by the Quick Edit module, which
  allow editing the content of the custom block itself).
* Edit mode [now behaves the same way whether accessed by clicking "Quick edit" or clicking through the toolbar](https://www.drupal.org/node/2847664)
* Users can now [escape from Edit mode with the ESC key](https://www.drupal.org/node/2784571), for better accessibility.

#### Place Blocks ([alpha stability](https://www.drupal.org/core/experimental#alpha))

This feature allows the user to place a block on any page and see the region
where it will be displayed, without having to navigate to a backend
administration form.
[8.4.0-alpha1 was the deadline for Place Blocks to stabilize](https://www.drupal.org/core/experimental#versions),
but the module's roadmap was not completed. Furthermore, the module is not
intended as a standalone feature and should instead be a built-in part of the
Block system. For these reasons,
[Place Blocks module has been marked hidden in this release](https://www.drupal.org/node/2898267)
(it can still be enabled with Drush). The Place Blocks module itself will be
turned into an empty module in Drupal 8.5.x, since ideally the core Block
system will offer the same functionality in 8.5.0 (though this depends on
completion of a [core patch for the feature](https://www.drupal.org/node/2739075).)
