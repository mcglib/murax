module CleanMetadata
    class Paper < CleanMetadataService
      attr_reader :pid
      def initialize(pid)
        @pid = pid
      end

      def clean
        metadata = self.execute_clean(@pid, "papers_gradres_27.py")
        return false unless metadata
        metadata
      end

    end
end
