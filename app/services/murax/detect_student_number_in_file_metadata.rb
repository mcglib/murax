require 'pathname'

module Murax
  class DetectStudentNumberInFileMetadata
     @error_message = nil
     def initialize(filepathname)
        begin
           raise ArgumentError.new("Missing required argument filename.") if filepathname.nil?
           @the_file = Pathname.new(filepathname)
           if !(@the_file.exist? && @the_file.file?)
              raise Errno:ENOENT.new("#{@the_file.to_s} is not a valid file.")
           end
        rescue ArgumentError, Errno::ENOENT, StandardError => e
           puts e.message
           @the_file = nil
        end
     end

     def title_contains_student_number?
        student_number_found = true
        begin
           cmd = "exiftool -s -Title '" + @the_file.to_s + "'"
           tag = `#{cmd}`
           student_number_found = false if /\d{9}/.match(tag).nil?
        rescue StandardError => e
           @error_message = e.message
        end
        student_number_found
     end

     def get_error_message
        @error_message
     end

     def threw_error?
        return !@error_message.nil?
     end
  end
end
