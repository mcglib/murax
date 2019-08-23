module Migrate
  class ImportRecord
    # Must include the email address of a valid user in order to ingest files
    @env_default_admin_set = 'default'
    @pid = nil

    def self.call(pid, date_created = nil)
      work_id = nil

      begin

      rescue => e
        puts "Error occured creating the role for #{role_params[:name]}: Error: #{e} -  #{@form.errors}"
        work_id = false
      end

     work_id

    end
  end
end
