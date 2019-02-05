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
        @work_type = config['work_type']
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

        work_attributes['admin_set_id'] =  Hyrax::CollectionType.where(title: 'User Collection').first.gid

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
          #work_attributes['visibility_during_embargo'] = @private_visibility
          #work_attributes['visibility_after_embargo'] = @public_visibility
          work_attributes['title'] = [metadata.css("title").text]
          work_attributes['label'] = metadata.css("title").text
          
          # Set the abstract
          abstracts = []
          abstracts << metadata.css("abstract[lang='fr']").text || nil
          abstracts <<  metadata.css("abstract").first.text
          work_attributes['abstract'] = abstracts

          work_attributes['creator'] = [metadata.css("creator").map(&:text)]
          work_attributes['contributor'] = [metadata.css("contributor").map(&:text)]
        
          # Get the date_uploaded
          date_modified_string = metadata.css("localdissacceptdate").text 
          date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y').strftime('%Y-%m-%d') unless date_modified_string.nil?
          work_attributes['date_modified'] =  date_modified.to_s
          work_attributes['date_uploaded'] =  date_modified.to_s
          work_attributes['date_created'] =  date_modified.to_s

          # get the modifiedDate

          #work_attributes['language'] = get_language_uri(languages) if !languages.blank?
          #work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !languages.blank?
          
          work_attributes['resource_type'] = @work_type


          # Rights visibility
          work_attributes['rights_statement'] = 'http://www.europeana.eu/portal/rights/rr-r.html'
          work_attributes['publisher'] = [metadata.css("publisher").map(&:text)]



          work_attributes['depositor'] = @depositor

          work_attributes
        end

        # Use language code to get iso639-2 uri from service
        def get_language_uri(language_codes)
          language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
                                "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
        end

        def get_rdf_info
          # RDF information
          work_attributes['deposit_record'] = ''
          work_attributes['cdr_model_type'] = ''
          rdf_version = metadata.xpath("//rdf:RDF", MigrationConstants::NS).last
          if rdf_version
            # Check for deposit record
            if rdf_version.to_s.match(/originalDeposit/)
              old_deposit_record_ids = rdf_version.xpath('rdf:Description/*[local-name() = "originalDeposit"]/@rdf:resource', MigrationConstants::NS).map(&:text)
              work_attributes['deposit_record'] = old_deposit_record_ids.map{ |id| @deposit_record_hash[MigrationHelper.get_uuid_from_path(id)] || MigrationHelper.get_uuid_from_path(id) }
            end

            # Check if aggregate work
            if rdf_version.to_s.match(/hasModel/)
              work_attributes['cdr_model_type'] = rdf_version.xpath('rdf:Description/*[local-name() = "hasModel"]/@rdf:resource', MigrationConstants::NS).map(&:text)
            end

            # Create lists of attached files and children
            if rdf_version.to_s.match(/resource/)
              contained_files = rdf_version.xpath("rdf:Description/*[not(local-name()='originalDeposit') and not(local-name() = 'defaultWebObject') and contains(@rdf:resource, 'uuid')]", MigrationConstants::NS)
              contained_files.each do |contained_file|
                tmp_uuid = MigrationHelper.get_uuid_from_path(contained_file.to_s)
                if work_attributes['cdr_model_type'].include? 'info:fedora/cdr-model:AggregateWork'
                  if !@binary_hash[tmp_uuid].blank? && !(@collection_uuids.include? tmp_uuid)
                    work_attributes['contained_files'] << tmp_uuid
                  elsif !@object_hash[tmp_uuid].blank? && tmp_uuid != uuid
                    child_works << tmp_uuid
                  end
                else
                  if !@binary_hash[tmp_uuid].blank?
                    work_attributes['contained_files'] << tmp_uuid
                  end
                end
              end

              if work_attributes['contained_files'].count > 1
                representative = rdf_version.xpath('rdf:Description/*[local-name() = "defaultWebObject"]/@rdf:resource', MigrationConstants::NS).to_s.split('/')[1]
                if representative
                  work_attributes['contained_files'] -= [MigrationHelper.get_uuid_from_path(representative)]
                  work_attributes['contained_files'] = [MigrationHelper.get_uuid_from_path(representative)] + work_attributes['contained_files']
                end
              end
              work_attributes['contained_files'].uniq!
            end

            # Find premis file
            work_attributes['premis_files'] = []
            premis_mods = metadata.xpath("//foxml:datastream[contains(@ID, 'MD_EVENTS')]", MigrationConstants::NS).last
            if !premis_mods.blank?
              premis_reference = premis_mods.xpath("foxml:datastreamVersion/foxml:contentLocation/@REF", MigrationConstants::NS).map(&:text)
              premis_reference.each do |reference|
                work_attributes['premis_files'] << MigrationHelper.get_uuid_from_path(reference)
              end
            end

            # Set access controls for work
            # Set default visibility first
            private_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
            public_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
            work_attributes['embargo_release_date'] = ''
            work_attributes['visibility'] = public_visibility

            if rdf_version.to_s.match(/metadata-patron/)
              patron = rdf_version.xpath("rdf:Description/*[local-name() = 'metadata-patron']", MigrationConstants::NS).text
              if patron == 'public'
                if rdf_version.to_s.match(/contains/)
                  work_attributes['visibility'] = public_visibility
                else
                  work_attributes['visibility'] =private_visibility
                end
              end
            elsif rdf_version.to_s.match(/embargo-until/)
              embargo_release_date = Date.parse rdf_version.xpath("rdf:Description/*[local-name() = 'embargo-until']", MigrationConstants::NS).text
              work_attributes['embargo_release_date'] = (Date.try(:edtf, embargo_release_date) || embargo_release_date).to_s
              work_attributes['visibility'] = private_visibility
              work_attributes['visibility_during_embargo'] = private_visibility
              work_attributes['visibility_after_embargo'] = public_visibility
            elsif rdf_version.to_s.match(/isPublished/)
              published = rdf_version.xpath("rdf:Description/*[local-name() = 'isPublished']", MigrationConstants::NS).text
              if published == 'no'
                work_attributes['visibility'] = private_visibility
              end
            elsif rdf_version.to_s.match(/inheritPermissions/)
              inherit = rdf_version.xpath("rdf:Description/*[local-name() = 'inheritPermissions']", MigrationConstants::NS).text
              if inherit == 'false'
                work_attributes['visibility'] = private_visibility
              end
            elsif rdf_version.to_s.match(/cdr-role:patron>authenticated/)
              authenticated = rdf_version.xpath("rdf:Description/*[local-name() = 'patron']", MigrationConstants::NS).text
              if authenticated == 'authenticated'
                work_attributes['visibility'] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
              end
            end
          end
        end
    end
  end
end
