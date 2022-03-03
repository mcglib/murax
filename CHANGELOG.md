# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
# [1.3.7] - 2022-03-03
* Changed the loglevel on Prod. ADIR-1202

# [1.3.6] - 2022-01-20
* Updated the banner image. ADIR-1184

# [1.3.5] - 2021-11-23
* Updated: Help text for Faculty and Department properties. 

# [1.3.4] - 2021-11-23
* Updated: Local affiliated centre and research unit properties now also act as facets. 

# [1.3.3] - 2021-11-12
### Changed
* Added Alternative title to Thesis worktype.
* Updated Alternative title property to be searchable.

# [1.3.2] - 2021-11-11
### Changed
* Downgrade to rails 5.2.4.3


# [1.3.1] - 2021-11-11
### Changed
* Fixing the Gemfile

# [1.3.0] - 2021-11-10
### Changed
* Upgraded to version 2.6.8 of ruby
* Updated several rails gems including upgrade to rails 5.2.4.6
* Rebuilt the dockerfile to use an CentOS docker image
* Updated the package.json file
* Updated various gems and nodejs modules
* Downgraded set-value to 3.0.2
* Removing references to proxies

# [1.2.27] - 2021-09-29
### Added
* Added a link to change user's password in dashboard profile.
* Updated password mailer to have change password link in the email template.

# [1.2.26] - 2021-08-27
### Changed
* Changed the additional fields order for Article work-type form. 

# [1.2.25] - 2021-08-26
### Added
* no-indexing of the site on dev and qa servers.

# [1.2.24] - 2021-08-09
### Changed
* Ugraded mimemagic and various nodes.js

# [1.2.23] - 2021-07-07
### Changed
* License property is now visible in all worktypes.

# [1.2.22] - 2021-06-22
### Changed
* Changed the user dev.library to dev.library@mcgill.ca

# [1.2.21] - 2021-05-03
### Changed
* Started using show method from Hyrax::WorksControllerBehavior instead of Murax::WorksControllerBechaviour to fix the GoogleSearchConsole errore.

# [1.2.20] - 2021-04-16
### Added
* New rake task to reindex recently added works

# [1.2.19] - 2021-03-23
### Added
* Added new response formats for json and js to error_controller
# [1.2.18] - 2021-02-22
### Added
* New rake task murax:change_user_password[user.email]

# [1.2.17] - 2021-02-10
### Added
* New rake task murax:reindex_works_by_workid[id,id,id...]
* reindex_works_by_workid task now uses IndexAWork service
* Updated sitemap
* tidy up reindex_works_by_workid rake task
*renamed IndexAWork to IndexAnObject
* better log reporting for reindex_works_by_workid task

# [1.2.16] - 2021-02-04
### Changed
* Upgraded yarn.lock packages

# [1.2.15] - 2021-02-04
### Changed
* Upgraded nokogiri and puma gems

# [1.2.14] - 2021-02-03
### Changed
* Fixed bug with the routes for /en on languages where generating 404s

# [1.2.13] - 2021-01-18
### Changed
* Disabled fixity check on whenever scheduler

# [1.2.12] - 2020-12-21
### Changed
* app/indexers/ indexers for all work types now include extracted text from representative media file as custom field in solr_doc 

# [1.2.11] - 2020-09-29
### Added
* New rake task report:report_filesize_by_workid['representative_media-or-other, fileformat, fileaccessibility, workid']
* New rake task report:report_total_filesize_by_collectionid['representative_media-or-other, fileformat, fileaccessibility, collectionid']
* New service to report filesize for specified file id
### Changed
* rake task murax:export_metadata_records_as_xml now correctly encodes entities

# [1.2.10] - 2020-09-04
### Changed
* murax:build_csv_with_specific_fields_by_search_criteria now handles nil attributes

# [1.2.9] - 2020-08-24
### Added
* New rake task murax:build_csv_with_specific_fields_by_search_criteria['search-term','search-field','output-field1 output-field2 ...']

# [1.2.8] - 2020-07-23
### Changed
* Updated rails to v5.2.4.3.

# [1.2.7] - 2020-07-07
### Changed
* Upgraded to v2.8.0 of hyrax
* Upgraded Active-Fedora to v12.1.1

# [1.2.6] - 2020-07-07
### Changed
* Added the Orcid ID field to display on the rows
* Made the identifier visible on report work type

