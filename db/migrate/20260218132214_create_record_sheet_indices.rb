class CreateRecordSheetIndices < ActiveRecord::Migration[8.1]
  def change
    create_table :record_sheet_indices do |t|
      t.string :record_id, null: false
      t.string :sheet_name, null: false
      t.integer :row_number, null: false

      t.timestamps
    end

    add_index :record_sheet_indices, :record_id, unique: true
    add_index :record_sheet_indices, [ :sheet_name, :row_number ]
  end
end
