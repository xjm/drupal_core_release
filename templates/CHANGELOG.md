Drupal 8.4.0, 2017-10-05
------------------------

## Drush users: Update to Drush 8.1.12

[Versions of Drush earlier than 8.1.12
will not work with Drupal 8.4.x](https://www.drupal.org/node/2874827). Update Drush to 8.1.12 before using it to
update to Drupal core 8.4.x or you will encounter fatal errors.

## Updated browser requirements: Internet Explorer 9 and 10 no longer supported

In April 2017, Microsoft discontinued all support for Internet Explorer 9 and
10. Therefore, [Drupal 8.4 has as well](https://www.drupal.org/node/2897971).
Drupal 8.4 still mostly works in these browser versions, but bugs that affect them only will no longer be
fixed, and existing workarounds for them will
be removed beginning in Drupal 8.5.

Additionally, Drupal 8's [browser requirements documentation page](https://www.drupal.org/docs/8/system-requirements/browser-requirements)
currently lists incorrect information regarding very outdated browser versions
such as Safari 5 and Firefox 5. [Clarifications to the browser policy and documentation](https://www.drupal.org/node/2390621) are underway and we hope to finalize it before 8.4.0-rc1.

## Known Issues

* Drupal 8.4.0-alpha1 includes major version updates for two dependencies: Symfony 3.2 and jQuery 3.
  Both updates may introduce backwards compatibility issues for some sites or modules, so test carefully.
  For more information, see the "Third-party library updates" section below.
* [Modal tour tips provided by the Tour module are not displayed correctly](https://www.drupal.org/node/2898808)
  because the third-party Joyride library has an incompatibility with jQuery 3.
  Tour tips are no longer centered and may be displayed entirely off-screen for many screen sizes.
  Work is underway on an upstream bug fix.
* Some sites that have files with 0 recorded usages may encounter
  [validation errors when saving content referencing these files](https://www.drupal.org/node/2896480).
  If your site's users report errors when saving content, you can
  [set the `file.settings.make_unused_managed_files_temporary` setting to `true`](https://www.drupal.org/node/2891902),
  but make sure you also set "Delete orphaned files" to "Never" on `/admin/config/media/file-system`
  to avoid permanent deletion of the affected files.

## Important bug fixes since 8.3.x

### File usage tracking

Drupal 8 has several longstanding [file usage tracking
bugs](https://www.drupal.org/node/2821423). To prevent further data loss,
Drupal 8.4 has [disabled the automatic deletion of files with no known remaining
usages](https://www.drupal.org/node/2801777). This will result of the accumulation
of unused files on sites, but ensures that files erroneously reporting 0 usages are
not deleted while in use.
[The change record explains how sites can opt back into marking files temporary](https://www.drupal.org/node/2891902).
If you choose to enable the setting, you canalso set "Delete orphaned files" to
"Never" on `/admin/config/media/file-system` to avoid permanent deletion of the affected files.

While the files will no longer be deleted by default, file usage is still not
tracked correctly in several scenarios, regardless of the setting. 
Discussion on [how to evolve the file usage tracking system](https://www.drupal.org/node/2821423)
is underway.

### Configuration export sorting

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

### Revision data integrity fixes

* Previously, data from draft revisions for [path aliases](https://www.drupal.org/node/2856363),
 [menus](https://www.drupal.org/node/2858434), and [books](https://www.drupal.org/node/2858431)
 could leak into the live site. Drupal 8.4.0-alpha1 hotfixes all three issues by
 preventing changes to this data from being saved on any revision that is not the
 default revision. These fixes improve revision support for both stable features
 and the experimental Content Moderation module.
* Correspondingly, [Content Moderation now avoids such scenarios with non-default revisions](https://www.drupal.org/node/2883868) by setting the 'default revision' flag earlier.
* Previously, [saving a revision of an entity translation could cause draft revisions to go "missing"](https://www.drupal.org/node/2766957). Drupal 8.4. prevents this by preventing the moderation state from being set to anything that would make the revision go "missing". [A similar but unrelated bug in Content Moderation](https://www.drupal.org/node/2862988) has also been fixed in this release.

## New stable modules

The following modules, previously considered experimental, are now stable and
safe for use on production sites, with full backwards compatibility and upgrade
paths from 8.4.0 to future releases:

### Datetime Range

The [Datetime Range module](https://www.drupal.org/node/2893128) provides a
field type that allows end dates to support contributed modules like
[Calendar](https://www.drupal.org/project/calendar). This stable release is
backwards-compatible with the 8.3.x experimental version and shares a
consistent API with other Datetime fields.

Future releases may improve Views support, usability, Datetime Range field
validation, and REST support. For bugs or feature requests for this
module, [see the core Datetime issue queue](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=Open&version%5B%5D=8.x&component%5B%5D=datetime.module&issue_tags_op=%3D).

### Layout Discovery

The [Layout Discovery module](https://www.drupal.org/node/2834025) provides
an API for modules or themes to register layouts as well as five common
layouts. Providing this API in core enables
core and contributed layout solutions to be compatible with each other. This
stable release is backwards-compatible with the 8.3.x experimental version
and introduces [support for per-region attributes](https://www.drupal.org/node/2885877).

### Media

The new core [Media module](https://www.drupal.org/node/2831274) provides an
API for reusable media entities and references. It is based on the contributed
[Media Entity module](https://www.drupal.org/project/media_entity).

Since there is a rich ecosystem of Drupal contributed modules built on Media
Entity, the top priority for this release is to
[provide a stable core API and data model](https://www.drupal.org/node/2895059)
for a smoother transition for these modules. Developers and expert
site builders can add Media as a dependency. Work is underway to [provide an
update path for existing sites' Media Entity data](https://www.drupal.org/node/2880334)
and to [port existing contributed modules to the refined core API](https://www.drupal.org/node/2860796).

Note that **the core Media module is currently marked hidden** and will not
appear on the 'Extend' (module administration) page. (Enabling a contributed
module that depends on the core Media module will also enable the Media
automatically.) The module will be displayed to site builders normally once
user experience issues with it are resolved in a future release.

Similarly, the REST API and normalizations for Media is not final and support
for decoupled applications will be improved in a future release.

### Inline Form Errors

The [Inline Form Errors module](https://www.drupal.org/node/2897652) provides a summary of any validation errors at the top of a form and places the individual error messages next to the form elements themselves. This helps users understand which entries need to be fixed, and how. Inline Form Errors was provided as an experimental module from Drupal 8.0.0 on, but it is now stable and polished enough for production use. See the core [Inline Form Errors module issue queue](https://www.drupal.org/project/issues/drupal?text=&status=Open&priorities=All&categories=All&version=All&component=inline_form_errors.module) for outstanding issues.

## Content authoring and site administration improvements

* The "Save and keep (un)published" dropbutton has been replaced with [a
  "Published" checkbox and single "Save" button](https://www.drupal.org/node/2068063). The "Save and..." dropbutton was a new design in Drupal 8, but users found it confusing, so we have restored a design that is more similar to the user interface for Drupal 7 and earlier.
* Previously, deleting a field on a content type would also delete any views depending on the field. While the confirmation form did indicate that the view would be deleted, users did not expect the behavior and often missed the message, leading to data loss. [Now, the view is disabled instead](https://www.drupal.org/node/2468045). In the future, we intend to [notify users that configuration has been disabled](https://www.drupal.org/node/2832558) (as in this fix) as well as [give users clearer warnings for other highly destructive operations](https://www.drupal.org/node/2773205).
* The [Drupal toolbar no longer flickers](https://www.drupal.org/node/2542050)
  during page rendering, thus improving perceived front-end performance.
* Options in [timezones selector are now grouped by regions](https://www.drupal.org/node/2847651)
  and labeled by cities instead of timezone names, making it much easier for users to find and select the specific timezone they need.
* Both the ["Comments" administration page at `/admin/content/comment`](https://www.drupal.org/node/1986606) and the ["Recent log messages" report provided by dblog](https://www.drupal.org/node/2015149) are now configurable views.
* Useful meta information about a node's status is typically displayed at the top of the node sidebar. Previously, this meta information was provided by the Seven theme, so it was not available in other administrative themes. [This meta information is now provided by node.module itself](https://www.drupal.org/node/2803875)
  so other administration themes can access it.

## REST and API-first improvements

* Authenticated REST API performance increased by 15% by
  [utilizing the Dynamic Page Cache](https://www.drupal.org/node/2827797).
* POSTing entities [can now happen at `/node`, `/taxonomy/term` and so on](https://www.drupal.org/node/2293697),
  instead of `/entity/node`, `/entity/taxonomy_term`. Instead of confusingly
  different URLs, they therefore now use the URLs you'd expect. Backwards
  compatibility is maintained.
* Added dedicated resource for [resetting a user's password](https://www.drupal.org/node/2847708).
* Time fields now are [normalized to RFC3339 timestamps by default](https://www.drupal.org/node/2768651), fixing time
  time ambiguity. Existing sites continue to receive UNIX timestamps, but can
  opt in. [See the change record for more information about backwards compatibility](https://www.drupal.org/node/2859657).
* [Path alias fields now are normalized too](https://www.drupal.org/node/2846554).
  [See the change record for information about how this impacts API-first modules and other features relying on serialized entities](https://www.drupal.org/node/2856220).
* When denormalization fails, a [422 response is now returned](https://www.drupal.org/node/2827084)
  instead of 400, per the HTTP specification.
* With CORS enabled to allow origins besides the site's own host,
  [submitting forms was broken](https://www.drupal.org/node/2853201) unless
  the site's own host was also explicitly allowed.
* Fatal errors and exceptions [now show a backtrace](https://www.drupal.org/node/2853300)
  also for all non-HTML requests, which makes for far easier debugging and
  better bug reports.
* Massive expansion of test coverage.

## Performance and scalability improvements

* The internal page cache now [has a dedicated cache bin](https://www.drupal.org/node/2889603)
  distinct from the rest of the render cache.
* The service collector [no longer loads all dependencies](https://www.drupal.org/node/2472337);
  instead, the new service ID collector allows instances of dependencies to
  be lazily created. [See the change record for information about how to use the service ID collector](https://www.drupal.org/node/2598944).
* The maximum time in-progress forms are cached [is now customizable](https://www.drupal.org/node/1286154)
  rather than being limited to a default cache lifetime of 6 hours.
  [See the change record to learn how to access this new setting](https://www.drupal.org/node/2886836).
* If there are no status messages to be rendered, the corresponding Twig
  template [is no longer loaded](https://www.drupal.org/node/2853509) on every
  page.
* [Optimized the early Drupal installer](https://www.drupal.org/node/2872611)
  to check whether any themes are installed first before invoking an
  unnecessary function.

## Developer experience improvements

* [Adopted Airbnb JavaScript style guide 14.1](https://www.drupal.org/node/2815077) as the new baseline set of
  coding standards for Drupal core and contributed modules.
  [See the change record for information about how to configure your project for eslint](https://www.drupal.org/node/2873849).
* Field type definitions can now [enforce the cardinality of the field](https://www.drupal.org/node/2403703).
  [See the change record for an example of this](https://www.drupal.org/node/2869873).
* [Added new methods](https://www.drupal.org/node/2869809) to make getting
  typed configuration entity representations easier.
  [See the change record for more information about how to invoke these methods](https://www.drupal.org/node/2877282).
* The `html_tag` render element now [supports nested render arrays](https://www.drupal.org/node/2694535),
  enabling the creation of dynamic SVGs. [See the change record for information about how you can use this in your theme](https://www.drupal.org/node/2887146).
* [Added more helpful errors](https://www.drupal.org/node/2705037) when CSS
  is not properly nested under an existing category in asset libraries.

## Automated testing improvements

* [PHPUnit has been updated from 4.8.28 to 4.8.35](https://www.drupal.org/node/2850797)
  in order to incorporate a forward compatibility layer for PHPUnit 4.8,
  useful during a future migration to PHPUnit 5 or PHPUnit 6.
* Many former WebTestBase tests were converted to BrowserTestBase.
  [Track current progress](http://simpletest-countdown.org/).
* The default approach for testing deprecated code has changed to
  [require use of the Drupal core deprecation policy](https://www.drupal.org/node/2488860)
  (`@trigger_error()`) to mark code deprecated; otherwise a test error will
  be thrown.
* [RTBC] In preparation for [JavascriptTests with webDriver](https://www.drupal.org/node/2775653),
  methods to test status code and response headers [are now disabled](https://www.drupal.org/node/2827014).
* [Resolved random test failures](https://www.drupal.org/node/2866056) due to
  ResourceTestBase's HTTP client timeout of 30 seconds.

## Third-party library updates

* [Drupal's Symfony dependency has been updated from Symfony 2.8 to Symfony
  3.2](https://www.drupal.org/node/2712647). This major version update is
  necessary because Symfony 2.8 support will end around the release of Drupal
  8.6.0 next year. [See the change record for information about Symfony 3 backwards compatibility
  breaks that affected Drupal core](https://www.drupal.org/node/2743809).
  [Drupal 8 also requires Symfony 3.2.8](https://www.drupal.org/node/2871253)
  because of a bug in Symfony 3.2.7.
* [#2533498: Update jQuery to version 3](https://www.drupal.org/node/2533498). Now that jQuery 3.0 has been released, jQuery 2.x will only be receiving security updates, so Drupal 8.4.0 ships with this library update. jQuery 3 features numerous improvements, including 
 better error reporting. See the [jQuery Core 3.0 Upgrade Guide](https://jquery.com/upgrade-guide/3.0/)  for information on jQuery 3 backwards compatibility breaks that might affect the JavaScript code in your modules, themes, and sites. Note that we may consider rolling back this library update if the [bug affecting tours](https://www.drupal.org/node/2898808) is not resolved in time for Drupal 8.4.0-beta1.
* [zendframework/zend-diactoros has been updated from 1.3.10 to 1.4.0](https://www.drupal.org/node/2874817).
* [jQuery UI has been updated from 1.11.4 to 1.12.1](https://www.drupal.org/node/2809427).
* [CKEditor has been updated from 4.6.2 to 4.7.1](https://www.drupal.org/node/2893566).
* [asm89/stack-cors has been updated from 1.0 to 1.1](https://www.drupal.org/node/2853201).

## Experimental modules

### Migrate ([beta stability](https://www.drupal.org/core/experimental#beta))

Migrate provides a general API for migrations. It will be considered completely stable once all  issues tagged [Migrate critical](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=Open&version%5B%5D=8.x&issue_tags_op=%3D&issue_tags=Migrate+critical) are resolved.

### Migrate Drupal and Migrate Drupal UI ([alpha stability](https://www.drupal.org/core/experimental#alpha))

Migrate Drupal module provides API support for Drupal-to-Drupal migrations, and Migrate Drupal UI offers a simple user interface to run migrations from older Drupal versions.

* This release adds [date](https://www.drupal.org/node/2566779) and [node reference](https://www.drupal.org/node/2814949) support for Drupal 6 to 8 migrations.
* Core provides migrations for most Drupal 6 data and can be used for migrating Drupal 6 sites to Drupal 8, and the Drupal 6 to 8 migration path is nearing beta stability. Some gaps remain, such as for some internationalization data. ([Outstanding issues for the Drupal 6 to Drupal 8 migration](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=1&status%5B%5D=13&status%5B%5D=8&status%5B%5D=14&status%5B%5D=15&status%5B%5D=4&issue_tags_op=%3D&issue_tags=migrate-d6-d8))
* The Drupal 7 to Drupal 8 migration is incomplete but is suitable for developers who would like to help improve the migration and can be used to test upgrades especially for simple Drupal 7 sites. Most high-priority migrations are available. ([Outstanding issues for the Drupal 7 to Drupal 8 migration](https://www.drupal.org/node/2456259))
* Drush support for Migrate is currently only available in the [Drupal Upgrade](https://www.drupal.org/project/migrate_upgrade) contributed module. (See the [pull request to add support to Drush](https://github.com/drush-ops/drush/issues/2140).)

* [Added field plugin](https://www.drupal.org/node/2814949) to handle
  migration of node reference field values from Drupal 6 to Drupal 8.
* [Added date field plugin](https://www.drupal.org/node/2566779) to handle
  migration of CCK date fields in Drupal 6 to Drupal 8.
* [Renamed migration field plugins and classes](https://www.drupal.org/node/2683435)
  referring to custom fields provided by the Drupal 6 module CCK, which was
  replaced in Drupal 7 by the core Field API. [See the change record for more information about how this impacts your migration plugins](https://www.drupal.org/node/2751897).
* [Renamed `migration` process plugin to `migration_lookup`](https://www.drupal.org/node/2845486)
  to better capture its purpose.
* [Renamed `iterator` process plugin to `sub_process`](https://www.drupal.org/node/2845483)
  to better capture its purpose.

### Workflows ([beta stability](https://www.drupal.org/core/experimental#beta))

The Workflows module provides an abstract system of states (like Draft, Archived, and Published) and transitions between them. Workflows can be used by modules that implement non-publishing workflows (such as for users or products) as well as content publishing workflows. 

Drupal 8.4 introduces a final significant backwards compatibility and data model break for this module, [moving responsibility for workflow states and transitions from the Workflow entity to the Workflow type plugin](https://www.drupal.org/node/2849827). Read [Workflow type plugins are now responsible for state and transition schema](https://www.drupal.org/node/2897706) for full details on the API and data model changes related to this fix. Now that this change is complete, the Workflows module has reached beta stability, and it may furthermore be marked stable in time for Drupal 8.4.0.

### Content Moderation ([beta stability](https://www.drupal.org/core/experimental#beta))

Content Moderation allows workflows from the Workflows module to be applied to content. Content Moderation has beta stability in 8.4.0-alpha1, but may become stable in time for 8.4.0. Notable improvements in this release:

* Workflow states are now [selected from a select list, rather than under a drop-button](https://www.drupal.org/node/2753717), which represents a significant usability improvement.
* Now that workflows can be applied to any revisionable entity type, Content Moderation [adds entity type checkboxes to the workflow form](https://www.drupal.org/node/2843083). This allows site administrators to configure which entity types should have the workflow at the same time as they configure the workflow itself, for a more intuitive user experience.
* Content Moderation now [prevents the deletion of workflows that are currently in use](https://www.drupal.org/node/2830740) to prevent fatal errors and data integrity problems.
* The confusing terminology of ["forward revisions" has been replaced with that of "pending revisions"](https://www.drupal.org/node/2890364). If your contributed module refers to revisions that are not yet published, it should use this new term.

### Field Layout ([alpha stability](https://www.drupal.org/core/experimental#alpha))

This module provides the ability for site builders to rearrange fields on content types, block types, etc. into new regions, for both the form and display, on the same forms provided by the normal field user interface.  Field Layout has had several bugfixes since 8.3.0, but no significant changes. See the [entity display layout roadmap](https://www.drupal.org/node/2795833) for the next steps for this module, which needs to become stable by 8.5.0 to remain in Drupal core.

### Settings Tray ([alpha stability](https://www.drupal.org/core/experimental#alpha))

The Settings Tray module allows configuring page elements such as blocks and menus from the frontend of your site. Settings Tray has improved significantly since Drupal 8.3.0. The goal for this release is to get Settings Tray to beta stability. Only two issues remain before that milestone: to [move the off-canvas dialog renderer into a core component](https://www.drupal.org/node/2784443), and to [rename the machine name of the module to settings_tray](https://www.drupal.org/node/2803375), to match its user-facing name. We hope to make Settings Tray stable by 8.5.0. To track progress, see the ["outside in" roadmap issue](https://www.drupal.org/node/2762505).

* [A CSS reset has been added to the Settings Tray](https://www.drupal.org/node/2826722) to improve the themer experience.
* Form validation messages now [appear in the Settings Tray instead of main page](https://www.drupal.org/node/2785047).
* [The toolbar background in Edit mode now matches the edit button](https://www.drupal.org/node/2894427), instead of the white background that many users found distracting or misunderstood to be an indication that something was broken.
* The block title field in the tray is now [labeled more clearly and only shown when the block title itself is shown](https://www.drupal.org/node/2882729).
* In the contextual links, ["Quick edit" is now listed before "Configure"](https://www.drupal.org/node/2784567), and the [custom blocks instead have a "Quick edit settings" link](https://www.drupal.org/node/2786193) (to distinguish them from the links provided by the Quick Edit module, which allow editing the content of the custom block itself).
* Edit mode [now behaves the same way whether accessed by clicking "Quick edit" or clicking through the toolbar](https://www.drupal.org/node/2847664)
* Users can now [escape from Edit mode with the ESC key](https://www.drupal.org/node/2784571), for better accessibility.

### Place Blocks ([alpha stability](https://www.drupal.org/core/experimental#alpha))

This feature allows the user to place a block on any page and see the region where it will be displayed, without having to navigate to a backend administration form. [8.4.0-alpha1 was the deadline for Place Blocks to stabilize](https://www.drupal.org/core/experimental#versions), but the module's roadmap was not completed. Furthermore, the module is not intended as a standalone feature and should instead be a built-in part of the Block system. For these reasons, [Place Blocks module has been marked hidden in this release](https://www.drupal.org/node/2898267) (it can still be enabled with Drush). The Place Blocks module itself will be turned into an empty module in Drupal 8.5.x, since ideally, the core Block system will offer the same functionality in 8.5.0 (though this depends on completion of a [core patch for the feature](https://www.drupal.org/node/2739075).)

