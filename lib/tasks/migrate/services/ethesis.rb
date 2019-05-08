module Migrate
  module Services
    require 'tasks/migrate/services/metadata_parser'
    require 'tasks/migration_helper'
    class EthesisImport

      def initialize(depositor)
        @depositor = depositor
      end
      
      def ingest_records
      end
      
      private

        def work_record(work_attributes)
        end

    end
  end
end
