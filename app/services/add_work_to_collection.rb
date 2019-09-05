class AddWorkToCollection
  def self.call(wkid, wk_type, collection_id)
    attached = true

    # Get the collection
    collectionObj = Collection.find(collection_id)
    collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

    begin
      attached = AttachWorkToCollection.call(wkid, wk_type,collectionObj)
    rescue => e
      attached = false
      puts "Failed to attach work #{wkid} to #{collectionObj.name}: #{e}"
    end

    attached
  end
end
