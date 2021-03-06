json.extract! import_log, :id, :created_at, :updated_at, :pid, :work_id, :title, :raw_xml, :date_imported, :work_type, :imported
json.work_url "<a href='/concern/theses/#{import_log.work_id}'>#{import_log.work_id}</a>"
if (!import_log.imported?)
  json.status "<span class='label label-warning'> Fail</span>"
  json.actions "<button class='btn btn-info btn-sm' data-target='#errorlog-#{import_log.pid}-Modal' data-toggle='modal' data-pid='#{import_log.pid}' type='button'><i class='fa fa-plus icon-minus' />Show Error</button>"
end
if (import_log.imported?)
  json.status "<span class='label label-success'> OK</span>"
  json.actions "<button class='btn btn-info btn-sm' data-target='#xmllog-#{import_log.pid}-Modal' data-toggle='modal' data-pid='#{import_log.pid}' type='button'><i class='fa fa-plus icon-plus' /> Raw XML</button>&nbsp;&nbsp;<button class='btn btn-info btn-sm' data-target='#importlog-#{import_log.pid}-Modal' data-toggle='modal' data-pid='#{import_log.pid}' type='button'><i class='fa fa-plus icon-plus' /> Full log</button>"
end

if (import_log.title.present?)
  json.set!(:title, import_log.title.truncate(40))
end
json.set!(:updated_at, l(import_log.updated_at, format: :short))
json.set!(:date_imported, l(import_log.date_imported, format: :short))
json.set!(:created_at, l(import_log.created_at, format: :short))
#json.actions render partial: "import_logs/.html.haml", locals: {import_log: import_log}
