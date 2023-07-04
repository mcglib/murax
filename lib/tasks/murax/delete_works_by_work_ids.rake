require 'optparse'
require 'uri'

namespace :murax do
    desc 'Deletes works using provided workids and sends an email with list of deleted workids.'
    task :delete_works_by_work_ids, [:notify_email, :wids] => :environment do |task, args|
        if args.count < 2
            puts 'Usage: bundle exec rake murax:delete_works_by_work_ids["email-adress","samvera-workid samvera-workid"]'
            exit
        end

        #check :notify_email for valid email address
        if !args[:notify_email].match(URI::MailTo::EMAIL_REGEXP).present?
          puts "Error: Enter a valid email address."
          exit
        elsif
          notify_email = args[:notify_email]
        end

        workids = args[:wids].split(' ')
        deleted_works = {}
        start_time = Time.now
        datetime_now = Time.now.strftime('%Y%m%d%H%M%S')
        logger = ActiveSupport::Logger.new("log/delete-works-by-work-ids-#{datetime_now}.log")
        logger.info "Started: at #{start_time}"
        workids.each do |wid|
            begin
                work = ActiveFedora::Base.find(wid)
                wid_title = work.attributes["title"][0]
            rescue ActiveFedora::ObjectNotFoundError => e
                puts "Not found: #{wid}."
                logger.info "Not found: #{wid}: #{e}."
            end
            deleted_works[wid] = wid_title
            work.destroy
            logger.info "Deleted: #{wid}."
        end

        DuplicateWorksMailer.with(user_email: notify_email, deleted_works: deleted_works).email_deleted_wids.deliver_now
        puts "Task completed. An email containing deleted work ids have been sent to #{notify_email} address."

    end
end
