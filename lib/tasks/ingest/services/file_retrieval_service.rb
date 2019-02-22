module Ingest
  class FileRetrievalService
    attr_reader :drive_path

    def initialize(user)
      @drive_path = Rails.configuration.x.bulk_upload_drive_path
      @user = user
    end

    def create_remote_files(file_name)
      if file_name[0] == "/" || file_name[0] == "\\"
        file_name = file_name[1..-1]
      end
      [{url: "#{@drive_path}/#{file_name}", file_name: file_name}]
    end

    def retrieve(file_path)
      if !file_path then return false end
      file_path = strip_slashes(file_path)
      if multiple_files(file_path)
        generate_multiple_ids(file_path)
      else
        generate_single_id(file_path)
      end
    end

    def generate_single_id(file_path)
      # Return false on exception to indicate a failure
      file = File.open("#{@drive_path}/#{file_path}", 'r') rescue false
      convert_to_hyrax(file)
    end

    def generate_multiple_ids(file_path)
      multiple_files(file_path).map do |file|
        # Return false on exception to indicate a failure
        file = File.open("#{@drive_path}/#{file}", 'r') rescue false
        convert_to_hyrax(file)
      end
    end

    def convert_to_hyrax(file)
      if file
        uploaded_file = Hyrax::UploadedFile.create(user: @user, file: file)
        return uploaded_file.id
      end
    end

    def multiple_files(file_path)
      return file_path.split('; ') if file_path.include? ';'
    end

    def strip_slashes(file_path)
      if file_path[0] == "/" || file_path[0] == "\\"
        return file_path[1..-1]
      else
        return file_path
      end
    end
  end
end
