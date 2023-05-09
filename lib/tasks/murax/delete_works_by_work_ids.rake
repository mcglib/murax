namespace :murax do
    desc 'Deletes works using provided workids'
    task :delete_works_by_work_ids, [:wids] => :environment do |task, args|
        if args.count < 1
            puts 'Usage: bundle exec rake murax:delete_works_by_work_ids["samvera-workid,samvera-workid"]'
            exit
        end
        workids = args[:wids].split(' ')
        start_time = Time.now
        datetime_now = Time.now.strftime('%Y%m%d%H%M%S')
        logger = ActiveSupport::Logger.new("log/delete-works-by-work-ids-#{datetime_now}.log")
        logger.info "Started: at #{start_time}"
        workids.each do |wid|
            begin
                work = ActiveFedora::Base.find(wid)
            rescue ActiveFedora::ObjectNotFoundError => e
                puts "Not found: #{wid}."
                logger.info "Not found: #{wid}: #{e}."
            end
            work.destroy
            logger.info "Deleted: #{wid}."
        end
        puts "Task completed."
    end
end