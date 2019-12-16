namespace :report do
  desc 'Output work ids for a specified batch import'
  task :report_work_ids_by_batch_id, [:batchid] => :environment do |t,args|
     if args.count < 1
        puts 'Usage: bundle exec rake report:report_work_ids_by_batch_id[<batchid>]'
        exit
     end
     batchid = args[:batchid]

     puts "fetching work ids from batch id #{batchid}"
     report_workids_service = ReportWorkidsService.new
     samvera_work_ids = report_workids_service.by_batch_id(batchid)
     puts "#{samvera_work_ids.join(',')}"
  end
end
