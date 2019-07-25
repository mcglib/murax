module CleanMetadata
    class BioResourceReport < CleanMetadataService
      attr_reader :pid
      attr_reader :work_type
      attr_writer :metadata
    
  
      def initialize(pid, work_type)
        @pid = pid
        @work_type = work_type
        
      end
    
      def clean
        @metadata = self.execute_clean(@pid, "bioEngReports.py")
        return false unless @metadata
        @metadata

      end
    end
  end