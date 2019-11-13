class GetAttachedFileNamesFromWork
  def self.call(curation_concern)
    file_names = []
    work_files = curation_concern.ordered_file_sets
    work_files.each do |f|
      file_names << f.to_s
    end
    str_file_names = file_names.join(";  ")

    file_names
  end
end
