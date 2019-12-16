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

end
