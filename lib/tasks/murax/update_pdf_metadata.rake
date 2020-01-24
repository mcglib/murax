require 'active_record'

namespace :murax do
  desc 'Update a main representative pdf metadata for a given  workid(s). Multiple work ids can be passed'
  task :update_pdf_metadata, [:workids] => :environment do |task, args|
    if args.count < 1
        puts 'Usage: bundle exec rake murax:update_pdf_metadata["<samvera-work-id>[ <samvera-work-id>]..."]'
        next
    end
    workids = args[:workids].split(' ')
    #faf = FetchAFile.new
    #faf.by_uri(f)
    
    # start processing
    process_update_pdfs(workids) if workids.present?
    
    # Email error report
    send_error_report(workids, @depositor)
  end

  def process_update_pdfs(workids)
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      logger = ActiveSupport::Logger.new("log/update-pdf-metadata-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"
      successes = 0
      errors = 0
      total_items = workids.count

      workids.each_with_index do | wkid, index |
        puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total_items}  : Processing the workid #{wkid}"

        begin
          # Get representative fileid   from wkid
          rep_file_set = GetRepresentativeFileSetByWorkId.call(wkid)

          # download the file 
          faf = FetchAFile.new
          file_path = faf.fetched_file_name if faf.by_file_id_ignore_visibility(rep_file_set.id).present?
          
          # Detect if file has a student number
          has_std_no = Murax::DetectStudentNumberInFileMetadata.new(file_path).title_contains_student_number?
 
          # Move to the next workid if there is no std no detected         
          next if !has_std_no

          # Get the file metadata
          file_metadata = FetchEmbeddedMetadataFromFile.new(file_path).fetch_as_hash if has_std_no
            
          # Remove file metadata ( cleanup the title )
          # write file metadata
          curr_title = file_metadata["Title"]
          new_hash = {"Title" => curr_title }
          new_hash["Title"] = curr_title.sub(/\d{9}/, "")

          WriteEmbeddedMetadataToFile.new(file_path, new_hash).update_fields if has_std_no
          #stripped_file = Murax::StripStudentNumberFromFileMetadata.strip(file_path, file_metadata)

          # update workid with new pdf file
          status = UpdateFileSetWithNewFile.call(file_path, rep_file_set) 

          # update the success status
          #successes += 1 if status

        rescue ActiveFedora::ObjectNotFoundError => e
           errors += 1
           puts "Can't find Samvera work #{wkid}"
           logger.error "Can't find Samvera work #{wkid}: #{e}"
           next
        rescue StandardError => e
          errors += 1
          logger.imported  = false
          logger.error = "#{e}: #{e.class.name} "
          logger.error "Error updating the PDF file #{file_path}: #{e}: #{e.class.name}"
        end

      end
      
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"
      logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{wkids.map(&:inspect).join(', ')} in #{duration} minutes"
      logger.info "Task finished at #{end_time} and lasted #{duration} minutes."

      # Return the workids
      workids
  end

end
