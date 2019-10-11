require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'open3'
require 'csv'
class MigrationHelper

  # Get the UUID
  def self.get_uuid_from_path(path)
    path.slice(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
  end

  # Get the Filepath hash
  def self.create_filepath_hash(filename, hash)
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

  # download the file from a give url

  def self.download_file(download_url, dest)
      file_path = nil
      if url.present? && dest.present?

        # set the dest_folder
        file_path = "#{dest}"

        download = open(download_url)
        io.copy_stream(download, file_path)

        # delete the tmp file to avoid running out of space
        File.delete(download)
      end
      # return the file_path
      file_path
  end


  def self.download_digitool_file_by_pid(pid, dest)
      fileinfo = nil
      if pid.present? && dest.present?

        item = DigitoolItem.new({"pid"=> pid})

        fileinfo = {path: item.download_file(dest),
                    name: item.get_file_name,
                    visibility: item.get_file_visibility,
                    pid: pid,
                    item_type: item.get_usage_type,
                    embargoed: item.is_embargoed?}
        if item.is_embargoed?
          fileinfo[:embargo_release_date] = item.get_embargo_release_date
          fileinfo[:visibility_during_embargo] = 'restricted'
          fileinfo[:visibility_after_embargo] = 'open'
        end

      end
      # return the file_path
      fileinfo
  end


  # Get the collection_pids
  def self.get_collection_pids(pids_file)
    pids = Array.new
    File.open(pids_file) do |file|
      file.each do |line|
        if !line.blank? && !get_uuid_from_path(line.strip).blank?
          pids.append(get_uuid_from_path(line.strip))
        end
      end
    end

    collection_uuids
  end
  
  def self.retry_operation(message = nil)
    begin
      retries ||= 0
      yield
    rescue Exception => e
      puts "[#{Time.now.to_s}] #{e}"
      puts e.backtrace.map{ |x| x.match(/^\/net\/deploy\/ir\/test\/releases.*/)}.compact
      puts message unless message.nil?
      sleep(5)
      retry if (retries += 1) < 2
      abort("[#{Time.now}] could not recover; aborting operation")
    end
  end
  
  # Get the migration config file
  def self.get_migration_config(collect_name)
      # Load the collection config file
      config_file = "spec/fixtures/digitool/config.yml"
      config = YAML.load_file(File.join(Rails.root, config_file))
      migration_config = config[collect_name]

      migration_config
  end

  def self.get_bibostatus_by_dctype(dctype)
    bibo_status = nil
    if dctypes.downcase.include? "preprint" or dctype.downcase.include? "pre-print"
      bibo_status = "Preprint"
    end
    if dctypes.downcase.include? "postprint"
      bibo_status = "Postprint"
    end
    if dctypes.downcase.include? "publisher" and !dctype.downcase.include? "preprint"
      bibo_status = "Published"
    end

    bibo_status
  end

  def self.get_samvera_collection_id(work_type, lccode)
      collection_id = nil
      mapping_file = "#{Rails.root}/spec/fixtures/digitool/llc_samvera_collections.csv"
      mappinglist = CSV.table(mapping_file, { headers: true, converters: :numeric, header_converters: :symbol})

      result = mappinglist.find_all  do |row| row.field(:lccode) == lccode and row.field(:worktype) == work_type end

      collection_id = result[0][:collection_id] if result[0].present?
      collection_id
  end

  def self.get_worktype_by_dctype(dctypes)
    worktype = nil
    unless dctypes.nil?

      article_types = ["preprint", "publisher", "peer", "article", "application", "postprint", "post print", "pre-print"]
      article_types.each do |term|
        if dctypes.downcase.include? term
          worktype = "Article"
        end
      end

      paper_types = ["project report", "policy", "working", "conference paper"]
      paper_types.each do |term|
        if dctypes.downcase.include? term
          worktype = "Paper"
        end
      end

      book_types = ["chapter", "book", "ebook"]
      book_types.each do |term|
        if dctypes.downcase.include? term
          worktype = "Book"
        end
      end

      report_types = ["technical"]
      report_types.each do |term|
        if dctypes.downcase.include? term
          worktype = "Report"
        end
      end

      presentation_types = ["poster"]
      presentation_types.each do |term|
        if dctypes.downcase.include? term
          worktype = "Presentation"
        end
      end
    end

    worktype
  end

  def self.get_worktype_by_lccode(lccode)
    work_type = nil

    unless lccode.nil?
      case lccode.upcase
      when "ETHESIS"
        work_type = "Thesis"
      when "BREPR"
        work_type = "Report"
      when "UGPAPER", "UGRAD", "LIVLAB"
        work_type = "Paper"
      else
        work_type = nil
      end
    end
    work_type
  end

  def self.get_worktype(dctypes, lccode)
      work_type = nil

      ## filter by lccode first
      work_type = self.get_worktype_by_lccode(lccode)

      ## if work_type is still nil, we get it by the dctype
      work_type = self.get_worktype_by_dctype(dctypes) if work_type.nil?

      work_type
  end

end
