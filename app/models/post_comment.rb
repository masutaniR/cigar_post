class PostComment < ApplicationRecord
  validates :comment, presence: true, length: { maximum: 100 }
  validates :category, presence: true
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
  belongs_to :post
end
