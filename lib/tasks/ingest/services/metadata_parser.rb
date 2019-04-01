module Ingest
  module Services
    class MetadataParser

      # Must include the email address of a valid user in order to ingest files
      @env_default_admin_set = 'default'
      #@private_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      #@public_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      def initialize(xml_metadata, depositor, collection, config)
        @xml = xml_metadata
        @collection_name = config['collection_name']
        @collection = collection
        @depositor = depositor
        @config = config
        @resource_type = config['resource_type']
        @admin_set = config['admin_set']
      end

      def parse
        metadata = @xml

        work_attributes = get_work_attributes(metadata)

        child_works = Array.new


        # Raise the error if  collections does not yet exist
        if !@collection_name.blank? && work_attributes['member_of_collections'].first.blank?
          puts 'Raise Error'
        end
        
        # Add work to specified collection
        work_attributes['member_of_collections'] = Array(@collection)



        # Find manifest files
        manifests = get_manifest_files(metadata)
        
        
        
        # We return the set of attributes
        #{ work_attributes: work_attributes.reject!{|k,v| v.blank?}, child_works: child_works }
        { work_attributes: work_attributes, manifests: manifests, child_works: child_works }
      end

      private

        def get_manifest_files(metadata)
          manifests = Hash.new
          manifests
        end
        def get_work_attributes(metadata)

          work_attributes = Hash.new
          
          # Set default visibility first
          #work_attributes['embargo_release_date'] = (Date.try(:edtf, embargo_release_date) || embargo_release_date).to_s
          ## investigate how we can get the visibility from the collection level
          work_attributes['visibility'] = 'open'
          
          work_attributes['title'] = [metadata.css("title").text]
          work_attributes['label'] = metadata.css("title").text
          
          # Set the abstract
          abstracts = []
          abstracts << metadata.css("abstract[lang='fr']").text || nil
          abstracts <<  metadata.css("abstract").first.text
          work_attributes['abstract'] = abstracts

          # set the description
          work_attributes['abstract'] = abstracts


          work_attributes['creator'] = metadata.css("creator").map(&:text)
          work_attributes['contributor'] = get_contributor_names(metadata.css("contributor"))
        
          # Get the date_uploaded
          date_uploaded =  DateTime.now.strftime('%Y-%m-%d')
          work_attributes['date_uploaded'] =  [date_uploaded.to_s]
          
          # get the modifiedDate
          date_modified_string = metadata.css("localdissacceptdate").text 
          date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y').strftime('%Y-%m-%d') unless date_modified_string.nil?
          work_attributes['date_modified'] =  [date_modified.to_s]
          work_attributes['date_created'] =  [date_modified.to_s]


          # get the date. copying the modifiedDate
          work_attributes['date'] = [date_modified.to_s]

          languages = [metadata.css('language').text]
          work_attributes['language'] = get_language_uri(languages) if !languages.blank?
          work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !languages.blank?
          
          work_attributes['resource_type'] = [@resource_type]

          # get the department
          work_attributes['department'] = [metadata.css('localthesisdegreediscipline').text]

          # setup the subjects
          work_attributes['subject'] = get_subjects(metadata.css('localthesisdegreediscipline'))


          # get the degree
          work_attributes['degree'] = [metadata.css('localthesisdegreename').text]


          # get the institution
          work_attributes['publisher'] = metadata.css("publisher").map(&:text)
          work_attributes['institution'] = metadata.css('publisher').map(&:text)
          
          # Rights visibility
          work_attributes['rights_statement'] = [@config['rights_statement']]
          
          # McGill rights statement
          work_attributes['rights_statement'] = 


          # Set the depositor
          work_attributes['depositor'] = @depositor.email

          # Set the rtype ( bibo dct:type)
          work_attributes['rtype'] = @resource_type

          # Get the identifier
          work_attributes['identifier'] = '312'

          work_attributes
        end


        # Get the subjects from the thesisdiscipline
        def get_subjects(degrees_xml)
          subjects = Array.new
          degrees_xml.each do | degree |
            my_text = degree.text

            @config['keywords_transformation'].each  do | forbidden_text |
            
              if my_text.downcase.include? forbidden_text.downcase()
                subjects.push(my_text.sub! "#{forbidden_text}", "")
              end
            
            end

          end
          subjects

        end
        #
        # Use language code to get iso639-2 uri from service
        def get_language_uri(language_codes)
          language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
                                "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
        end

        def get_contributor_names(contributor_xml)
          contributors = Array.new
          contributor_xml.each do | contrib |
            my_text = contrib.text
            role = my_text.gsub(/\(.*\)/, "")
            contributors.push(role.strip)
          end

          contributors
        end

    end
  end
end
