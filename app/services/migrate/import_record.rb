module Migrate
  class ImportRecord
    # Must include the email address of a valid user in order to ingest files
    @env_default_admin_set = 'default'

    def initialize(metadata_file, ids, depositor, config)
    end

    def import
    end

  end
end
