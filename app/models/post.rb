class Post < ApplicationRecord
  validates :body, length: { maximum: 100 }
  attachment :post_image
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
end
