# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.1] - 2016-11-05

### Changed
 - Significantly reduced the size of assets in order to improve load times ([#152], [#156]).

### Fixed
 - Fixed modals not showing up after The Great JS CDN Migration.
 - Content in dropdowns now gets properly scoped to a universe scope.
 - Fixed a handful of style bugs around the site from the new design.
 - Styled markdown fields so markdown lists are visible ([#154]).
 - Fixed bugs in quick-adding and custom fields not saving/showing ([#159]).

## [2.0.0] - Content Expansion Release - 2016-11-01

### Added
 - Seven new types of content:
   - Creatures
   - Races
   - Religions
   - Groups
   - Magic
   - Languages
   - Scenes
 - Custom attributes: Create new tabs and fields for any content type ([#108]).
 - All fields now support [Markdown] formatting. See [this guide on Markdown]
   to learn how to use it.

### Changed
 - Promotional Eternal accounts. Now priced at $9 USD per month,
   and provides unlimited universes, and all new content types,
   for $9 USD per month.
 - Significant server upgrades to improve the experience
   and make sure Notebook is always available

### Fixed
 - Mobile browsing has had some of the rough edges taken off.

Read the [announcement][announcement-2.0.0] of this release on Medium.

## [1.2.0] - 2016-10-05

### Added
 - Additional fields to Locations: laws, climate, founding story, and sports.
 - A "Nature" tab to Characters containing new fields,
   and moved the "Fave" tab fields under "Social".
 - A "Rules" tab to Universes containing fields for detailing magic systems,
   laws of physics, and technologies.

### Fixed
 - A bug that prevented the "Hairstyle" field from saving on Characters.
 - A bug that prevented the "Language" field from saving on Locations.

## [1.1.0] - 2016-10-04

### Added
 - You can now download Notebook contents in JSON, TXT, or CSV.

## [1.0.0] - Public Release - 2016-10-01

### Added
 - Characters, Items, and Locations
 - Content sharing
 - Free Eternal accounts throughout the month of October.

Read the [announcement][announcement-1.0.0] of our public release on Medium.

[Markdown]: https://en.wikipedia.org/wiki/Markdown
[this guide on Markdown]: https://guides.github.com/features/mastering-markdown/

[Unreleased]: https://github.com/indentlabs/notebook/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/indentlabs/notebook/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/indentlabs/notebook/compare/v0.2.0...v2.0.0
[1.2.0]: https://github.com/indentlabs/notebook/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/indentlabs/notebook/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/indentlabs/notebook/tree/v1.0.0

[announcement-1.0.0]: https://medium.com/indent-labs/introducing-notebook-ai-f06d8d3d8e77
[announcement-2.0.0]: https://medium.com/indent-labs/the-next-version-of-notebook-ai-is-here-62470d0bda19

[#108]: https://github.com/indentlabs/notebook/pull/108
[#152]: https://github.com/indentlabs/notebook/pull/152
[#154]: https://github.com/indentlabs/notebook/issues/154
[#156]: https://github.com/indentlabs/notebook/pull/156
[#159]: https://github.com/indentlabs/notebook/issues/159
