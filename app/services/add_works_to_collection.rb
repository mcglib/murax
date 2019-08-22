class AddWorksToCollection
  def self.call(works, collection_id)
    attached = true

    # Get the collection
    collectionObj = Collection.find(collection_name)
    collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    byebug

    work_ids.each do |wkid|
      byebug
       attached = AttachWorkToCollection(wkid, work_type,collectionObj)
    end

    attached
  end
end
