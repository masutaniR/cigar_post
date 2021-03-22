# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, 'Postモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { post.valid? }

    let(:user) { create(:user) }
    let!(:post) { build(:post, user_id: user.id) }

    context 'bodyカラム' do
      it '空白でないこと' do
        post.body = ''
        is_expected.to eq false
      end
      it '100字以内であること：100字はOK' do
        post.body = Faker::Lorem.characters(number: 100)
        is_expected.to eq true
      end
      it '100字以内であること：101字はNG' do
        post.body = Faker::Lorem.characters(number: 101)
        is_expected.to eq false
      end
    end

    context 'categoryカラム' do
      it '空白でないこと' do
        post.category = ''
        is_expected.to eq false
      end
    end

  end

  describe 'アソシエーションのテスト' do

    context 'Userモデルとの関係' do
      it 'N:1になっている' do
        expect(Post.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context 'PostCommentモデルとの関係' do
      it '1:Nになっている' do
        expect(Post.reflect_on_association(:post_comments).macro).to eq :has_many
      end
    end

    context 'Likeモデルとの関係' do
      it '1:Nになっている' do
        expect(Post.reflect_on_association(:likes).macro).to eq :has_many
      end
    end

    context 'Notificationモデルとの関係' do
      it '1:Nになっている' do
        expect(Post.reflect_on_association(:notifications).macro).to eq :has_many
      end
    end
  end
end