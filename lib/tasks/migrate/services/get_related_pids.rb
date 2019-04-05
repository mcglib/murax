module Migrate
  module Services
    require 'net/http'
    require 'uri'
    class GetRelatedPids
      @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
      def initialize(pid)
        @pid = pid
        get_related_pids
      end
      private 
        def get_related_pids
          uri = URI.parse("#{@scripts_url}?pid=#{@pid}")
          response = Net::HTTP.get_response(uri)
          puts response
        end
    end
  end
end
