Drupal 8.4.0, 2017-10-05
------------------------
## Drush users: Update to Drush 8.1.12

Versions of [Drush](https://github.com/drush-ops/drush) earlier than 8.1.12
[will not work with Drupal 8.4.x](https://www.drupal.org/node/2874827). Update Drush to 8.1.12 before using it to
update Drupal core or you will encounter fatal errors.

## Updated browser requirements: Internet Explorer 9 and 10 no longer supported

In April 2017, Microsoft discontinued all support for Internet Explorer 9 and
10. Therefore, [Drupal 8.4 has as well](https://www.drupal.org/node/2897971).
Drupal 8.4 still mostly works in these browser versions, but existing and newly
discovered bugs that only affect these browser versions will no longer be
fixed, and existing workarounds in Drupal core for these browser versions will
be removed beginning in Drupal 8.5.

Additionally, Drupal 8's [browser requirements documentation page](https://www.drupal.org/docs/8/system-requirements/browser-requirements)
currently lists incorrect information regarding very outdated browser versions
such as Safari 5 and Firefox 5. Clarifications to the policy and documentation
are [in progress](https://www.drupal.org/node/2390621), with a goal of being
finalized before 8.4.0-rc1.

## Important bug fixes since 8.3.x

Certain Drupal 8 sites have been reporting vanishing files. Drupal helpfully
removes unused files, but unfortunately there are [several file usage tracking
bugs](https://www.drupal.org/node/2821423). To prevent further data loss,
Drupal 8.4 has [disabled the automatic deletion of files with no remaining
usages](https://www.drupal.org/node/2801777).
[See the change record](https://www.drupal.org/node/2891902), which explains
the broken scenario in detail and describes how sites can opt out.

These file usage bugs are still outstanding and
[discussion on how to evolve the file usage tracking system](https://www.drupal.org/node/2821423)
is underway.

This release also includes one significant data integrity bug fix:

* [#2361539: Config export key order is not predictable for sequences, add orderby property to config schema](https://www.drupal.org/node/2361539)
  resolves an issue where sequences in configuration were not sorted unless
  the code responsible for saving configuration explicitly performed a sort.
  This resulted in unpredictable changes in the ordering of configuration and
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

This release also includes numerous data integrity bug fixes for revision
data, including:

* [#2766957: Forward revisions + translation UI can result in forked draft revisions](https://www.drupal.org/node/2766957)
  addresses an issue in which saving a new entity revision with a moderation
  state affecting the default state would inadvertently cause translations of
  the entity to become the default revision. This would cause certain draft
  revisions to become "missing".
* [#2883868: Content Moderation decides to set a new revision as the default one way too late in the entity update process](https://www.drupal.org/node/2883868)
  prevents users from saving content if any changes have been made which
  would lead to a revision that is not a default revision. This in turn
  prevents issues like the following from resurfacing:
    * [#2856363: Path alias changes for draft revisions immediately leak into live site](https://www.drupal.org/node/2856363)
      prevents draft revisions of content with a newly modified URL alias
      from being publicly accessible at the new alias.
    * [#2858434: Menu changes from node form leak into live site when creating draft revision](https://www.drupal.org/node/2858434)
      prevents draft revisions of content that have a newly added
      corresponding menu item from being publicly accessible in the menu.
    * [#2858431: Book storage and UI is not revision aware, changes to drafts leak into live site](https://www.drupal.org/node/2858431)
      prevents draft revisions of content newly added to a book outline using
      the edit form from being publicly accessible in the book outline.

These fixes improve revision support for both stable features
and the experimental Content Moderation module. [See below for additional
experimental Content Moderation improvements](#workflows-and-content-moderation).

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
validation, and add REST improvements. For bugs or feature requests for this
module, [see the core Datetime issue queue](https://www.drupal.org/project/issues/search/drupal?project_issue_followers=&status%5B%5D=Open&version%5B%5D=8.x&component%5B%5D=datetime.module&issue_tags_op=%3D).

### Layout Discovery

The [Layout Discovery module](https://www.drupal.org/node/2834025) provides
an API for modules or themes to register layouts as well as five common
default layouts. By providing this API in core, we help make it possible for
core and contributed layout solutions to be compatible with each other. This
stable release is backwards-compatible with the 8.3.x experimental version
and introduces [support for per-region attributes](https://www.drupal.org/node/2885877).

See the [layout roadmap](https://www.drupal.org/node/2811175) for the next
steps for this module.

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

## Content authoring and site administration improvements

* The "Save and keep un-/published" buttons which users found confusing
  [have been replaced](https://www.drupal.org/node/2068063) with a
  "Published" checkbox and single "Save" button. [Change record](https://www.drupal.org/node/2847274)
* Deleting a field on a content type [will no longer also delete](https://www.drupal.org/node/2468045)
  views depending on that field; instead, the view is disabled.
  [Change record](https://www.drupal.org/node/2871981)
* The Drupal toolbar [no longer flickers](https://www.drupal.org/node/2542050)
  during page rendering, thus improving perceived front-end performance.
  [Change record](https://www.drupal.org/node/2871997)
* Options in timezones selector [are now grouped by regions](https://www.drupal.org/node/2847651)
  and represent cities instead of timezone names.
  [Change record](https://www.drupal.org/node/2873857)
* The "Comments" administration page at `/admin/content/comment`
  [is now a configurable view](https://www.drupal.org/node/1986606).
  [Change record](https://www.drupal.org/node/2898013)
* The "Recent log messages" report provided by dblog [is now a configurable view](https://www.drupal.org/node/2015149).
  [Change record](https://www.drupal.org/node/2850115)
* Useful meta information about a node's status that was formerly only
  available in the Seven theme [now originates from node.module](https://www.drupal.org/node/2803875)
  so other administration themes can access it.
* [RTBC] The _Administer users_ permission [no longer includes](https://www.drupal.org/node/2846365) the ability to
  grant user roles in bulk operations. Only users with the _Administer roles_
  permission can grant user roles. [Change record](https://www.drupal.org/node/2853612)

## REST and API-first improvements

* Authenticated REST API performance increased by 15% by
  [utilizing the Dynamic Page Cache](https://www.drupal.org/node/2827797).
* POSTing entities [can now happen at `/node`, `/taxonomy/term` and so on](https://www.drupal.org/node/2293697),
  instead of `/entity/node`, `/entity/taxonomy_term`. Instead of confusingly
  different URLs, they therefore now use the URLs you'd expect. Backwards
  compatibility is maintained. [Change record](https://www.drupal.org/node/2737401)
* Added dedicated resource for [resetting a user's password](https://www.drupal.org/node/2847708).
* Time fields now are [normalized to RFC3339 timestamps by default](https://www.drupal.org/node/2768651), fixing time
  time ambiguity. Existing sites continue to receive UNIX timestamps, but can
  opt in. [Change record](https://www.drupal.org/node/2859657)
* [Path alias fields now are normalized too](https://www.drupal.org/node/2846554).
  [Change record](https://www.drupal.org/node/2856220)
* When denormalization fails, a [422 response is now returned](https://www.drupal.org/node/2827084)
  instead of 400, per the HTTP specification. [Change record](https://www.drupal.org/node/2828773)
* With CORS enabled to allow origins besides the site's own host,
  [submitting forms was broken](https://www.drupal.org/node/2853201) unless
  the site's own host was also explicitly allowed.
* Fatal errors and exceptions [now show a backtrace](https://www.drupal.org/node/2853300)
  also for all non-HTML requests, which makes for far easier debugging and
  better bug reports. [Change record](https://www.drupal.org/node/2856738)
* Massive expansion of test coverage.

## Performance and scalability improvements

* The internal page cache now [has a dedicated cache bin](https://www.drupal.org/node/2889603)
  distinct from the rest of the render cache. [Change record](https://www.drupal.org/node/2896679)
* The service collector [no longer loads all dependencies](https://www.drupal.org/node/2472337);
  instead, the new service ID collector allows instances of dependencies to
  be lazily created. [Change record](https://www.drupal.org/node/2598944)
* The maximum time in-progress forms are cached [is now customizable](https://www.drupal.org/node/1286154)
  rather than being limited to a default cache lifetime of 6 hours.
  [Change record](https://www.drupal.org/node/2886836)
* If there are no status messages to be rendered, the corresponding Twig
  template [is no longer loaded](https://www.drupal.org/node/2853509) on every
  page.
* [Optimized the early Drupal installer](https://www.drupal.org/node/2872611)
  to check whether any themes are installed first before invoking an
  unnecessary function.

## Developer experience improvements

* [Adopted Airbnb JavaScript style guide 14.1] as the new baseline set of
  coding standards for Drupal core and contributed modules.
  [Change record](https://www.drupal.org/node/2873849)
* Field type definitions can now [enforce the cardinality of the field](https://www.drupal.org/node/2403703).
  [Change record](https://www.drupal.org/node/2869873)
* [Added new methods](https://www.drupal.org/node/2869809) to make getting
  typed configuration entity representations is now easier.
  [Change record](https://www.drupal.org/node/2877282)
* The `html_tag` render element now [supports nested render arrays](https://www.drupal.org/node/2694535),
  enabling the creation of dynamic SVGs. [Change record](https://www.drupal.org/node/2887146)
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
  be thrown. [Change record](https://www.drupal.org/node/2811561)
* [RTBC] In preparation for [JavascriptTests with webDriver](https://www.drupal.org/node/2775653),
  methods to test status code and response headers [are now disabled](https://www.drupal.org/node/2827014).
  [Change record](https://www.drupal.org/node/2857562)
* [Resolved random test failures](https://www.drupal.org/node/2866056) due to
  ResourceTestBase's HTTP client timeout of 30 seconds.

## Third-party library updates

* [Drupal's Symfony dependency has been updated from Symfony 2.8 to Symfony
  3.2](https://www.drupal.org/node/2712647). This major version update is
  necessary because Symfony 2.8 support will end around the release of Drupal
  8.6.0 next year. [See the change record for information about Symfony 3 BC
  breaks that affected Drupal core](https://www.drupal.org/node/2743809).
  [Drupal 8 also requires Symfony 3.2.8](https://www.drupal.org/node/2871253)
  because of a bug in Symfony 3.2.7.
* [zendframework/zend-diactoros has been updated from 1.3.10 to 1.4.0](https://www.drupal.org/node/2874817).
* [jQuery UI has been updated from 1.11.4 to 1.12.1](https://www.drupal.org/node/2809427).
* [CKEditor has been updated from 4.6.2 to 4.7.1](https://www.drupal.org/node/2893566).
* [asm89/stack-cors has been updated from 1.0 to 1.1](https://www.drupal.org/node/2853201).

## Experimental modules

(Move sections up to "new stable modules" if they become stable.)

### Migrate, Migrate Drupal, and Migrate Drupal UI

* [Added field plugin](https://www.drupal.org/node/2814949) to handle
  migration of node reference field values from Drupal 6 to Drupal 8.
* [Added date field plugin](https://www.drupal.org/node/2566779) to handle
  migration of CCK date fields in Drupal 6 to Drupal 8.
* [Renamed migration field plugins and classes](https://www.drupal.org/node/2683435)
  referring to custom fields provided by the Drupal 6 module CCK, which was
  replaced in Drupal 7 by the core Field API. [Change record](https://www.drupal.org/node/2751897)
* [Renamed `migration` process plugin to `migration_lookup`](https://www.drupal.org/node/2845486)
  to better capture its purpose. [Change record](https://www.drupal.org/node/2861226)
* [Renamed `iterator` process plugin to `sub_process`](https://www.drupal.org/node/2845483)
  to better capture its purpose. [Change record](https://www.drupal.org/node/2880427)

### Workflows and Content Moderation

* [Added entity type checkboxes to the workflow form](https://www.drupal.org/node/2843083)
  to select revisionable content types for Content Moderation.
  [Change record](https://www.drupal.org/node/2875643)
* Workflow types can now [lock certain changes to workflows](https://www.drupal.org/node/2830740)
  once states and workflows are in use.
* Workflow type plugins are now [responsible for state and transition schema](https://www.drupal.org/node/2849827).
  [Change record](https://www.drupal.org/node/2897706)
* [Replaced all instances of "forward revision" with "pending revision"](https://www.drupal.org/node/2890364)
  to improve developer and user experience.
* Where necessary, code in the Content Moderation module that should not be
  accessed or extended beyond core is now
  [marked with `@internal`](https://www.drupal.org/node/2876419).
* [Renamed editorial workflow label from "Editorial workflow" to "Editorial"](https://www.drupal.org/node/2894499)
  to improve developer experience while building user interfaces.

### Field Layout

* Minor bug fixes from 8.3.x to 8.4.x.

### Settings Tray

* [Added a CSS reset to the Settings Tray](https://www.drupal.org/node/2826722) to improve the user experience.
* [Form validation messages now appear in the Settings Tray instead of main page](https://www.drupal.org/node/2785047).
* [Changed the toolbar background to blue when in Edit mode](https://www.drupal.org/node/2894427).
* [Hid Title input unless it is displayed and changed label to Block Title](https://www.drupal.org/node/2882729).
* Off-canvas tray [now opens with default width instead of previous unclosed state](https://www.drupal.org/node/2828912).
* ["Quick edit" is now listed before "Configure" in contextual links while in Edit mode](https://www.drupal.org/node/2784567).
* ["Quick edit" links for custom blocks are now differentiated as "Quick edit settings"](https://www.drupal.org/node/2786193).
* [Edit mode now behaves the same way whether accessed by clicking "quick edit" or clicking through the toolbar](https://www.drupal.org/node/2847664)
* [Added escape from Edit mode with ESC key](https://www.drupal.org/node/2784571) to improve accessibility.

### Place Block

* [Marked as hidden](https://www.drupal.org/node/2898267).
* Minor bug fix.
