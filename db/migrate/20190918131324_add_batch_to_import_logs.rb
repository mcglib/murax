class AddBatchToImportLogs < ActiveRecord::Migration[5.1]
  def change
    add_reference :import_logs, :batch, foreign_key: true
  end
end