# [1.2.5] - 2020-06-10
### Changed
* Added a sitemap generator gem along with configuration in config/sitemap.rb

# [1.2.4] - 2020-06-03
### Changed
* Upgraded to v2.7.2 of hyrax

## [1.2.3] - 2020-04-14
### Changed
* Upgraded to v2.7.1 of hyrax
* Added a rake task to change the depositor of a given set of works

## [1.2.2] - 2020-04-08
### Changed
* Added a is-live env variable

## [1.2.1] - 2020-04-01
### Changed
* Enabled advanced search (beta)

## [1.1.27] - 2020-03-26
### Changed
* Removed no-follow, no-index so Google can crawl

## [1.1.26] - 2020-03-19
### Changed
* Upgraded to v2.7.0 of hyrax
* Upgraded to v3.12.4 of puma

## [released]
## [1.1.25] - 2020-03-12
### Changed
* Enabled department, language and degree to be searchable
* Disabled the abstract from showing in the index results

## [1.1.24] - 2020-03-10
### Changed
* Enabled department, language and degree to be searchable
* Disabled the abstract from showing in the index results

## [1.1.23] - 2020-03-10
### Changed
* Disabled the advanced search link on the top of page

## [1.1.22] - 2020-03-09
### Changed
* Update metadata field service: report that creator field is not yet supported
* Updated the readme
* OAI: suppress etdms output for non-thesis records
* GPSO import: embargo files with student nos in embedded file metadata during import
* Changed ENV to development for apache+passenger on the docker containers
* Added FAQ items for the Homepage

## [1.1.21] - 2020-03-04
### Changed
* Updated the classiq controller
* Fixing the search controller
* minor tweaks to docker-compose file
* Added the degree, department and faculty to advanced search
* Disabled nested creator from the advanced search
* added a new task that adds the role to collections
* added ENV variable for admin user

## [1.1.20] - 2020-02-25
### Changed
* Changing the core search engine functionality
## [1.1.9] - 2020-02-18
### Changed
* Upgraded to v2.6.0 of hyrax
* Updates to the murax architecture
## [1.1.8] - 2020-02-11
### Changed
* Added a murax architecture svg file
## [1.1.7] - 2020-02-11
### Changed
* report_workids_service: documented behaviour of by_metadata_search; increased rows to 10000
* made changes to thesis and book worktype
* Fixed bug with docker container and apache

## [unreleased]
## [1.1.6] - 2020-02-04
### Changed
* report_workids_service: documented behaviour of by_metadata_search; increased rows to 10000
* report_workids_service: renamed parameter of by_metadata_search from pattern to search_value for sake of clarity
* Bump fstream from 1.0.11 to 1.0.12
* Bump lodash.template from 4.4.0 to 4.5.0
* Added murax-architecture.svg
* Bump mixin-deep from 1.3.1 to 1.3.2

## [1.1.5] - 2020-02-03
### Changed
* Added code for footer
* Updated the google analytics code
* Added google analytics for the launch
* Code cleanup

## [1.1.4] - 2020-02-03
### Changed
* Fixed a bug with the
* Updated the README with info re: customizations to the abstract language tagging
* Updated the README and the license info
* Fixing the language field for all works.

## [1.1.3] - 2020-01-30
### Changed
* Removed Pronto from the Gemfile.lock file

## [1.1.2] - 2020-01-16
### Changed
* removed subject and identifier as required properties in ethesis profile form
* fixed the bug with the whitespace on annoucmenet on home page
* renamed the file to murax_homepage
* renamed the file
* made it fancy for the boss
* added muraxs directory namespace in stylesheets

## [1.1.1] - 2019-12-11
### Changed
* Added a condition that checks if the presenter is an edrtor we can hide the user activity
* Added check so that a user must add a file before submitting a new work
## [1.1.0] - 2019-12-06
### Changed
* Added nofollow, noindex for preventing google searching and crawling
## [Unreleased]
## [1.0.43] - 2019-11-27
### Changed
* Added a rake task to export digitool xml of a given set of workids or csvfile
## [1.0.42] - 2019-11-26
### Changed
* Clara fixed bug with the papers that had and extra field
## [1.0.41] - 2019-11-25
### Changed
* Fixed the bug with ETHESIS2 not importing. Added a check so that we can get the dctype of the xml to check for thesis.
## [1.0.40] - 2019-11-25
### Changed
* Updated the code to fetch pids from the second template
* Added the template 2 pids for ingest
* Renaming the thesis pid for ETHESIS2

