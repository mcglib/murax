class AttachWorkToCollection
  def self.call(work_id, work_type, collectionObj)
      attached = true
      # Get the work
      byebug
      work = (work_type.singularize.classify.constantize).find(work_id)

      begin
        work.member_of_collections << collectionObj
        work.save!
      rescue  StandardError => e
        attached = false
        puts "The work #{work_id} - #{work.title} could not be attached to the collection #{collectionObj.title.first}. See #{e}"
      end
      attached
  end
end
