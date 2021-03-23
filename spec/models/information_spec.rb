# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Information, 'Informationモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { information.valid? }
    
    let(:information) { build(:information) }
    
    context 'titleカラム' do
      it '空白でないこと' do
        information.title = ''
        is_expected.to eq false
      end
      it '50字以内であること：50字はOK' do
        information.title = Faker::Lorem.characters(number: 50)
        is_expected.to eq true
      end
      it '50字以内であること：51字はNG' do
        information.title = Faker::Lorem.characters(number: 51)
        is_expected.to eq false
      end
    end
    
    context 'bodyカラム' do
      it '空白でないこと' do
        information.body = ''
        is_expected.to eq false
      end
      it '5000字以内であること：5000字はOK' do
        information.body = Faker::Lorem.characters(number: 5000)
        is_expected.to eq true
      end
      it '5000字以内であること：5001字はNG' do
        information.body = Faker::Lorem.characters(number: 5001)
        is_expected.to eq false
      end
    end
    
  end
end