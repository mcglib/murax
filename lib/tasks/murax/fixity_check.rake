require 'active_record'
require 'optparse'
namespace :murax do
  #bundle exec rake murax:fixity_check
  desc 'Fixity check'
  task :fixity_check => :environment do
    #return `ARGV` with the intended arguments
    Hyrax::RepositoryFixityCheckService.fixity_check_everything
    exit
  end
end

