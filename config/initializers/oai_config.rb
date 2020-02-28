OAI_CONFIG ={
  provider: {
    repository_name: ENV['OAI_REPO_NAME'],
    repository_url: "#{ENV['OAI_URL']}",
    record_prefix: ENV['OAI_RECORD_PREFIX'],
    admin_email: ENV['OAI_ADMIN_EMAIL'],
    sample_id: ENV['OAI_SAMPLE_ID']
  },
  document: {
    limit: ENV['OAI_DOCUMENT_LIMIT'].to_i,
    set_fields: [{ label: 'DocumentType', solr_field: 'has_model_ssim' }, { label: 'Collection', solr_field: 'nesting_collection__parent_ids_ssim'}],
    set_class: '::OaiSet',
    format_filters: {
      'oai_etdms': ['has_model_ssim:"Thesis"'],
    },
    supported_formats: ['oai_dc','oai_etdms']
  }
}
