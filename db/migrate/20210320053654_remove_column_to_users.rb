class RemoveColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :password_manually_updated
  end
end
