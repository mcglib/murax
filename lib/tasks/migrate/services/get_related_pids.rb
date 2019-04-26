module Migrate
  module Services
    require 'net/http'
    require 'uri'
    class RelatedPids
      @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
      def initialize(pid)
        @pid = pid
        get_related_pids
      end
      private 
        def get_related_pids(pid)
          if pid.present?
            uri = URI.parse("#{@scripts_url}?pid=#{pid}")
            res = Net::HTTP.get_response(uri)
            my_pids = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
            related_pids = my_pids["#{pid}"].except("usage_type")
          end

          related_pids
        end

        def download_pid_file(dest=nil)
        
        end

    end
  end
end
