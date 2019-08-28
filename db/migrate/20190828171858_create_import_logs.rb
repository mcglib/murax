class CreateImportLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :import_logs do |t|
      t.string :title
      t.integer :pid
      t.boolean :imported
      t.datetime :date_imported
      t.string :work_type, limit: 30
      t.string :collection_id
      t.string :digitool_collection_code, limit: 10
      t.text :error
      t.string :work_id

      t.timestamps
    end
    add_index :import_logs, :title
    add_index :import_logs, :work_type
    add_index :import_logs, :collection_id
    add_index :import_logs, :work_id
  end
end
