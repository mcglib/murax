module FindOrCreateCollection
  class << self
    def create(slug, email)
      return unless slug.present?
      existing = Collection.where id: slug
      return existing.first if existing.first
      col = Collection.new metadata_for_collection(slug)
      @user = User.where(:email => email).first
      col.apply_depositor_metadata @user
      col.save!
      col
    end

    def metadata_for_collection(slug)
      collection_metadata.each do |c|
        return { id: slug, title: [c['title']], description: [c['blurb']] ,  collection_type_gid:  get_collection_type_gid(c['collection_type'])} if c['slug'] == slug
      end
      raise StandardError, "No collection metadata found for slug '#{slug}'"
    end

    def collection_metadata
      @collection_metadata ||= JSON.parse(File.read(File.join(Rails.root, 'config', 'digitool_collections.json')))
    end

    def get_collection_type_gid(collection_name)
      return unless collection_name.present?
      Hyrax::CollectionType.where(title: collection_name).first.gid
    end
  end
end
