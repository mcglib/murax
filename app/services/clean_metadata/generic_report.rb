module CleanMetadata
    class GenericReport < CleanMetadataService
      attr_reader :pid
      attr_reader :work_type
      def initialize(pid, work_type)
        @pid = pid
        @work_type = work_type
      end

      def clean
        metadata = self.execute_clean(@pid, "GenericReports.py")
        return false unless metadata
        metadata
      end

    end
end
