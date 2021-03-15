class AddDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :like_notice, :boolean, default: true, null: false
    add_column :users, :comment_notice, :boolean, default: true, null: false
    add_column :users, :follow_notice, :boolean, default: true, null: false
  end
end
