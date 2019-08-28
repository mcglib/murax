class CreateImportlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :importlogs do |t|
      t.string :title
      t.integer :pid
      t.boolean :imported
      t.datetime :date_imported
      t.string :work_type, limit: 30
      t.string :collection_id, limit: 30
      t.string :work_id, limit: 30
      t.string :digitool_collection_code, limit: 10

      t.timestamps
    end
    add_index :importlogs, :title
  end
end
