class ReportWorkidsService
      def self.by_filename(filename)
        samvera_work_ids = []
        if !filename.nil?
          active_fedora_relation = FileSet.search_with_conditions("label_ssi:#{filename}")
          if active_fedora_relation.nil? || active_fedora_relation.empty?
             puts "Can't find file #{filename}"
          else
             file_set = FileSet.find(active_fedora_relation.max_by { |r| r['_version_']}['id'])
             samvera_work_ids = file_set.parent_work_ids.uniq
          end
        end
        samvera_work_ids
      end

      def self.by_batch_id(batchid)
        samvera_work_ids = []
        if !batchid.nil?
          b=Batch.find(batchid)
          if b.import_log.nil?
             puts "No log info found in batch #{batchid}"
          end
          b.import_log.each do |log| samvera_work_ids << log['work_id'] end
        end
        samvera_work_ids
      end

      def self.by_pid(pid)
        workid = nil

         begin
           # We search for works with the pid #pid and have no label. Filesets have labels.
           # We do this since we have not found a way to filter on everything that is not a fileset
           # we could have used  "-has_model_ssim" => "FileSet", as a condition but that
           # did not work
           results = ActiveFedora::Base.search_with_conditions({"relation_tesim" => "pid: #{pid}", "label_ssi" => ""})
           if results.empty?
            raise ActiveFedora::ObjectNotFoundError, "No work with the pid '#{pid}'was  not found in solr"
            Rails.logger.warn "No work with the pid '#{pid}'was  not found in solr"
           end 

           workid = results.first.id

        rescue => e
            raise StandardError, "Error occured getting the work id for pid #{pid}: Error: #{stderr} #{e}"
            Rails.logger.warn "Error occured searching for the work id for pid #{pid}: Error: #{stderr} #{e}"
            nil
        end

        return false unless pid.present?

        workid
      end
end
