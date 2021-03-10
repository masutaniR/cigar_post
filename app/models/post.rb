class Post < ApplicationRecord
  validates :body, presence: true, length: { maximum: 100 }
  validates :category, presence: true
  attachment :post_image
  enum category: { senryu: 0, tanka: 1, free_haiku: 2 }

  belongs_to :user
  has_many :post_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # ユーザが投稿にコメント済みか確認する
  def commented_by?(user)
    post_comments.where(user_id: user.id).exists?
  end

  # ユーザが投稿にいいね済みか確認する
  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end

  # いいね通知
  def create_notification_like(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and post_id = ? and action = ?", current_user.id, user_id, id, 'like'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        post_id: id,
        visited_id: user_id,
        action: 'like'
      )
      if notification.visitor_id == notification.visited_id
        notification.checked = true
      end
      notification.save if notification.valid?
    end
  end

  # コメント通知
  def create_notification_comment(current_user, comment_id)
    save_notification_comment(current_user, comment_id, user_id)
    temp_ids = PostComment.select(:user_id).where(post_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      save_notification_comment(current_user, comment_id, temp_id['user_id'])
    end
  end

  def save_notification_comment(current_user, comment_id, visited_id)
    notification = current_user.active_notifications.new(
      post_id: id,
      post_comment_id: comment_id,
      visited_id: visited_id,
      action: 'comment'
    )
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end

  # 投稿検索
  def self.body_search_for(content)
    Post.where("body LIKE?", "%#{content}%")
  end

  # カテゴリ検索
  def self.category_search_for(content)
    case content
    when '川柳'
      Post.where("category LIKE?", "0")
    when '短歌'
      Post.where("category LIKE?", "1")
    when '自由律俳句'
      Post.where("category LIKE?", "2")
    end
  end

  # 並び替え
  def self.sort_for(sort)
    case sort
    when 'created_at_desc'
      order("created_at DESC")
    when 'created_at_asc'
      order("created_at ASC")
    when 'likes_count'
      posts = self.includes(:likes).sort_by{|post| post.likes.size}.reverse
      return Kaminari.paginate_array(posts)
    when 'comments_count'
      posts = self.includes(:post_comments).sort_by{|post| post.post_comments.size}.reverse
      return Kaminari.paginate_array(posts)
    end
  end
end
