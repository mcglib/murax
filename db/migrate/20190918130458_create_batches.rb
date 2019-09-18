class CreateBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :batches do |t|
    #  t.references :import_log, foreign_key: true
      t.integer :no, null: false
      t.string :name
      t.timestamp :started, null: false
      t.timestamp :finished, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :batches, :name
    add_index :batches, :no
  end
end
