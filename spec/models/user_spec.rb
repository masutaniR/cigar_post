# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { user.valid? }

    let(:user) { build(:user) }

    context 'nameカラム' do
      it '空白でないこと' do
        user.name = ''
        is_expected.to eq false
      end
      it '20字以内であること：20字はOK' do
        user.name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      it '20字以内であること：21字はNG' do
        user.name = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
    end
    
    context 'introductionカラム' do
      it '200字以内であること：200字はOK' do
        user.introduction = Faker::Lorem.characters(number: 200)
        is_expected.to eq true
      end
      it '200字以内であること：201字はNG' do
        user.introduction = Faker::Lorem.characters(number: 201)
        is_expected.to eq false
      end
    end

  end
  
  describe 'アソシエーションのテスト' do
    
    context 'Postモデルとの関係' do
      it '1:Nになっている' do
        expect(User.reflect_on_association(:posts).macro).to eq :has_many
      end
    end
    
    context 'PostCommentモデルとの関係' do
      it '1:Nになっている' do
        expect(User.reflect_on_association(:post_comments).macro).to eq :has_many
      end
    end
    
    context 'Likeモデルとの関係' do
      it '1:Nになっている' do
        expect(User.reflect_on_association(:likes).macro).to eq :has_many
      end
    end
    
    context 'Relationshipモデルとの関係' do
      it '1:Nになっている：relationships' do
        expect(User.reflect_on_association(:relationships).macro).to eq :has_many
      end
      it '1:Nになっている：reverse_of_relationships' do
        expect(User.reflect_on_association(:reverse_of_relationships).macro).to eq :has_many
      end
      it '1:Nになっている：following' do
        expect(User.reflect_on_association(:following).macro).to eq :has_many
      end
      it '1:Nになっている：followers' do
        expect(User.reflect_on_association(:followers).macro).to eq :has_many
      end
    end
    
    context 'Notificationモデルとの関係' do
      it '1:Nになっている：active_notifications' do
        expect(User.reflect_on_association(:active_notifications).macro).to eq :has_many
      end
      it '1:Nになっている：passive_notifications' do
        expect(User.reflect_on_association(:passive_notifications).macro).to eq :has_many
      end
    end
  end
end