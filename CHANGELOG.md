# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.7.1] - 2019-07-25
### Changed
- Merging changes from develop

## [1.0.7] - 2019-07-25
### Added
- Added open3 gem 
- Integrated python scripts from Clara
- Added reports.py
- Added new PAPER work type as mentioned in ADIR-428
- Added open3
- added a new worktype PRESENTATION as mentioned in ADIR-429
- Added a method to show for work item type alreay selected
- Added Clara's bioReport py script
- Added python libs
- Added a new worktype BOOK as mentioned in ADIR-427

### Changed
- changed the langauge and date fields
- Created the workptype Report
- fixed relation error
- checked the license issue
- changed some config for license
- license fixed
- changing help text for date in all worktype local/config files as it was mistyped by stakeholders
- Modified item type property
- changed multiple and single properties back
- more requested changes to report worktype
- changed work type report one more time.
- removed the brwose everything as requested in the ticket ADIR-390
- some ui changes
- updated bioreport py file
- UI help text updated according to ADIR-420
- Updated the deploy command for sidekiq
- Updated the docker file to install python packages via pip to run Clara's script
- Removing worktypes IMAGE and POSTER
- Changed the proprty fields as requested again in ADIR-426
- Changed the proprty fields as requested again in ADIR-433
- Cleanup code for cleanup services
- Updated the generic report script
- removed the work type WORK
- tried reordering of work types
- ADIR-425: Intergrated the python scripts. Added env variable for PYTHON_BIN


## [1.0.6] - 2019-05-15
### Changed
- Fixing bugs with the deploy script

## [1.0.5] - 2019-05-08
### Added
- Upgraded to v2.5.0 of hyrax
- New UI for the homepage
- Added  OAI-PMH gem
- Added Rake tasks to import digitool items.
- Implemented the thesis and article work-type
- Updated the facets according to specs requested.
- Updated the thesis worktype form and view page

### Changed
- Modified basic metadata file to overwrite default file
- Upgrade various gems

## [1.0.4] - 2019-02-23
### Added
- Upgraded to versions 2.4.1 of hyrax
- Create a batch process to generate the digitool collections
### Changed
- Updated various gems and added others

## [1.0.3] - 2018-10-23
### Added
- Added rake taks to automate the role creation.  

## [1.0.2] - 2018-10-23
### Added
- Added the right env files
- Configured to work with external servers for db, solr and fedora

## [1.0.0] - 2018-10-12
### Added
- Initial release of mura. preceded by nurax
- updated the Gemfile.locka
### Changed
