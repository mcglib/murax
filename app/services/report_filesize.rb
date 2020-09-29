class ReportFilesize

  def initialize(file_id)
    begin
      raise ArgumentError.new("Missing required argument file_id.") if file_id.nil?
      @the_file = FileSet.find(file_id)
      if !(@the_file.exist? && @the_file.file?)
         raise Errno::ENOENT.new("#{file_id} does not exist or is not a file")
      end
      puts @the_file.file_size.first
      true
    rescue ArgumentError, Errno::ENOENT, StandardError => e
      puts e.message
      @the_file = nil
      false
    end
  end

end
