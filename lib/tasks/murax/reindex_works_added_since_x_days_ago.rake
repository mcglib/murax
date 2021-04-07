require 'active_record'
require 'optparse'
require 'rsolr'
require 'date'

namespace :murax do
  desc 'Reindex work(s) added since X days ago'
  task :reindex_works_added_since_x_days_ago, [:days] => :environment do |task, args|
    days = args[:days]
    if days == 'h' or args.count < 1
      puts "Usage: bundle exec rake murax:reindex_works_added_since_x_days_ago[number-of-days-ago]"
      puts "       where number-of-days-ago is an integer than 100"
      exit
    end
    start_time = Time.now.strftime('%Y%m%d%H%M%S')
    logger = ActiveSupport::Logger.new("log/reindex_works_added_since_#{days}_days_ago-#{start_time}.log")
    workids = fetch_works_added_since_x_days_ago(days,logger)
    reindex_works(workids,logger)
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
    end
    work_ids
  end

  def reindex_works(workids,logger)
    begin
      reindex_service=IndexAnObject.new
      success = 0
      errors  = 0
      workids.each do |work_id|
        reindex_service.by_object_id(work_id)
        if reindex_service.get_status()
          success+=1
          logger.info work_id
        else
          errors+=1
          logger.error "Can't update index for #{work_id}"
        end
      end
    logger.info "#{workids.length} works processed"
    logger.info "#{success} works successfully indexed"
    logger.info "#{errors} works failed to reindex"
    end_time = Time.now.strftime('%Y%m%d%H%M%S')
    logger.info "job ended at #{end_time}"
    rescue StandardError => e
      puts e.message
      logger.error e.message
    end
  end
end