## [1.0.39] - 2019-11-22
### Changed
* fixed the file manager internal server error
* hidden the share work button from the home page
* hiddent the signup button on login
* changed the log in heading to administrative login
* moved the terms of use button to the right bottom of home content page. moved from index
* Changed the verbage on login to login (staff only) and also changed the location of login button to footer of the home page.
## [1.0.38] - 2019-11-14
### Changed
* Minor changes to check thesis
* add details to batch report for errors
* Updated the code so that we can see the file that is being added to be checked
* Updated
* Added some methods to obfuscate the filename when its from GPSO
* Updated the controller so that we only target filenames from gpso
* Clean up code we do not need
* Fixed a bug introduced by the change of filenames
* Made the check_thesis more generic
* Renaming the task so its more generic
* Updated the code for the verification of the pids. Increased checking perfomance by 300%
* Udpated to newer version of bootstrap tables
* Updated so that the we hide the filename and just show the system file id
* Updated the file_set_presenter
* Upgraded the code so that we can have a summary of missing pids.
* Upgraded the code so that we can have a summary of missing pids.
* support for a few more unexpected dc:types

## [Unreleased]
## [1.0.37] - 2019-11-13
### Changed
* Added route to batches
* remvoed dev.library account from emails
* removed the helper method in rtype filed, making it default to an empty value unless selected by a user
* added rtype as faceted field
* Added a import worker
* Fixing the import form and added a job to run the import
* Added the import worker
* added the plumbing so that the worker jobs are added to sidekiq queue
* fixed issues with batch reports
* Revert "fixed issues with batch reports"

* Updated the code to run the pid processing
* Refactored the services to work for service import_record
* fixed problem with batch reporting
* identifier field now saved
* removed 'THESIS' entry from notes
* Added a rake task that will gives the information about how many objects in samvera have multiple abstracts with the same language
* Changed find_each to reduce the usage of memory, pluck will not work untill I pass 'all' option to it, and also it will get me only the fields and not the objects.
* Updated the code for importing via UI
* Final tweaks to digitool pid importer
* removed trailing byebug
* changed the logic
* added faculty and department to book worktype
* Updated code to show the full log
* Fixed bug with the presenters of the batches log
* Updated bug with the batch reports
* Fixing so as to speed up search
* Bug fixing
* Fixing a way to check for the thesis pids
* Updated the task to send some logging details
## [1.0.36.3] - 2019-11-06
### Changed
* Disabled code that checks for items that are embargoed.
## [1.0.36.2] - 2019-10-30
### Changed
* Fixing logic checking if fileset is present
## [1.0.36.1] - 2019-10-30
### Changed
* Fixed bug when the main fileset is empty for suppressed pids.
## [1.0.36] - 2019-10-21
### Changed
* stop capturing faculty and dept info for books
* Don't include 'McGill University' as a publisher for Papers (Presentations and Books already exclude McGill)
## [1.0.35] - 2019-10-15
### Changed
* Export samvera metadata as xml
* Revert "Export samvera metadata as xml"
   This reverts commit 402e10a6cdc4e3261c5ccc9d0378e5352ddecb5d.
