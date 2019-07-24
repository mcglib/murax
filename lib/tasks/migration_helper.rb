require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'open3'
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
      end
      # return the file_path
      file_path
  end


  def self.download_digitool_file_by_pid(pid, dest)
      fileinfo = nil
      if pid.present? && dest.present?

        item = DigitoolItem.new({"pid"=> pid})
        
        fileinfo = {path: item.download_main_pdf_file(dest),
                    name: item.get_file_name,
                    visibility: item.get_file_visibility,
                    pid: pid,
                    item_type: item.get_usage_type}

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
      sleep(10)
      retry if (retries += 1) < 5
      abort("[#{Time.now}] could not recover; aborting migration")
    end
  end
end
