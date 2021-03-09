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
  has_many :active_notifications, class_name: 'Notification', foreign_key: 'visitor_id', dependent: :destroy
  has_many :passive_notifications, class_name: 'Notification', foreign_key: 'visited_id', dependent: :destroy

  # かんたんログイン
  def self.guest
    find_or_create_by(email: 'test@test.com') do |user|
      user.name = 'ゲスト'
      user.password = SecureRandom.urlsafe_base64
      user.introduction = ""
      user.profile_image_id = ""
    end
  end

  # フォロー作成
  def follow(user)
    relationships.create(followed_id: user.id)
  end

  # フォロー削除
  def unfollow(user)
    relationships.find_by(followed_id: user.id).destroy
  end

  # フォロー確認
  def following?(user)
    following.include?(user)
  end

  # フォロー通知
  def create_notification_follow(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and action = ?", current_user.id, id, 'follow'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: 'follow'
      )
      notification.save if notification.valid?
    end
  end

  # ユーザー検索
  def self.search_for(content)
    User.where("name LIKE? OR introduction LIKE?", "%#{content}%", "%#{content}%")
  end

  # 管理側ユーザー検索
  def self.admin_search_for(content)
    User.where("name LIKE? OR email LIKE?", "%#{content}%", "%#{content}%")
  end

  # # タイムライン投稿検索
  # def Post.body_search_for(content)
  #   Post.where("body LIKE?", "%#{content}%")
  # end

  # # タイムラインカテゴリ検索
  # def Post.category_search_for(content)
  #   if content == '川柳'
  #     Post.where("category LIKE?", "0")
  #   elsif content == '短歌'
  #     Post.where("category LIKE?", "1")
  #   else
  #     Post.where("category LIKE?", "2")
  #   end
  # end
end
