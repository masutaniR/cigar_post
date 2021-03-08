class RenameFollowingIdColumnToRelationships < ActiveRecord::Migration[5.2]
  def change
    rename_column :relationships, :following_id, :follower_id
  end
end
