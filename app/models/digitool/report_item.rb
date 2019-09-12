class Digitool::ReportItem < DigitoolItem

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
    xml = CleanMetadata::GenericReport.new(@pid, @work_type).clean
    xml
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

      xml.remove_namespaces!
      # Set the title
      work_attributes['title'] = []
      xml.xpath("/record/title").each do |title|
        work_attributes['title'] << title.text
      end

      # Set the abstract
      work_attributes['abstract'] = []
      xml.xpath("/record/abstract").each do |abstract|
        work_attributes['abstract'] << abstract.text if abstract.text.present?
      end


      # set the description
      work_attributes['description'] = []
      xml.xpath("/record/description").each do |desc|
        work_attributes['description'] << desc.text if desc.text.present?
      end

      # set the creator
      #work_attributes['creator'] = []
      #xml.xpath("/record/creator").each do |term|
      #  work_attributes['creator'] << term.text
      #end


      # set the nested creator attributes
      work_attributes['nested_ordered_creator_attributes'] = []
      xml.xpath("/record/creator").each_with_index do |term, index|
        work_attributes['nested_ordered_creator_attributes'] << process_ordered_field("creator", term.text, index) unless term.text.nil?
      end

      work_attributes['contributor'] =[]
      xml.xpath("/record/contributor").each do |term|
        work_attributes['contributor'] << term.text
      end

      work_attributes['subject'] =[]
      xml.xpath("/record/subject").each do |term|
        work_attributes['subject'] << term.text
      end

      # Get the date_uploaded
      date_uploaded =  DateTime.now.strftime('%Y-%m-%d')
      work_attributes['date_uploaded'] =  [date_uploaded.to_s]
      work_attributes['date_modified'] =  [date_uploaded.to_s]

      # get the modifiedDate
      date_modified_string = xml.xpath("/record/localdissacceptdate").text
      unless date_modified_string.empty?
        date_modified =  DateTime.strptime(date_modified_string, '%m/%d/%Y')
                        .strftime('%Y-%m-%d')
        work_attributes['date_created'] =  [date_modified.to_s]
      end


      # get the date. copying the modifiedDate
      date = xml.xpath("/record/date").text
      work_attributes['date'] = [date] if date.present?

      # McGill rights statement
      work_attributes['rights'] =  [config['rights_statement']]

      # Set the depositor
      work_attributes['depositor'] = depositor.email

      # set the relation
      work_attributes['relation'] = []
      xml.xpath("/record/relation").each do |term|
        work_attributes['relation'] << term.text if term.text.present?
      end

      #Added the isPart of
      work_attributes['note'] = []
      xml.xpath("/record/isPartOf").each do |term|
        work_attributes['note'] << term.text if term.text.present?
      end
      # Added the localcollectioncode
      xml.xpath("/record/localcollectioncode").each do |term|
        work_attributes['note'] << term.text if term.text.present?
      end

      ## add the technical creation date as part of the notes field
      work_attributes['note'] << add_creation_date_to_notes


      work_attributes['alternative_title'] = []
      xml.xpath("/record/alternative").each do |term|
        work_attributes['alternative_title'] << term.text if term.text.present?
      end

      work_attributes['report_number'] = []
      xml.xpath("/record/localtechnicalreportnumber").each do |term|
        work_attributes['report_number'] << term.text if term.text.present?
      end
      xml.xpath("/record/source").each do |term|
        work_attributes['report_number'] << term.text if term.text.present?
      end

      work_attributes['faculty'] = []
        xml.xpath("/record/localfacultycode").each do |term|
        work_attributes['faculty'] << term.text if term.text.present?
      end

      # get the department
      work_attributes['department'] =[]
      xml.xpath("/record/localdepartmentcode").each do |term|
        work_attributes['department'] << term.text if term.text.present?
      end
      xml.xpath("/record/localthesisdegreediscipline").each do |term|
        work_attributes['department'] << term.text if term.text.present?
      end

      # get the publisher
      work_attributes['publisher'] = []
      xml.xpath("/record/publisher").each do |term|
        work_attributes['publisher'] << term.text if term.text.present?
      end

      # get the rtype
      work_attributes['rtype'] =[]
      xml.xpath("/record/type").each do |term|
        work_attributes['rtype'] << term.text if term.text.present?
      end


      #localaffiliatedcentre
      work_attributes['local_affiliated_centre'] =[]
      xml.xpath("/record/localaffiliatedcentre").each do |term|
        work_attributes['local_affiliated_centre'] << term.text if term.text.present?
      end

      #localresearchunit
      work_attributes['research_unit'] =[]
      xml.xpath("/record/localresearchunit").each do |term|
        work_attributes['research_unit'] << term.text if term.text.present?
      end

      # get the extent if any
      extent = xml.xpath("/record/extent").text
      work_attributes['extent'] = extent if extent.present?

      # languages
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
