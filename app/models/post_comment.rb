class PostComment < ApplicationRecord
  validates :comment, presence: true, length: { maximum: 100 }
  validates :category, presence: true
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
  belongs_to :post
  has_many :notifications, dependent: :destroy

  # 管理側コメント検索
  def self.comment_search_for(content)
    PostComment.where("comment LIKE?", "%#{content}%")
  end

  # 管理側コメントカテゴリ検索
  def self.category_search_for(content)
    case content
    when '川柳'
      PostComment.where("category LIKE?", "0")
    when '短歌'
      PostComment.where("category LIKE?", "1")
    when '自由律俳句'
      PostComment.where("category LIKE?", "2")
    end
  end
end
