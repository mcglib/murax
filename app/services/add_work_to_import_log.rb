class AddWorkToImportLog
  def self.call(work,collection_id)
      saved = true
      # Get the work
      begin
        record = ImportLog.create(work)
        # set the date created
        record.date_imported = Date.new
        record.save!
      rescue  StandardError => e
        saved = false
        puts "The work #{work[:work_id]} - #{work[:title]} could not be logged to the import log. See #{e}"
      end

      saved
  end
end
