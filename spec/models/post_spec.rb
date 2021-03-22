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
    end

  end
end