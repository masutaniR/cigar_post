class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }
  validates :introduction, length: { maximum: 200 }
  attachment :profile_image

  has_many :posts, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # かんたんログイン
  def self.guest
    find_or_create_by(email: 'test@test.com') do |user|
      user.name = 'ゲスト'
      user.password = SecureRandom.urlsafe_base64
      user.introduction = ""
      user.profile_image_id = ""
    end
  end

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

  def following?(user)
    following.include?(user)
  end
end
