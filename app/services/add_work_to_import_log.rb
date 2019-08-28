class AddWorkToImportLog
  def self.call(work,collection_id)
      saved = true
      # Get the work
      record = ImportLog.new
      begin
        record
        record.save!
      rescue  StandardError => e
        saved = false
        puts "The work #{work[:work_id]} - #{work[:title]} could not be logged to the import log. See #{e}"
      end
      saved
  end
end
