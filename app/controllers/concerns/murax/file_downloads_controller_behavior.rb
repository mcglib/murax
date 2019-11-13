module Murax
  module FileDownloadsControllerBehavior
    extend ActiveSupport::Concern
    include Hyrax::LocalFileDownloadsControllerBehavior
      # Handle the HTTP show request
      def send_original_content
        response.headers['Accept-Ranges'] = 'bytes'
        if request.head?
          local_content_head
        elsif request.headers['Range']
          send_range_for_local_file
        else
          send_original_file_contents
        end
      end
      
      def send_original_file_contents
        self.status = 200
        prepare_local_file_headers
        # For derivatives stored on the local file system
        send_file file, local_derivative_download_options
      end
      # Override the Hydra::Controller::DownloadBehavior#content_options so that
      # we have an attachement rather than 'inline'
      def file_content_options
        { type: local_file_mime_type, filename: file_name, disposition: 'attachment' }
      end

      def file_name
        # check if its a thesis and then we simply change the name 
        #
        byebug
        params[:filename] || File.basename(file) || (asset.respond_to?(:label) && asset.label)
      end
  end
end

