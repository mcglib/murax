require('open3')
class CleanMetadataService
    attr_reader :python_bin
    def self.clean(*args, &block)
            new(*args, &block).clean
    end
    def execute_clean(pid, script_name)
        if ENV["PYTHON_BIN"].present?
            python_bin = ENV["PYTHON_BIN"]
        else
            python_bin = "python"
        end
  
        begin
            stdout, stderr, status = Open3.capture3("cd ./lib/python && #{python_bin} #{script_name} #{@pid.to_s}")
            if status.success?
              @metadata = stdout
            else
              return false
            end
        rescue => e
            puts "Error occured cleaning the pid #{@pid}: Error: #{stderr}"
            false
        end
  
        return false unless @metadata
        @metadata
    end
end
