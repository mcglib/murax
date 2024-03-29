# frozen_string_literal: true
module Murax
  # works controller behavior
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Hyrax::WorksControllerBehavior
    included do
      #before_action :redirect_mismatched_work, only: [:show]
      #before_action :scrub_params, only: %i[update create]

      def redirect_mismatched_work
        curation_concern = ActiveFedora::Base.find(params[:id])
        redirect_to(main_app.polymorphic_path(curation_concern), status: :moved_permanently) and return if curation_concern.class != _curation_concern_type
      end
    end 

    def new
      # Set the default values
      #curation_concern.publisher = ['McGill University']
      curation_concern.rights_statement = ['http://rightsstatements.org/vocab/InC/1.0/']
      curation_concern.degree_grantors = 'http://id.loc.gov/authorities/names/n80017721' if curation_concern.respond_to?(:degree_grantors)
      super
    end

    def edit
      #parse_geo
      #get_other_option_values
       super
    end

    def update
      set_language_attribute_for_abstracts if params["language_select"].present?
      super
    end
    def create
      set_language_attribute_for_abstracts if params["language_select"].present?
      #set_other_option_values
      super
    end
    def destroy
      title = curation_concern.to_s
      deleted_work_id = curation_concern.id
      deleted_files = deleted_work_files
      deleted_file_ids = deleted_work_file_ids
      super
      ## Send an email when a curation concern is deleted to the user
      WorkDeleteMailer.with(user: current_user, deleted_work_title: title, deleted_work_id: deleted_work_id, deleted_files: deleted_files, deleted_file_ids: deleted_file_ids).work_delete_email.deliver_now
    end

    private
    
    def deleted_work_files
      file_names = []
      work_files = curation_concern.ordered_file_sets
      work_files.each do |f|
        file_names << f.to_s
      end
      str_file_names = file_names.join(";  ")
      return str_file_names
    end


    def deleted_work_file_ids
      file_ids = []
      file_ids_arr = curation_concern.ordered_file_set_ids
      file_ids_arr.each do |id|
        file_ids << id.to_s
      end
      str_file_ids = file_ids.join(";  ")
      return str_file_ids
    end


    def scrub_params
      Hyrax::ParamScrubber.scrub(params, hash_key_for_curation_concern)
    end

    def set_embargo_release_date
    end

    def mutate_embargo_date
      translated_date = date_string.split.first.to_i.send(date_string.split.second.to_sym).from_now.to_date
      params[hash_key_for_curation_concern]['embargo_release_date'] = Date.parse(translated_date.to_date.to_s).strftime('%Y-%m-%d')
    end

    def set_language_attribute_for_abstracts
      new_abstracts = []
      params["language_select"].each_with_index do | lang, index | 
           #Join the value with the respective language index
           # Skip blank texts
           if !params[hash_key_for_curation_concern]['abstract'][index].blank?
              new_abstracts << "\"#{params[hash_key_for_curation_concern]['abstract'][index]}\"@#{params["language_select"][index]}"
           end
      end
      curation_concern.abstract = new_abstracts
      params[hash_key_for_curation_concern]['abstract'] = new_abstracts
    end
    def set_other_option_values
      # if the user selected the "Other" option in "degree_field" or "degree_level", and then provided a custom
      #       # value in the input shown when selecting this option, these custom values would be assigned to the
      #             # "degree_field_other" and "degree_level_other" attribute accessors so that they can be accessed by
      #                   # AddOtherFieldOptionActor. This actor will persist them in the database for reviewing later by an admin user
      curation_concern.degree_field_other = params[hash_key_for_curation_concern]['degree_field_other'] if params[hash_key_for_curation_concern]['degree_field'] == 'Other' && params[hash_key_for_curation_concern]['degree_field_other'].present?
      curation_concern.degree_level_other = params[hash_key_for_curation_concern]['degree_level_other'] if params[hash_key_for_curation_concern]['degree_level'] == 'Other' && params[hash_key_for_curation_concern]['degree_level_other'].present?

      curation_concern.degree_name_other = params[hash_key_for_curation_concern]['degree_name_other'] if params[hash_key_for_curation_concern]['degree_name'] == 'Other' && params[hash_key_for_curation_concern]['degree_name_other'].present?

      curation_concern.degree_grantors_other = params[hash_key_for_curation_concern]['degree_grantors_other'] if params[hash_key_for_curation_concern]['degree_grantors'] == 'Other' && params[hash_key_for_curation_concern]['degree_grantors_other'].present?

      curation_concern.current_username = current_user.username
    end


    def get_other_option_values
      @degree_field_other_options = get_all_other_options('degree_field')
      curation_concern.degree_field_other = degree_field_other_option.name if @degree_field_other_options.present? && curation_concern.degree_field.present? && curation_concern.degree_field == 'Other'
      @degree_name_other_options = get_all_other_options('degree_name')
      curation_concern.degree_name_other = degree_name_other_option.name if @degree_name_other_options.present? && curation_concern.degree_name.present? && curation_concern.degree_name == 'Other'
      degree_level_other_option = get_other_options('degree_level')
      curation_concern.degree_level_other = degree_level_other_option.name if degree_level_other_option.present? && curation_concern.degree_level.present? && curation_concern.degree_level == 'Other'
      degree_grantors_other_option = get_other_options('degree_grantors')
      curation_concern.degree_grantors_other = degree_grantors_other_option.name if degree_grantors_other_option.present? && curation_concern.degree_grantors.present? && curation_concern.degree_grantors == 'Other'
      @other_affiliation_other_options = get_all_other_options('other_affiliation')
    end

   def parse_geo
      curation_concern.nested_geo.each do |geo|
        if geo.bbox.present?
           # bbox is stored as a string array of lat/long string arrays like: '["121.1", "121.2", "44.1", "44.2"]', however only one array of lat/long array is stored, so the first will need to be converted to simple array of strings like: ["121.1","121.2","44.1","44.2"]
          box_array = geo.bbox.to_a.first.tr('[]" ', '').split(',')
          geo.bbox_lat_north = box_array[0]
          geo.bbox_lon_west = box_array[1]
          geo.bbox_lat_south = box_array[2]
          geo.bbox_lon_east = box_array[3]
          geo.type = :bbox.to_s
        end
        if geo.point.present?
           # point is stored as a string array of lat/long string arrays like: '["121.1", "121.2"]', however only one array of lat/long array is stored, so the first will need to be converted to simple array of strings like: ["121.1","121.2"]
           point_array = geo.point.to_a.first.tr('[]" ', '').split(',')
          geo.point_lat = point_array[0]
          geo.point_lon = point_array[1]
          geo.type = :point.to_s
        end
     end
   end

    def get_other_options(property)
      OtherOption.find_by(work_id: curation_concern.id, property_name: property)
    end

    def get_all_other_options(property)
      OtherOption.where(work_id: curation_concern.id, property_name: property.to_s)
    end

  end
end
