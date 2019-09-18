class AddRawXmlToImportlogs < ActiveRecord::Migration[5.1]
  def change
    add_column :import_logs, :raw_xml, :string
  end
end
