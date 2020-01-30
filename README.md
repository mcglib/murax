# README

[![pipeline status](https://gitlab.ncs.mcgill.ca/lts/murax/badges/master/pipeline.svg)](https://gitlab.ncs.mcgill.ca/lts/murax/commits/master)

Hyrax based system underlying the Carolina Digital Repository
Currently using Hyrax version 2.5.1
Currently in production
Hosts institutional repository content at UNC Chapel Hill
Customizations
Automatically assign AdminSet based on work type
Custom workflows:
New withdrawn state for works
Honors thesis workflow automatically assigns departmental group as reviewer for deposited works
Updated deposit/edit form with combined files and metadata tabs
Import scripts for new ProQuest deposits
Merges old and new analytics data from Google Analytics
Contact Information
Email: cdr@unc.edu




Hyrax Version
v2.5.0
[changelog](https://github.com/samvera/hyrax/releases/tag/v2.5.0)


Docker Configuration 

Fedora path:
http://132.206.197.166:8888/fcrepo/rest/

Adminer ( TO see database )
http://132.206.197.166:8090
Connection info:
DB: Postgres
server: Postgres.docker.local
username: murax
password: <see the .env file>


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

