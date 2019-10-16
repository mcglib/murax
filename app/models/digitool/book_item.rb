class Digitool::BookItem < DigitoolItem

  attr_accessor :config

  def initialize(attributes={})
    super
    @metadata_xml = clean_metadata
    @metadata_hash = set_metadatahash(@metadata_xml)

    set_title if is_view?

  end

  def add_creation_date_to_notes()
    date = @raw_xml.at_css('digital_entity control creation_date').text if @raw_xml.present?
    "Date first available online: " + date
  end

  # path to the python cleaning module
  def clean_metadata
    xml = nil
    xml = CleanMetadata::Facultypublication.new(@pid).clean

    xml
  end


  def update_identifier(work, work_type)
   work.identifier = "https://#{ENV["RAILS_HOST"]}/concerns/theses/#{new_work.id}"
   work.save!
  end

  def create( parsed_data )
      begin
        work_attributes = parsed_data[:work_attributes]
        work_attributes["relation"] << "pid: #{@pid}"

        new_work = work_record(work_attributes)

        #update the identifier
        new_work.identifier =  get_url_identifier
        new_work.save!


        # Create sipity record
        workflow = Sipity::Workflow.joins(:permission_template)
                       .where(permission_templates: { source_id: new_work.admin_set_id }, active: true)
        workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
        MigrationHelper.retry_operation('creating sipity entity for work') do
          Sipity::Entity.create!(proxy_for_global_id: new_work.to_global_id.to_s,
                                 workflow: workflow.first,
                                 workflow_state: workflow_state.first)
        end

        # We add the main file to the work
        fileset = add_main_file(@pid, work_attributes, new_work)
        puts "The work #{@pid} does not have a main file set.Check for errors"  if fileset.nil?
        log.info "The work #{@pid} does not have a file set." if fileset.nil?
        # now we fetch the related pid files
        if item.has_related_pids?
          add_related_files(item, work_attributes,new_work) 
        end

        # resave
        new_work.save!
      rescue Exception => e
        puts "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}"
        log.info "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}"
      end


      new_work
  end

  def get_work_attributes(config, depositor)
      work_attributes = Hash.new
      # Set default visibility first
      #work_attributes['embargo_release_date'] = (Date.try(:edtf, embargo_release_date) || embargo_release_date).to_s
      ## investigate how we can get the visibility from the collection level
      work_attributes['visibility'] = 'open'
      xml = Nokogiri::XML.parse(@metadata_xml)

      xml.remove_namespaces!

      # Set the title
      work_attributes['title'] = []
      xml.xpath("/record/title").each do |title|
        work_attributes['title'] << title.text
      end

      # Set the alternate title
      work_attributes['alternative_title'] = []
      xml.xpath("/record/alternative").each do |title|
        work_attributes['alternative_title'] << title.text
      end


      # set the nested creator attributes
      work_attributes['nested_ordered_creator_attributes'] = []
      xml.xpath("/record/creator").each_with_index do |term, index|
        work_attributes['nested_ordered_creator_attributes'] << process_ordered_field("creator", term.text, index) unless term.text.nil?
      end

      work_attributes['contributor'] =[]
      xml.xpath("/record/contributor").each do |term|
        work_attributes['contributor'] << term.text
      end


      # Set the abstract
      work_attributes['abstract'] = set_abstracts(xml.xpath("/record/abstract"))

      # Set the description
      work_attributes['description'] = []
      xml.xpath("/record/description").each do |term|
        work_attributes['description'] << term.text if term.text.present?
      end


      ## bibliographic citation
      work_attributes['bibliographic_citation'] = []
      xml.xpath("/record/bibliographicCitation").each do |term|
        work_attributes['bibliographic_citation'] << term.text if term.text.present?
      end


      ## date fields
      # Get the date_uploaded
      date_uploaded =  DateTime.now.strftime('%Y-%m-%d')
      work_attributes['date_uploaded'] =  [date_uploaded.to_s]
      work_attributes['date_modified'] =  [date_uploaded.to_s]
      # get the modifiedDate
      date_modified_string = xml.xpath("/record/localdissacceptdate").text
      unless date_modified_string.empty?
        # disabled adding acceptdate to date created.
        #date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y')
        #                .strftime('%Y-%m-%d')
        #work_attributes['date_created'] =  [date_modified.to_s]
      end
      ## set the disaccpetdate
      #work_attributes['date_accepted'] =  []
      #xml.xpath("/record/localdissacceptdate").each do |term|
      #  work_attributes['date_accepted'] << term.text if term.text.present?
      #end
      work_attributes['date'] =[]
      xml.xpath("/record/date").each do |term|
        work_attributes['date'] << get_proper_date(term.text) if term.text.present?
      end



      ## For ESHIP import rights statements as is
      work_attributes['rights'] = []
      xml.xpath("/record/rights").each do |term|
        work_attributes['rights'] << term.text if term.text.present?
      end



      ## Set the depositor
      work_attributes['depositor'] = depositor.email



      ## set the relation
      work_attributes['relation'] = []
      xml.xpath("/record/relation").each do |term|
        if (term.text.downcase.include? 'proquest')
          # Lets remove the pid
          text_value = "Proquest: #{term.text.strip.split(/\s+/).last}"
        else
         text_value = term.text if term.text.present?
        end
        work_attributes['relation'] << text_value if text_value.present?
      end


      ##add notes
      #Added the isPart of
      work_attributes['note'] = []
      xml.xpath("/record/isPartOf").each do |term|
        work_attributes['note'] << term.text if term.text.present?
      end
      xml.xpath("/record/localcollectioncode").each do |term|
        work_attributes['note'] << term.text if term.text.present?
      end
      # disable authoring software
      #xml.xpath("/record/localauthoringsoftware").each do |term|
      #  work_attributes['note'] << "Authoring software: #{term.text}" if term.text.present?
      #end
      ## add the technical creation date as part of the notes field
      work_attributes['note'] << add_creation_date_to_notes
      ## add (date) available
      #available_note = xml.xpath("/record/available").text
      #work_attributes['note'] << available_note if available_note.present?

      ## get the faculty
      work_attributes['faculty'] = []
        xml.xpath("/record/localfacultycode").each do |term|
        work_attributes['faculty'] << term.text if term.text.present?
      end


      ## get the department
      work_attributes['department'] =[]
      xml.xpath("/record/localdepartmentcode").each do |term|
        work_attributes['department'] << term.text if term.text.present?
      end
      ## get the department from the discipline field
      #xml.xpath("/record/localthesisdegreediscipline").each do |term|
      #  work_attributes['department'] << term.text if term.text.present?
      #end


      ## get the degree
      #work_attributes['degree'] =[]
      #xml.xpath("/record/localthesisdegreename").each do |term|
      #  work_attributes['degree'] << term.text if term.text.present?
      #end


      ## get the source
      work_attributes['source'] =[]
      xml.xpath("/record/source").each do |term|
        work_attributes['source'] << term.text if term.text.present?
      end


      ## get the publisher - do not include McGill as a publisher
      work_attributes['publisher'] = []
      xml.xpath("/record/publisher").each do |term|
        if (!term.text.downcase.include? 'mcgill')
          work_attributes['publisher'] << term.text if term.text.present?
        end
      end


      ## get the grant_number
      work_attributes['research_unit'] = []
      xml.xpath("/record/localresearchunit").each do |term|
        work_attributes['research_unit'] << term.text if term.text.present?
      end
      # get the grant_number
      work_attributes['grant_number'] = []
      xml.xpath("/record/localgrantnumber").each do |term|
        work_attributes['grant_number'] << term.text if term.text.present?
      end

      ## get the rtype
      work_attributes['rtype'] =[]
      xml.xpath("/record/type").each do |term|
        work_attributes['rtype'] << term.text if term.text.present?
      end


      ## get the extent
      extent = xml.xpath("/record/extent").text
      work_attributes['extent'] = extent if extent.present?


      # get the institution
      inst = xml.xpath("/record/institution").text
      work_attributes['institution'] = inst if inst.present?
      # Other institutions
      inst = xml.xpath("/record/localtechnicalreportinstitution").text
      work_attributes['institution'] = inst if inst.present?
      ## Other institution defination
      #inst = xml.xpath("/record/localdissertationinstitution ").text
      #work_attributes['institution'] = inst if inst.present?


      ## get identifier
      work_attributes['identifier'] = []
      xml.xpath("/record/identifier").each do |term|
        work_attributes['identifier'] << term.text if term.text.present?
      end

      ## get the subjects
      work_attributes['subject'] =[]
      xml.xpath("/record/subject").each do |term|
        work_attributes['subject'] << term.text
      end


      ## get the license
      work_attributes['license'] =[]
      xml.xpath("/record/license").each do |term|
        work_attributes['license'] << term.text
      end


      ## get status
      work_status = xml.xpath("/record/status").text
      work_attributes['status'] = work_status if work_status.present?


      ## get languages
      languages = []
      xml.xpath("/record/language").each do |term|
        clean_term = term.text.squish
        languages << clean_term if clean_term.present?
      end
      work_attributes['language'] = get_language_uri(languages) if !languages.blank?
      work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !languages.blank?

      work_attributes
  end

end
