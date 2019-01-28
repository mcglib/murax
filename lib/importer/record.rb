module Importer
  class Record
    def initializer(xmlObj, depositor, collections, admin_set)
      @xml = xmlObj
      @work_type = work_type
      @collections = collections
      @depositor = depositor
      @admin_set = admin_set
    end

    def import
      work_attributes = get_work_attributes(@xml)
      child_works = Array.new

      # Add work to specified collection
      work_attributes['member_of_collections'] = Array(Collection.where(title: @collection_name).first)

      if !@collections.blank? && work_attributes['member_of_collections'].first.blank?
        raise StandardError, 'Missing the collection name for the work to be imported into.'
      end

        work_attributes['admin_set_id'] = (AdminSet.where(title: @admin_set).first || AdminSet.where(title: @env_default_admin_set).first).id

      { work_attributes: work_attributes.reject!{|k,v| v.blank?}, child_works: child_works }
    end

    private
      def get_work_attributes(metadata)
        work_attributes = Hash.new
        work_attributes
      end
      # Use language code to get iso639-2 uri from service
      def get_language_uri(language_codes)
        language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
                              "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
      end
  end
end

