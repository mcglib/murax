class UpdateFileSetWithNewFile
      def self.call(filepath, fileset)
        byebug
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

end

