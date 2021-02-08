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
     indexer=IndexAWork.new
     start_time = Time.now.strftime('%Y%m%d%H%M%S')
     logger = ActiveSupport::Logger.new("log/reindex-works-#{start_time}.log")
     logger.info "Task started at #{start_time}"
     logger.info "reindexing work ids:"
     success = 0
     errors = 0
     wkids.each do |work_id|
       #work = ActiveFedora::Base.find(work_id)
       #raise StandardError.new("Unable to locate work id: #{work_id}") if work.nil?
       indexer.by_work_id(work_id)
       if indexer.get_status()
         logger.info work_id
       else
         logger.error "Can't update index for #{work_id}"
       end
     end
     end_time = Time.now.strftime('%Y%m%d%H%M%S')
     job_time=end_time.to_i-start_time.to_i
     logger.info "job ended at #{end_time} (#{job_time.to_s} secs)"
   rescue StandardError => e
     puts e.message
     logger.error e.message
   end
  end
end
