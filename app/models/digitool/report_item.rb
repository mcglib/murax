class Digitool::ReportItem < DigitoolItem
  
  attr_accessor :config

  def initialize(attributes={})
    super
    #@metadata = clean_metadata
    @metadata_xml = clean_metadata(get_metadata, @local_collection_code)
    @metadata_hash = Hash.from_xml(@metadata_xml)

    set_title if is_view?

  end

  def set_title
    @title = @metadata_hash['title']
  end

  def add_creation_date_to_notes()
    date = @raw_xml.at_css('digital_entity control creation_date').text if @raw_xml.present?
    "Date first available online: " + date
  end

  # path to the python cleaning module
  def get_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      doc.to_s
  end

  def clean_metadata(raw_metadata, collection_code)
    xml = nil
    if @pid.present? and @work_type.present?

        #Here we call the python services 
        #depending on the collection we are working on
        case collection_code # a_variable is the variable we want to compare
        when "BREPR"    #compare to 1
          report_class = "CleanMetadata::GenericReport";
        when "GRADRES"    #compare to 2
          report_class = "CleanMetadata::GenericReport";
        else
          report_class = "CleanMetadata::GenericReport";
        end

        service_instance = report_class.constantize
        xml = service_instance.new(@pid, @work_type).clean
        #xml = raw_metadata
    end

    xml
  end

  def parse(config, depositor)
      admin_set = config['admin_set']
      env_default_admin_set = 'Default Admin Set'

      work_attributes = get_work_attributes(config, depositor)
      child_works = Array.new
  
      work_attributes['admin_set_id'] = AdminSet.where(title: admin_set).first || AdminSet.where(title: env_default_admin_set).first.id

      { work_attributes: work_attributes.reject!{|k,v| v.blank?},
        child_works: child_works }
  end

  def create( parsed_data )
      begin
        work_attributes = parsed_data[:work_attributes]
        work_attributes["relation"] << "pid: #{@pid}"

        new_work = work_record(work_attributes)
        new_work.save!

        #update the identifier
        new_work.identifier = "https://#{ENV["RAILS_HOST"]}/concerns/theses/#{new_work.id}"

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

      # Set the title
      work_attributes['title'] = []
      xml.xpath("/record/dc:title").each do |title|
        work_attributes['title'] << title.text
      end

      # Set the abstract
      work_attributes['abstract'] = []
      xml.xpath("/record/ns1:abstract").each do |abstract|
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
      
      
      # Get the date_uploaded
      date_uploaded =  DateTime.now.strftime('%Y-%m-%d')
      work_attributes['date_uploaded'] =  [date_uploaded.to_s]
      work_attributes['date_modified'] =  [date_uploaded.to_s]
      
      # get the modifiedDate
      date_modified_string = xml.xpath("/record/dc:localdissacceptdate").text
      unless date_modified_string.empty?
        date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y')
                        .strftime('%Y-%m-%d')
        work_attributes['date_created'] =  [date_modified.to_s]
      end
      
      # get the institution


      # get the date. copying the modifiedDate
      date = xml.xpath("/record/dc:date").text
      work_attributes['date'] = [date] if date.present?

      # McGill rights statement
      work_attributes['rights'] =  [config['rights_statement']]

      # Set the depositor
      work_attributes['depositor'] = depositor.email

      
      # set the relation
      work_attributes['relation'] = []
      xml.xpath("/record/dc:relation").each do |term|
        work_attributes['relation'] << term.text if term.text.present?
      end

      #Added the isPart of
      work_attributes['note'] = []
      xml.xpath("/record/ns1:isPartOf").each do |term|
        work_attributes['note'] << term.text if term.text.present?
      end

      ## add the technical creation date as part of the notes field
      work_attributes['note'] << add_creation_date_to_notes

     
      work_attributes['alternative_title'] = []
      xml.xpath("/record/dc:alternative_title").each do |term|
        work_attributes['alternative_title'] << term.text if term.text.present?
      end
      
      work_attributes['source'] = []
      xml.xpath("/record/dc:source").each do |term|
        work_attributes['source'] << term.text if term.text.present?
      end
      
      work_attributes['report_number'] = []
      xml.xpath("/record/dc:source").each do |term|
        work_attributes['report_number'] << term.text if term.text.present?
      end
      
      work_attributes['faculty'] = []
        xml.xpath("/record/ns1:localfacultycode").each do |term|
        work_attributes['faculty'] << term.text if term.text.present?
      end
      
      # get the department
      work_attributes['department'] =[]
      xml.xpath("/record/ns1:localdepartmentcode").each do |term|
        work_attributes['department'] << term.text if term.text.present?
      end

      # languages
      languages = []
      xml.xpath("/record/dc:language").each do |term|
        clean_term = term.text.squish
        languages << clean_term if clean_term.present?
      end
      work_attributes['language'] = get_language_uri(languages) if !languages.blank?
      work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !languages.blank?


      work_attributes
  end

end
