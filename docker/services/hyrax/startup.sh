#!/bin/bash

set -e
# Exit on fail

echo "Starting sidekiq service"

cd ${APP_PATH}
RAILS_ENV=${RAILS_ENV} bundle exec sidekiq -d -L ${APP_PATH}/log/sidekiq.log
# Finally call command issued to the docker service
# This is only for the Web container.
echo "Checking that the db is up already!"
#sh ./wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT} -t 30 --strict -- echo "Database is up!"
waitforit -address=tcp://${DATABASE_HOST}:${DATABASE_PORT} -timeout=30 -debug -- printf "The Database is up!"
export  PGPASSWORD=${DATABASE_PASSWORD}

echo "Sleeping for 10 seconds and then confirming that the db has booted"
sleep 10
waitforit -address=tcp://${DATABASE_HOST}:${DATABASE_PORT} -timeout=30 -debug -- printf "The Database is up!"
export  PGPASSWORD=${DATABASE_PASSWORD}

echo "Run yarn install so that we can make sure we can compile assets"
yarn install

echo "Checking if the database has been initialized"
echo "bundle exec rake db:exists RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt"
bundle exec rake db:exists RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt


if grep -q "false" /tmp/stderr.txt; then
  echo "Initializing database..."
  echo "-------------------------"
  echo "bundle exec rake db:clean RAILS_ENV=${RAILS_ENV}"
  bundle exec rake db:clean RAILS_ENV=${RAILS_ENV}

  echo "Running any migrations first to be sure we are upto date"
  echo "bundle exec rake db:migrate  RAILS_ENV=${RAILS_ENV}"
  bundle exec rails db:migrate  RAILS_ENV=${RAILS_ENV}

  echo "Clean out an Fedora items if needed "
  bundle exec rake murax:fedora_clean RAILS_ENV=${RAILS_ENV}
  
  echo "Create the default collection types"
  bundle exec rake hyrax:default_collection_types:create RAILS_ENV=${RAILS_ENV}
  
  echo "Initializing the default admin set and roles..."
  echo "bundle exec rake hyrax:default_admin_set:create RAILS_ENV=${RAILS_ENV}"
  bundle exec rake hyrax:default_admin_set:create RAILS_ENV=${RAILS_ENV}

  echo "Initializing the default digitool collections"
  echo "bundle exec rake murax:create_digitool_collections RAILS_ENV=${RAILS_ENV}"
  bundle exec rake murax:create_digitool_collections RAILS_ENV=${RAILS_ENV}
  
  echo "Seed the database with some default roles"
  bundle exec rake murax:create_default_roles RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt
  
  echo "Create the default admin user"
  bundle exec rake murax:create_default_admin_user -- -n ${ADMIN_USERNAME}  -p ${ADMIN_PASSWORD} -e ${ADMIN_EMAIL} RAILS_ENV=${RAILS_ENV}

else
  echo "Database tables exists. Not initializing."
  
  echo "Running any migrations first to be sure we are upto date"
  echo "bundle exec rails db:migrate  RAILS_ENV=${RAILS_ENV}"
  bundle exec rails db:migrate  RAILS_ENV=${RAILS_ENV}
fi
echo "------END OF DB SETUP-------------------"

#echo "Running any migrations first to be sure we are upto date"
#echo "bundle exec rake db:migrate  RAILS_ENV=${RAILS_ENV}"
#bundle exec rake db:migrate  RAILS_ENV=${RAILS_ENV}

rm /tmp/stderr.txt

#cd /root/Backup && bundle exec backup perform -t filebackup,databasebackup
echo "Writing out the crontask from whenever gem"
whenever -w

echo "Set the writing permissions on the ${UPLOAD_PATH}  and ${WORKING_PATH}"
chmod a+rwx -R ${UPLOAD_PATH}
chmod a+rwx -R ${WORKING_PATH}

echo "Set the writing permissions on the ${DERIVATIVES_PATH} folder"
mkdir -p ${DERIVATIVES_PATH}
chmod a+rwx -R ${DERIVATIVES_PATH}

echo "Set the writing permissions on ${TMP_PATH} folder"
mkdir -p ${TMP_PATH}
chmod a+rwx -R ${TMP_PATH}


echo "Starting the cron service"
cron
cd ${APP_PATH}


rm -rf ${APP_PATH}/tmp/pids/server.pid

echo "Precompiling the rake assets with ${RAILS_ENV}"
RAILS_ENV=${RAILS_ENV} bundle exec rake assets:precompile

echo "Copy the assets file for 404 and 505 in ${RAILS_ENV}"
cd ${APP_PATH}
#cp ${APP_PATH}/public/assets/404-*.html ${APP_PATH}/public/404.html
#cp ${APP_PATH}/public/assets/500-*.html ${APP_PATH}/public/500.html
echo "Starting the server on ${RAILS_ENV}"
RAILS_ENV=${RAILS_ENV} bundle exec rails s -p 3000 -b '0.0.0.0'
