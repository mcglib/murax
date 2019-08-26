class AddWorksToCollection
  def self.call(works, collection_id)
    attached = true

    # Get the collection
    collectionObj = Collection.find(collection_id)
    collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

    works.each do |wkid, work_type|
      attached = AttachWorkToCollection.call(wkid, work_type,collectionObj)
    end

    attached
  end
end
