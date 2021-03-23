# frozen_stirng_literal: true

require 'rails_helper'

RSpec.describe Relationship, 'Relationshipモデルのテスト', type: :model do
  describe 'アソシエーションのテスト' do

    context 'Userモデルとの関係' do
      it 'N:1になっている：follower' do
        expect(Relationship.reflect_on_association(:follower).macro).to eq :belongs_to
      end
      it 'N:1になっている：followed' do
        expect(Relationship.reflect_on_association(:followed).macro).to eq :belongs_to
      end
    end

  end
end