module Migrate
  module Services
    class MetadataParser

      # Must include the email address of a valid user in order to ingest files

      def initialize(metadata, depositor, config)
        @metadata = metadata
        @depositor = depositor
        @admin_set = config['admin_set']
        @resource_type = config['resource_type']
        @env_default_admin_set = 'Default Admin Set'
        @rights_statement = config['rights_statement']
      end

      def parse
        work_attributes = get_work_attributes(@metadata)
        child_works = Array.new
  
        work_attributes['admin_set_id'] = (AdminSet.where(title: @admin_set).first || AdminSet.where(title: @env_default_admin_set).first).id

        { work_attributes: work_attributes.reject!{|k,v| v.blank?},
          child_works: child_works }
      end

      private

        def get_work_attributes(metadata)

          work_attributes = Hash.new
          # Set default visibility first
          #work_attributes['embargo_release_date'] = (Date.try(:edtf, embargo_release_date) || embargo_release_date).to_s
          ## investigate how we can get the visibility from the collection level
          work_attributes['visibility'] = 'open'
          

          xml = Nokogiri::XML.parse(metadata)
          # Set the title
          work_attributes['title'] = []
          xml.xpath("/record/dc:title").each do |title|
            work_attributes['title'] << title.text
          end

          # Set the abstract
          work_attributes['abstract'] = []
          xml.xpath("/record/dcterms:abstract").each do |abstract|
            work_attributes['abstract'] << abstract.text if abstract.text.present?
          end


          # set the description
          work_attributes['description'] = work_attributes['abstract']
          
          # set the creator
          work_attributes['creator'] = []
          xml.xpath("/record/dc:creator").each do |term|
            work_attributes['creator'] << term.text
          end


          work_attributes['contributor'] =[]
          xml.xpath("/record/dc:contributor").each do |term|
            work_attributes['contributor'] << term.text
          end
          
          work_attributes['subject'] =[]
          xml.xpath("/record/dc:subject").each do |term|
            work_attributes['subject'] << term.text
          end
          
          
          # get the department
          work_attributes['department'] =[]
          xml.xpath("/record/dcterms:localthesisdegreediscipline").each do |term|
            work_attributes['department'] << term.text if term.text.present?
          end
          
          # get the degree
          work_attributes['degree'] =[]
          xml.xpath("/record/dcterms:localthesisdegreename").each do |term|
            work_attributes['degree'] << term.text if term.text.present?
          end

          
 
          # Get the date_uploaded
          date_uploaded =  DateTime.now.strftime('%Y-%m-%d')
          work_attributes['date_uploaded'] =  [date_uploaded.to_s]
          
          # get the modifiedDate

          date_modified_string = xml.xpath("/record/dc:localdissacceptdate").text
          unless date_modified_string.empty?
            date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y')
                            .strftime('%Y-%m-%d')
            work_attributes['date_modified'] =  [date_modified.to_s]
            work_attributes['date_created'] =  [date_modified.to_s]
          end
          
          # get the institution
          work_attributes['publisher'] = xml.xpath("/record/dc:publisher").text
          work_attributes['institution'] = xml.xpath("/record/dc:publisher").text


          # get the date. copying the modifiedDate
          date = xml.xpath("/record/dc:date").text
          work_attributes['date'] = [date] if date.present?

          # McGill rights statement
          work_attributes['rights'] =  [@rights_statement]

          # Set the depositor
          work_attributes['depositor'] = @depositor.email

          # Set the rtype ( bibo dct:type)
          # Here we might need to tweak it to fetch the proper type
          work_attributes['rtype'] = @resource_type
          
          # set the relation
          work_attributes['relation'] = []
          xml.xpath("/record/dc:relation").each do |term|
            work_attributes['relation'] << term.text if term.text.present?
          end

          #Added the isPart of
          work_attributes['note'] = []
          xml.xpath("/record/dcterms:isPartOf").each do |term|
            work_attributes['note'] << term.text if term.text.present?
          end
         
          work_attributes['alternative_title'] = []
          xml.xpath("/record/dc:alternative_title").each do |term|
            work_attributes['alternative_title'] << term.text if term.text.present?
          end
          
          work_attributes['source'] = []
          xml.xpath("/record/dc:source").each do |term|
            work_attributes['source'] << term.text if term.text.present?
          end
          
          work_attributes['faculty'] = []
          xml.xpath("/record/dcterms:localfacultycode").each do |term|
            work_attributes['faculty'] << term.text if term.text.present?
          end


          # languages
          languages = []
          xml.xpath("/record/dc:language").each do |term|
            languages << term.text if term.text.present?
          end
          work_attributes['language'] = get_language_uri(languages) if !languages.blank?
          work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !languages.blank?

          
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
