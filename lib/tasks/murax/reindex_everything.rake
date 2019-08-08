require 'active_fedora'
namespace :murax do 
  desc 'Reindexes all objects'
  task reindex: :environment do
    puts "Starting the reindex now ..."
    Rails.logger.info "Running it 1st time .."
    ActiveFedora::Base.reindex_everything
    puts "Running it second time to make sure all the objects have been reindexed. "
    Rails.logger.info "Running second time.."
    ActiveFedora::Base.reindex_everything
  end
end
