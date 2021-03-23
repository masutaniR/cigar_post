# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, 'Notificationモデルのテスト', type: :model do
  describe 'アソシエーションのテスト' do
    
    context 'Postモデルとの関係' do
      it 'N:1になっている' do
        expect(Notification.reflect_on_association(:post).macro).to eq :belongs_to
      end
    end
    
    context 'PostCommentモデルとの関係' do
      it 'N:1になっている' do
        expect(Notification.reflect_on_association(:post_comment).macro).to eq :belongs_to
      end
    end
    
    context 'Userモデルとの関係' do
      it 'N:1になっている：visitor' do
        expect(Notification.reflect_on_association(:visitor).macro).to eq :belongs_to
      end
      it 'N:1になっている：visited' do
        expect(Notification.reflect_on_association(:visited).macro).to eq :belongs_to
      end
    end
    
  end
end