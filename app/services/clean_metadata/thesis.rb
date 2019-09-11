module CleanMetadata
    class Thesis < CleanMetadataService
      attr_reader :pid
      def initialize(pid)
        @pid = pid
      end

      def clean
        metadata = self.execute_clean(@pid, "thesis.py")
        return false unless metadata
        metadata
      end

    end
end
