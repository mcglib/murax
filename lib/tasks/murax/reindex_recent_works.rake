require 'active_record'
require 'optparse'
require 'rsolr'
require 'date'

namespace :murax do
  desc 'Reindex work(s) added since X days ago'
  task :reindex_recent_works, [:days] => :environment do |task, args|
    days = args[:days]
    if days == 'h' or args.count < 1
      puts "Usage: bundle exec rake murax:reindex_recent_works[number-of-days-ago]"
      puts "       where number-of-days-ago is an integer"
      exit
    end
    start_time = Time.now.strftime('%Y%m%d%H%M%S')
    @logfile = "log/reindex_recent_works-#{start_time}.log"
    @error_flag = false
    @indexing_errors = 0
    logger = ActiveSupport::Logger.new(@logfile)
    workids = fetch_works_added_since_x_days_ago(days,logger)
    reindex_recent_works(workids,logger)
    email_admin_user(@logfile)
  end

  def fetch_works_added_since_x_days_ago(days,logger)
    work_ids = []
    begin
      raise ArgumentError.new("Missing required number of days parameter.") if days.nil?
      #convert days into a specific_date
      now = Date.today
      specific_date = (now - days.to_i)
      solr_query = "system_create_dtsi:[#{specific_date.to_s}T00:00:01Z TO NOW]"
      results = ActiveFedora::SolrService.query(solr_query,rows:10000)
      results.each do |r|
        next if r['has_model_ssim'].first.eql? 'FileSet'
        next if r['has_model_ssim'].first.eql? 'Collection'
        next if r['has_model_ssim'].first.include? 'Hydra'
        next if r['has_model_ssim'].first.include? 'ActiveFedora'
        work_ids << r.id
      end
    rescue ArgumentError, StandardError => e
      puts e.message
      logger.error e.message
      @error_flag=true
    end
    work_ids
  end

  def reindex_recent_works(workids,logger)
    begin
      reindex_service=IndexAnObject.new
      success = 0
      workids.each do |work_id|
        reindex_service.by_object_id(work_id)
        if reindex_service.get_status()
          success+=1
          logger.info work_id
        else
          @indexing_errors+=1
          logger.error "Can't update index for #{work_id}"
        end
      end
    logger.info "#{workids.length} works processed"
    logger.info "#{success} works successfully indexed"
    logger.info "#{@indexing_errors} works failed to reindex"
    end_time = Time.now.strftime('%Y%m%d%H%M%S')
    logger.info "job ended at #{end_time}"
    rescue StandardError => e
      puts e.message
      logger.error e.message
      @error_flag=true
    end
  end


  def email_admin_user(logger)
     email_addr = ENV['ADMIN_EMAIL'].tr('"','')
     server_instance = ENV['RAILS_HOST']
     subject = "Recent works reindexed in Samvera"
     email_body = "Reindexing of recently added works in Samvera on #{server_instance} completed. "
     if @indexing_errors > 0
        subject = "Indexing errors found: #{subject}"
        email_body << "#{@indexing_errors.to_s} indexing errors occurred. "
     end
     if @error_flag
        subject = "SYSTEM ERROR: #{subject}" if @error_flag
        email_body << "A non-recoverable error occurred. Please see attached log file for details."
     end
     SystemMailer.system_email_with_attachment(email_addr,subject,email_body,@logfile).deliver
  end

end
