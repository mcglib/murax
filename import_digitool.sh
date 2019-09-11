#!/bin/bash
# example of using arguments to a script
home_dir="/storage/www/murax/current"
csv_file_path="spec/fixtures/digitool/pids/$1-pids.csv"
download_url="http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/theses-by-pids-for-hyrax.php"
d=`date +%m-%d-%Y-%H%M%S`
exec_command="env RAILS_ENV=production bundle exec rake migration:bulk_import_csv[$csv_file_path,5,0]"

echo "Digitool collection code is $1"
cd $home_dir

echo "Total number of arguments is $#"

echo "Downloading the collection data"
echo "wget -O $csv_file_path $download_url?col=$1"
wget -O $csv_file_path $download_url?col=$1

echo $exec_command $d
echo "Executing the command: nohup $exec_command --trace > log/rake_$d.out 2>&1 &"
#nohup $COMMAND --trace > log/rake_20190909.out 2>&1 &
