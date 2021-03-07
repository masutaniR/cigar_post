class Post < ApplicationRecord
  validates :body, presence: true, length: { maximum: 100 }
  validates :category, presence: true
  attachment :post_image
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
  has_many :post_comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # ユーザが投稿にコメント済みか確認する
  def commented_by?(user)
    post_comments.where(user_id: user.id).exists?
  end

  # ユーザが投稿にいいね済みか確認する
  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end
end
