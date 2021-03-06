class ChangeCategoryOfPosts < ActiveRecord::Migration[5.2]
  def change
    def up
      change_column :posts, :category, :integer, default: 0
    end

    def down
      change_column :posts, :category, :integer
    end
  end
end
