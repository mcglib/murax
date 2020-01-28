namespace :report do
  desc 'Output work ids for a specified set of pids'
  task :report_work_ids_by_pid, [:pids] => :environment do |t,args|
     if args.count < 1
        puts 'Usage: bundle exec rake murax:report_work_ids_by_pid["<pid>[ <pid>]..."]'
        next
     end
    
     pids = args[:pids].split(' ')

     successes = 0
     errors = 0
     total_items = pids.count
     workids = {}
     pids.each_with_index do | pid, index |
        puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total_items}  : Processing the pid #{pid}"
        puts "fetching work ids from pid #{pid}"
        samvera_work_id = ReportWorkidsService.by_pid(pid)
        workids << samvera_work_id if samvera_work_id.present?
     end

     puts workids.join("\n")



  end
end
