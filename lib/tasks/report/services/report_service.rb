module Report
  module Services
    attr_accessor :workid, :filename
    class ReportService
      def initialize(options={})
         @filename = options.fetch(:filename, nil)
         @batchid  = options.fetch(:batchid, nil)
      end

      def get_work_ids_by_filename
        samvera_work_ids = []
        if !@filename.nil?
          active_fedora_relation = FileSet.where("label_ssi:#{@filename}")
          if active_fedora_relation.nil?
             puts "Can't find file #{@filename}"
          end
          file_set = FileSet.find(active_fedora_relation.first.id)
          samvera_work_ids = file_set.parent_work_ids.uniq
        end
        samvera_work_ids
      end

      def get_work_ids_by_batch_id
        samvera_work_ids = []
        if !@batchid.nil?
          b=Batch.find(@batchid)
          if b.import_log.nil?
             puts "No log info found in batch #{@batchid}"
          end
          b.import_log.each do |log| samvera_work_ids << log['work_id'] end
        end
        samvera_work_ids
      end

    end
  end
end
