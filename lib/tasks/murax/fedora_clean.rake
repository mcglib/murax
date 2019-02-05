require 'active_fedora/cleaner'
namespace :murax do
  include ActiveFedora::Cleaner
  desc ' Clear out all the fedora data'
  task fedora_clean: [:environment] do
       ActiveFedora::Cleaner.clean!
       ActiveFedora::SolrService.instance.conn.delete_by_query('*:*', params: { 'softCommit' => true })
  end
end
