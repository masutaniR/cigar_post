class AddColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :other_comment_notice, :boolean, default: true, null: false
  end
end
