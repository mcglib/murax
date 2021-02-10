require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Reindex work(s) by specified id(s)'
  task :reindex_works_by_workid, [:workid] => :environment do |task, args|
    workid = args[:workid]
    wkids = args.extras
    wkids << workid
    if wkids.empty? or workid.empty?
      puts "Usage: bundle exec rake murax:reindex_works_by_workid[workid[,workid...]]"
      puts "       reindexes specified works"
      exit
    end
    index_works(wkids)
    exit
  end

  def index_works(wkids)
   begin
     reindex_service=IndexAnObject.new
     start_time = Time.now.strftime('%Y%m%d%H%M%S')
     logger = ActiveSupport::Logger.new("log/reindex-works-#{start_time}.log")
     logger.info "Task started at #{start_time}"
     logger.info "reindexing work ids:"
     success = 0
     errors = 0
     wkids.each do |work_id|
       reindex_service.by_object_id(work_id)
       if reindex_service.get_status()
         success+=1
         logger.info work_id
       else
         errors+=1
         logger.error "Can't update index for #{work_id}"
       end
     end
     logger.info "#{wkids.length} works processed"
     logger.info "#{success} works successfully reindexed"
     logger.info "#{errors} works failed to reindex"
     end_time = Time.now.strftime('%Y%m%d%H%M%S')
     logger.info "job ended at #{end_time}"
   rescue StandardError => e
     puts e.message
     logger.error e.message
   end
  end
end
