class AddWorksToImportLog
  def self.call(works, collection_id)
    attached = true

    works.each do |work|
      attached = AddWorkToImportLog.call(work, collection_id)
    end

    attached
  end
end