* Samvera export metadata as xml task
* Samvera export metadata as xml task - tidy up stray comments
* tidied up comments in metadata export rake task
* Updated the time that fixity checks are run
* dc:source wasn't being imported for papers
* Added a view log modal window to the import logs
* Added the import log view and the log error modal
* Minor UI tweaks to the import logs
## [1.0.34] - 2019-10-15
### Changed
* Report objects can now be imported into Samvera collection id faculty-pubs
* Added support for Presentation work type in Research publications
* Added support for Papers in Samvera Research publications
* for thesis it should link to an item in view
* support for book objects
* Added a helper method to please the boss and it is working now.
* Fixing a bug with the email report
* Fixed a wrong regexp to clean up the urls
## [1.0.33] - 2019-10-15
### Changed
* Fixed bug with the thesis imports.
* Updated the code for printing out the log
* Changed the code for reading the localfilename so that it removes all whitespace from the url
* Hid the link to download the pdf for embargoed items
* changed to downcase
* Updated the display error log
## [1.0.32] - 2019-10-10
### Changed
* Improved the Ui for digitool imports
## [1.0.31] - 2019-10-08
### Changed
* Fixing email reports
## [1.0.30.2] - 2019-10-07
### Changed
* Fixed sidekiq jobs to 2 in PROD.
## [1.0.30.1] - 2019-10-04
### Changed
* File name issues
## [1.0.30] - 2019-10-04
### Changed
* Added ethesis pids for better tracking
* Adjusted the bulk import script so that we can do ethesis differently
## [1.0.29.2] - 2019-10-04
### Changed
* Fixed sidekiq jobs to 2 in PROD.
* Added host in subject of email sent after import
## [1.0.29.1] - 2019-10-04
### Changed
* Forgot to echo out the js code part :)
## [1.0.29] - 2019-10-04
### Changed
* Fixing a bug with interface for the dashboard of hyrax
## [1.0.28] - 2019-10-03
### Added
* Sorting and being able to export the logs
* Fixed bug with the turbolinks not loading the bootstrap tables
## [1.0.27] - 2019-10-03
### Changed
* Fixing the duration for the batches
* Visual change to the UI of the import_logs
## [1.0.26] - 2019-10-02
### Changed
* fixing batch ui
* fixing the rails ui for import logs
## [1.0.25] - 2019-10-02
### Changed
* revised facultypublications_functions.py filename part deux
* fixed collection ids for 'Research Publications' collection
* app/models/digitool/article_item.rb added bib citation and identifier elements
* fixed handling of faculty_pubs collection
* lib/tasks/migration_helper.rb - added 'post print' as type option
* Udpated
* support for importing embargoed files
* fixing batch ui
* Fixing names with python function
* Re-added the file
* Moved the config directives to the right locations
* File renaming issues
* File naming
* For ESHIP items import rights statements as is
* For ESHIP don't import 'McGill University' as Publisher
* Don't try to get an embargo date when processing waivers
## [1.0.24.2] - 2019-09-26
### Changed
* Fixed bug with wrong theses collection id in the config.yml in fixtures folder
## [1.0.24.1] - 2019-09-26
### Changed
* Making the UI for impot logger more responsive and added content for batches.
## [1.0.24] - 2019-09-26
### Changed
* Added bulk import work_ids to a collection
## [1.0.23] - 2019-09-25
### Changed
* Updated the import email preview file
* new entries in discipline_Dictionary.txt for ugrad and ugpapers
* added DEFAULT_DEPOSITOR_EMAIL to .env.test
* Added the import log controller files
* Added a rake task to process pids that did not get added to the theses collection
* Updated
* Updated the routes for the import log
* Added bootstrap tables
* Added the batches controller
* Finishing setting up the import_logs controller
## [1.0.22] - 2019-09-20
### Changed
* Fixin the error messages for 404, 422 and 500
* Updated the env variables
* Updated the code for import record
* Fixed the email report
* Added cc to the report
* Removed authoring software
## [1.0.21] - 2019-09-18
### Changed
## [1.0.20] - 2019-09-18
### Changed
* Added a method to check if the item is suppressed
* Fixed bug with name of file for suppressed items
* Added the import_digitool script
* Improved the digitool import bash script
* Improved the digitool import bash script
* Added command so that db migrate is run when we do a docker-compose up
* Added raw_xml field to import_logs
* Disabled adding date creation for thesis dates
* Added a raw_xml column in the import log so we can refer back after the import
* fixing the bash shell
* Added the batch model to the import_log and a model to do batch imports
* Fixed to the logic of main views and items that are of usage_type archive
* Added a test import mailer
* Added  a send error report

### Added
* New batch model to bulk imports
* New xml field to be added to the import_log model
## [1.0.19] - 2019-09-16
### Changed
* Added local collection code to the note field for report and paper
* Testing to see if we can use azure containers
* added new property date accepted to default metadata
* Updated the ci image for ruby
* Adding date accepted
* Added the g++ package for CI
* Fixed bug with import script fetching wrong metadata
* Removed debugging code
* Fixing ci
* Added representative id to the work. The main pid is the representative id
* Added a setup_chrome for CI testing
* Fixing a bug with getting metadata
## [1.0.18] - 2019-09-13
### Changed
* Hidden the citations fields in work show page according to the request in ADIR-490
* Fixed the date formats to be of XXXX instead for YYYY
* Changing the bundler version for gitlab
* Fixing the tags for azure
* Fixing the gitlab ci proccess
* Fixed the way we name the files
* Added en/fr prefixes
## [1.0.17] - 2019-09-12
### Changed
* changed the label for creator property
* removed the author order from form
* Fix bug with missing variable
* Removed duplicate thesis item

