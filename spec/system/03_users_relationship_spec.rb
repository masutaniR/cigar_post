require 'rails_helper'

describe 'ユーザー間交流のテスト', js: true do

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:post) { create(:post, user_id: user.id) }
  let!(:other_post) { create(:post, user_id: other_user.id) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  describe 'コメントのテスト' do

    before do
      visit post_path(other_post)
    end

    context 'コメント新規投稿のテスト' do

      before do
        fill_in 'post_comment[comment]', with: Faker::Lorem.characters(number: 25)
        click_button '送信'
      end

      it 'コメント投稿が正しく保存される' do
        visit current_path
        expect(other_post.post_comments.count).to eq 1
      end
      it 'リダイレクト先が投稿詳細ページになっている' do
        expect(current_path).to eq "/posts/#{ other_post.id.to_s }"
      end
    end

    context 'コメント投稿失敗のテスト' do

      before do
        fill_in 'post_comment[comment]', with: ''
        click_button '送信'
      end

      it 'エラーメッセージが表示される' do
        error = find('#error_explanation')
        expect(error).to have_content 'コメントを入力してください'
      end
      it 'コメントは保存されない' do
        visit current_path
        expect(other_post.post_comments.count).to eq 0
      end
      it 'リダイレクト先が投稿詳細ページになっている' do
        expect(current_path).to eq "/posts/#{ other_post.id.to_s }"
      end
    end

    context '自分のコメント表示のテスト' do

      before do
        @comment = Faker::Lorem.characters(number: 25)
        fill_in 'post_comment[comment]', with: @comment
        click_button '送信'
      end

      it 'コメント投稿者の画像と名前のリンクが正しい' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_link PostComment.last.user.name, href: "/users/#{ PostComment.last.user.id.to_s }"
      end
      it 'コメント本文が表示される' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_content @comment
      end
      it 'コメントカテゴリが表示される' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_content PostComment.last.category_i18n
      end
      it 'コメント削除リンクが表示される' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_link '削除', href: post_post_comment_path(other_post, PostComment.last)
      end
    end

    context '他人のコメント表示のテスト' do

      let!(:other_comment) { create(:post_comment, user_id: other_user.id, post_id: post.id) }

      before do
        visit post_path(post)
      end

      it 'コメント投稿者の画像と名前のリンクが正しい' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_link other_user.name, href: "/users/#{ other_user.id.to_s }"
      end
      it 'コメント本文が表示される' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_content other_comment.comment
      end
      it 'コメントカテゴリが表示される' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).to have_content other_comment.category_i18n
      end
      it 'コメント削除リンクは表示されない' do
        comment_box = find_all('.one-comment')[0]
        expect(comment_box).not_to have_link '削除'
      end
    end
  end

  describe 'いいねのテスト' do

    before do
      visit post_path(other_post)
      click_link 'いいね'
    end

    context 'いいね作成と削除' do
      it 'いいねが正しく保存される' do
        visit current_path
        expect(other_post.likes.count).to eq 1
      end
      it 'いいねのカウントが表示される' do
        reactions = find('.post-reaction')
        expect(reactions).to have_content 'いいね 1'
      end
      it 'いいねが正しく削除される：1投稿に1つしか作成できない' do
        click_link 'いいね 1'
        visit current_path
        expect(other_post.likes.count).to eq 0
      end
      it 'いいねが0の場合カウントは表示されない' do
        click_link 'いいね 1'
        reactions = find('.post-reaction')
        expect(reactions).not_to have_content 'いいね 1'
        expect(reactions).to have_content 'いいね'
      end
    end
  end

  describe 'フォローのテスト' do

    before do
      visit user_path(other_user)
      click_link 'フォローする'
    end

    context 'フォロー作成と削除' do
      it 'フォローが正しく保存される' do
        visit current_path
        expect(other_user.followers.count).to eq 1
      end
      it 'フォローしたユーザーのフォロワー数が更新される' do
        followers = find_all('tr')[2]
        expect(followers).to have_content 'フォロワー'
        expect(followers).to have_content '1'
      end
      it 'フォローが正しく削除される' do
        click_link 'フォロー中'
        visit current_path
        expect(other_user.followers.count).to eq 0
      end
      it 'フォロー削除したユーザーのフォロワー数が更新される' do
        click_link 'フォロー中'
        followers = find_all('tr')[2]
        expect(followers).to have_content 'フォロワー'
        expect(followers).to have_content '0'
      end
    end
  end

end