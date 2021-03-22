# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { user.valid? }

    let!(:user) { build(:user) }

    context 'nameカラム' do
      it '空白でないこと' do
        user.name = ''
        is_expected.to eq false
      end
    end

  end
end