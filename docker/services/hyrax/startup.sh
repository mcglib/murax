#!/bin/bash

set -e
# Exit on fail

echo "Starting sidekiq service"

bundle exec sidekiq -d -L ${APP_PATH}/sidekiq.log
# Finally call command issued to the docker service
#!/bin/bash
# This is only for the Web container.
echo "Checking that the db is up already!"
#sh ./wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT} -t 30 --strict -- echo "Database is up!"
waitforit -address=tcp://${DATABASE_HOST}:${DATABASE_PORT} -timeout=30 -debug -- printf "The Database is up!"
export  PGPASSWORD=${DATABASE_PASSWORD}

echo "Sleeping for 10 seconds and then confirming that the db has booted"
sleep 10
waitforit -address=tcp://${DATABASE_HOST}:${DATABASE_PORT} -timeout=30 -debug -- printf "The Database is up!"
export  PGPASSWORD=${DATABASE_PASSWORD}

echo "Checking if the database has been initialized"
echo "bundle exec rake db:exists RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt"
bundle exec rake db:exists RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt


if grep -q "false" /tmp/stderr.txt; then
  echo "Initializing database..."
  echo "-------------------------"
  echo "bundle exec rake db:clean RAILS_ENV=${RAILS_ENV}"
  bundle exec rake db:clean RAILS_ENV=${RAILS_ENV}

else
  echo "Database tables exists. Not initializing."
fi

echo "Running any migrations first to be sure we are upto date"
echo "bundle exec rake db:migrate  RAILS_ENV=${RAILS_ENV}"
bundle exec rake db:migrate  RAILS_ENV=${RAILS_ENV}
echo "------END OF DB SETUP-------------------"

echo "Clean out an Fedora items if needed "
bundle exec rake murax:fedora_clean RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt

echo "Create the default collection types"
bundle exec rake hyrax:default_collection_types:create RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt

echo "Create the default admin set"
bundle exec rake hyrax:default_admin_set:create RAILS_ENV=${RAILS_ENV} > /tmp/stderr.txt


#    before "deploy:migrate", "deploy:clear_fedora"
#    after "deploy:migrate", "deploy:create_collections"
#    after "deploy:migrate", "deploy:create_admin_set"
 #   after "deploy:migrate", "db:seed"
 #   invoke "deploy"


rm /tmp/stderr.txt

#cd /root/Backup && bundle exec backup perform -t filebackup,databasebackup
echo "Writing out the crontask from whenever gem"
whenever -w

echo "Starting the cron service"
cron
cd /usr/src/app

