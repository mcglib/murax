class AttachWorkToCollection
  def self.call(work_id, work_type, collectionObj)
      attached = true
      # Get the work
      work = (work_type.singularize.classify.constantize).find(work_id).first

      begin
        work.member_of_collections << collectionObj
        work.save!
      rescue  StandardError => e
        attached = false
        puts "The work #{work_id} could not be attached to the collection #{collection.id}. See #{e}"
        
      end
      attached
  end
end
