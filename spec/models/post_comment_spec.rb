# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostComment, 'PostCommentモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { post_comment.valid? }

    let!(:user) { create(:user) }
    let!(:post) { create(:post, user_id: user.id) }
    let(:post_comment) { build(:post_comment, user_id: user.id, post_id: post.id) }

    context 'commentカラム' do
      it '空白でないこと' do
        post_comment.comment = ''
        is_expected.to eq false
      end
      it '100字以内であること：100字はOK' do
        post_comment.comment = Faker::Lorem.characters(number: 100)
        is_expected.to eq true
      end
      it '100字以内であること：101字はNG' do
        post_comment.comment = Faker::Lorem.characters(number: 101)
        is_expected.to eq false
      end
    end

    context 'categoryカラム' do
      it '空白でないこと' do
        post_comment.category = ''
        is_expected.to eq false
      end
    end

  end

  describe 'アソシエーションのテスト' do

    context 'Userモデルとの関係' do
      it 'N:1になっている' do
        expect(PostComment.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context 'Postモデルとの関係' do
      it 'N:1になっている' do
        expect(PostComment.reflect_on_association(:post).macro).to eq :belongs_to
      end
    end

    context 'Notificationモデルとの関係' do
      it '1:Nになっている' do
        expect(PostComment.reflect_on_association(:notifications).macro).to eq :has_many
      end
    end

  end
end