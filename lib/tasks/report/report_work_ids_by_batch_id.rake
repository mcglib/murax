namespace :report do
  require 'tasks/report/services/report_service'

  desc 'Output work ids for a specified batch import'
  task :report_work_ids_by_batch_id, [:batchid] => :environment do |t,args|
     if args.count < 1
        puts 'Usage: bundle exec rake report:report_work_ids_by_batch_id[<batchid>]'
        exit
     end
     batchid = args[:batchid]

     puts "fetching work ids from batch id #{batchid}"
     report_service = Report::Services::ReportService.new(batchid: batchid)
     samvera_work_ids = report_service.get_work_ids_by_batch_id
     puts "#{samvera_work_ids.join(',')}"
  end
end
