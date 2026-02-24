class RenameGoogleUidToAuthUidOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :google_uid, :auth_uid
    rename_index :users, "index_users_on_google_uid", "index_users_on_auth_uid"
  end
end
