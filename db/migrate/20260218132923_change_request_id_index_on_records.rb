class ChangeRequestIdIndexOnRecords < ActiveRecord::Migration[8.1]
  def change
    remove_index :records, :request_id, if_exists: true
    add_index :records, :request_id
  end
end
