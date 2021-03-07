class Post < ApplicationRecord
  validates :body, presence: true, length: { maximum: 100 }
  validates :category, presence: true
  attachment :post_image
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
  has_many :post_comments, dependent: :destroy

  # 特定のユーザが投稿にコメント済みか確認する
  def commented_by?(user, post)
    PostComment.where(user_id: user.id, post_id: post.id).exists?
  end
end
