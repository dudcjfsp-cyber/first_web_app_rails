class CreateRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :records do |t|
      t.string :record_id, null: false
      t.string :request_id, null: false
      t.datetime :submitted_at_utc, null: false
      t.references :user, null: false, foreign_key: true
      t.string :company_name, null: false
      t.string :product_name, null: false
      t.integer :quantity, null: false

      t.timestamps
    end

    add_index :records, :record_id, unique: true
    add_index :records, :request_id
  end
end
