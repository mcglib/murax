namespace :ingest do
  require 'fileutils'
  require 'tasks/migration/migration_logging'
  require 'htmlentities'
  require 'tasks/migration/migration_constants'
  require 'csv'
  require 'yaml'
  require 'open-uri'

  # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
  require 'tasks/migrate/services/ingest_service'
  require 'tasks/migrate/services/metadata_parser'


  # Must include the email address of a valid user in order to ingest files
  @depositor_email = 'dev.library@mcgill.ca'

  @private_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  @public_visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  #
  # temporary location for file download
  @temp = 'lib/tasks/ingest/tmp'
  FileUtils::mkdir_p @temp



  desc 'Ingests a set of ethesis based on a pid'
  task :ethesis, [:pid, :collection] => :environment do |t, args|
    @collection_name = args[:collection]
    @depositor = User.where(email: "dev.library@mcgill.ca")
    start_time = Time.now
    pid = args[:pid]
    puts "[#{start_time.to_s}] Start migration of ethesis with PID:#{args[:pid]}"

    url = "http://digitool.library.mcgill.ca/cgi-bin/download-pid-xmlfile.pl?pid=#{args[:pid]}"
    #url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/pid-metadata-for-hyrax/retrieve-DEs-by-pidlist.php?pid=148464,12033,12034,12190,12729"
    metadata = Nokogiri::XML(open(url))

    puts "getting metadata for: #{pid}"
    work_attributes = Hash.new

    child_works = Array.new

    desc_md = Nokogiri::XML(metadata.xpath("//xb:digital_entity/mds/md/value/text()").text)

    work_attributes['title'] = [desc_md.xpath(".//dc:title/text()").to_s]
    work_attributes['label'] = desc_md.xpath(".//dc:title/text()").to_s
    work_attributes['depositor'] = desc_md.xpath(".//dc:creator/text()").to_s
    work_attributes['contributor'] = desc_md.xpath(".//dc:contributor").to_s
    work_attributes['description'] = [desc_md.xpath(".//dcterms:abstract/text()").to_s]


    # Add creators
    creators = Array.new
    c_items = desc_md.xpath(".//dc:creator").children
    unless c_items.empty?
        c_items.each do |n|
          creators << n.to_s
        end
    end
    work_attributes['creator'] = creators unless creators.nil?


    # Add contributors
    contributors = Array.new
    c_items = desc_md.xpath(".//dc:contributor").children
    unless c_items.empty?
        c_items.each do |n|
          contributors << n.to_s
        end
    end
    work_attributes['contributor'] = contributors unless contributors.nil?

    # Add the descriptions
    descriptions = Array.new
    abstract = desc_md.xpath(".//dcterms:abstract").children
    unless abstract.empty?
        abstract.each do |n|
          descriptions << n.to_s
        end
    end
    
    descpt = desc_md.xpath(".//dc:description").children
    unless descpt.empty?
      descpt.each do |node|
        descriptions << node.to_s
      end
    end
    work_attributes['description'] = descriptions unless descriptions.nil?

    # set the language
    work_attributes['language'] = [desc_md.xpath(".//dc:language/text()").to_s]


    date_created_str = metadata.xpath(".//control/creation_date/text()").to_s
    date_created = DateTime.strptime(date_created_str, '%Y-%m-%d %H:%M:%S').strftime('%Y-%m-%d')  unless date_created_str.nil?
    work_attributes['date_created'] = [(Date.try(:edtf, date_created) || date_created).to_s]
 
    # get the modifiedDate
    date_modified_str = metadata.xpath(".//control/modification_date/text()").to_s
    date_modified = DateTime.strptime(date_modified_str, '%Y-%m-%d %H:%M:%S').strftime('%Y-%m-%d') unless date_modified_str.nil?
    work_attributes['date_modified'] = [(Date.try(:edtf, date_modified) || date_modified).to_s]


    # Set access controls for work
    # Set default visibility first
    #work_attributes['embargo_release_date'] = ''
    work_attributes['visibility'] = @public_visibility

    # Keywords I believe are subjects
    unless desc_md.xpath(".//dc:subject").nil?
      subjects = Array.new
      desc_md.xpath(".//dc:subject").children.each do | node|
        subjects << node.to_s
      end
      work_attributes['keyword'] = subjects
      work_attributes['subject'] = subjects
    end

    work_attributes['publisher'] = [desc_md.xpath(".//dc:publisher/text()").to_s]

    ## Set the PID as identifier
    identifier = desc_md.xpath(".//dc:identifier/text()").to_s
    work_attributes['identifier'] = ([identifier] || [pid]) unless identifier.nil?

    # Added the rights_statement
    work_attributes['rights_statement'] = ["http://rightsstatements.org/vocab/NKC/1.0/"]

    # Add work to specified collection
    work_attributes['member_of_collections'] = Array(Collection.where(title: @collection_name).first)
    # Create collection if it does not yet exist
    if !@collection_name.blank? && work_attributes['member_of_collections'].first.blank?
          user_collection_type = Hyrax::CollectionType.where(title: 'User Collection').first.gid
          work_attributes['member_of_collections'] = Array(Collection.create(title: [@collection_name],
                                         depositor: @depositor.ids.first,
                                         collection_type_gid: user_collection_type))
    end
    
    @admin_set_id = (AdminSet.where(title: @admin_set).first || AdminSet.where(title: "Default Admin Set").first).id
    work_attributes['admin_set_id'] = @admin_set_id


    directory_path = metadata.xpath("//xb:digital_entity/stream_ref/directory_path/text()").to_s

    # Download and get the file for the items
    download_url =  "http://digitool.library.mcgill.ca/cgi-bin/download-pid-file.pl?pid=#{pid}&dir_path=#{directory_path}"
    download = open("#{download_url}")
    file_path = "/tmp/#{pid}.pdf"
    IO.copy_stream(download, file_path)
    ordered_members = Array.new


    work = Work.new(work_attributes)
    work.save
    fileset_attrs = { 'title' => ["#{pid}.pdf"],
                      'visibility' => @public_visibility }
    fileset = create_fileset(parent: work, resource: fileset_attrs, file: file_path)
    ordered_members << fileset
  

    work.ordered_members = ordered_members
    end_time = Time.now
    puts "[#{end_time.to_s}] Completed migration of #{pid} in #{end_time-start_time} seconds"


    exit
  end

  def ingest_ethesis_file(parent: nil, resource: nil, f: nil)
    puts "ingesting... #{f.to_s}"
    fileset_metadata = resource.slice('visibility', 'embargo_release_date', 'visibility_during_embargo',
    'visibility_after_embargo')
    if resource['embargo_release_date'].blank?
      fileset_metadata.except!('embargo_release_date', 'visibility_during_embargo', 'visibility_after_embargo')
    end
    
  end

  def create_fileset(parent: nil, resource: nil, file: nil)
    @depositor = User.find_by_email(@depositor_email)
    file_set = FileSet.create(resource)
    actor = Hyrax::Actors::FileSetActor.new(file_set, @depositor)
    actor.create_metadata(resource)


    actor.create_content(Hyrax::UploadedFile.create(file: File.open(file), user: @depositor))
    actor.attach_to_work(parent, resource)

    File.delete(file) if File.exist?(file)

    file_set

  end





  desc 'batch migrate records from XML file'
  task :works, [:collection, :configuration_file, :mapping_file] => :environment do |t, args|

    start_time = Time.now
    puts "[#{start_time.to_s}] Start migration of #{args[:collection]}"

    config = YAML.load_file(args[:configuration_file])
    collection_config = config[args[:collection]]

    # The default admin set and designated depositor must exist before running this script
    if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
        User.where(email: collection_config['depositor_email']).count > 0
      @depositor = User.where(email: collection_config['depositor_email']).first

      # Hash of all binaries in storage directory
      @binary_hash = Hash.new
      create_filepath_hash(collection_config['binaries'], @binary_hash)

      # Hash of all .xml objects in storage directory
      @object_hash = Hash.new
      create_filepath_hash(collection_config['objects'], @object_hash)

      # Hash of all premis files in storage directory
      @premis_hash = Hash.new
      create_filepath_hash(collection_config['premis'], @premis_hash)

      Migrate::Services::IngestService.new(collection_config,
                                           @object_hash,
                                           @binary_hash,
                                           @premis_hash,
                                           args[:mapping_file],
                                           @depositor).ingest_records
    else
      puts 'The default admin set or specified depositor does not exist'
    end

    end_time = Time.now
    puts "[#{end_time.to_s}] Completed migration of #{args[:collection]} in #{end_time-start_time} seconds"
  end

  private

    def get_uuid_from_path(path)
      path.slice(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
    end

    def create_filepath_hash(filename, hash)
      File.open(filename) do |file|
        file.each do |line|
          value = line.strip
          key = get_uuid_from_path(value)
          if !key.blank?
            hash[key] = value
          end
        end
      end
    end
end
