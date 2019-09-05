namespace :murax do
  #bundle exec rake murax:fixity_check
  desc 'Fixity check'
  task :fixity_check => :environment do
    #return `ARGV` with the intended arguments
    Rails.logger.warn "Running Hyrax::RepositoryFixityCheckService.fixity_check_everything"
    Hyrax::RepositoryFixityCheckService.fixity_check_everything
  end
end