## [1.0.16] - 2019-09-11
### Changed
* Fixed bug with tmp files not being deleted
* Fixed missing fields for Report, Paper

## [1.0.14] - 2019-09-05
### Changed
* organized the order
* Changed to require instead of require_dependency
* create_user_assign_role rake task: use email as display name
* added faculty publication script
* fixing the ordered string helper
* removing whitespaces and disabling some functions
* Fixing the paper type
* Disabling orderedstringhelper
* Fixingthe capfile
* Added custom 404 and 500 error pages
* Working on author order
* fixed the author order
* Updated the services
* removed the byebug from files
* Updated the graduation year validator
* organized code
* Organized the code in models
* Updated the code for Paper type
* Fixing murax controllers
* updated the hints for newly nested_ordered_creator field
* added style for drag and drop of nested field
* Got the import of ordered creators working
* Enabled reload(sys) and utf-8 functionality

### Added
* added eship type dictionay
* added a filed author_order to all work-types
* fixed the author order for all work-types
* Added the OrderedStringHelper module to order the language and terms
* new rake task to create user by email and add to specified role


## [1.0.13] - 2019-08-27
### Changed
* Disabling temp to fix bug with parse on all branches
## [1.0.12] - 2019-08-26
### Changed
* Enabled utf-8 in thesis py script
* Adding a few items
* Adding a generic rake task to import a single digitool item
* hid the link to forgot to password
* created rake task to create user groups
* Updated the import record code
* added the new version of task
* fixed the code according to Jarvis's instructions
* Updated the code to import the Paper worktype
* Testing running GRADRES
* Moved the lists of pids to a separate dir
* Added a gitignore file to hide the  pyc compiled files
* Updated tge gitignore file
* Removing unused files
* Added a import record
* Changed the date function
* Added a service import record that takes the pid and does the rest
* updated status of permissions
* updated it again
* Added two services to add works to collections
* Added the import service
* Fixed namespace problem:
* Updated the development branch to disabled sidekiq settings
* Disabled user stats collection job in hyrax.
* Fixing the start date for google analytics
* Added a rake task to run fixity checks on the files
* Removed debugging code
* Fixin misplaces gitignore file
* Removing some debugging info
* Added a check for making sure the item can have an identifier if its a thesis
* added some function to give permission to casual_workers
* Added custom multi_value so we can have html5 support of dates and integers
* Added ovverides to the multi_value fields. Upadted the rights field property



## [1.0.11.2] - 2019-08-22
### Changed
* Added fix to get the rtype in the BREPR reports

## [1.0.11.1] - 2019-08-22
### Changed
* Added fix to get the rtype in the BREPR reports

## [1.0.11] - 2019-08-19
### Changed
* Added fix to get the publisher in the BREPR reports

## [1.0.10] - 2019-08-17
### Changed
* Fixed rtype view 
* Added helpers for the worktypes

## [1.0.9.1] - 2019-08-16
### Changed
* Fixing bug with adding works to a collection
* Added extent field to ingest of works of the Report type

## [1.0.9] - 2019-08-15
* Updated the code for Digitool import of reports

## [1.0.8] - 2019-08-12
### Changed
* Updated the fixity check
* Updated the code for Digitool import
* Changed identifier Script
* updated few gem
* updated hyrax 2.5.0 to 2.5.1 to fix the security bug
* Updated the browse everything provider
* Updated the code for the rake task
* added the thesis script
* Updated the features
* Removed the error file from script and renamed the functions file
* Cahnged Relation Field
* Updated to run bioresource reports
* Updated the config file


### Added
* Added a separate task for creating default admin user
* aaded a user group
* added new user group settings
* added a new file
* Created the rake task to automate the reindexing
 ADded checks for collection mappings
* added report number to solr doc
* added all properties to solr document, initially they were skpipped thinking that only the new properties are needed there and not the ones that come with hyrax by default, apprently that approach is not right
* made a change to article form
* Enabled utf-8 on the GenericReports.py file
* Changed language function to remove trailing spaces and newlines
* Added the bioresource pids
* updated language field
* Adding the reports pid list
* Updating the identifier field
* Added language to solr doc


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
