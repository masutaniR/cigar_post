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

    subject { find_all('.one-comment')[0] }

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
        is_expected.to have_link PostComment.last.user.name, href: "/users/#{ PostComment.last.user.id.to_s }"
      end
      it 'コメント本文が表示される' do
        is_expected.to have_content @comment
      end
      it 'コメントカテゴリが表示される' do
        is_expected.to have_content PostComment.last.category_i18n
      end
      it 'コメント削除リンクが表示される' do
        is_expected.to have_link '削除', href: post_post_comment_path(other_post, PostComment.last)
      end
    end

    context '他人のコメント表示のテスト' do

      let!(:other_comment) { create(:post_comment, user_id: other_user.id, post_id: post.id) }

      before do
        visit post_path(post)
      end

      it 'コメント投稿者の画像と名前のリンクが正しい' do
        is_expected.to have_link other_user.name, href: "/users/#{ other_user.id.to_s }"
      end
      it 'コメント本文が表示される' do
        is_expected.to have_content other_comment.comment
      end
      it 'コメントカテゴリが表示される' do
        is_expected.to have_content other_comment.category_i18n
      end
      it 'コメント削除リンクは表示されない' do
        is_expected.not_to have_link '削除'
      end
    end
  end

  describe 'いいねのテスト' do

    before do
      visit post_path(other_post)
      click_link 'いいね'
    end

    context 'いいね作成と削除' do

      subject { find('.post-reaction') }

      it 'いいねが正しく保存される' do
        visit current_path
        expect(other_post.likes.count).to eq 1
      end
      it 'いいねのカウントが表示される' do
        is_expected.to have_content 'いいね 1'
      end
      it 'いいねが正しく削除される：1投稿に1つしか作成できない' do
        click_link 'いいね 1'
        visit current_path
        expect(other_post.likes.count).to eq 0
      end
      it 'いいねが0の場合カウントは表示されない' do
        click_link 'いいね 1'
        is_expected.not_to have_content 'いいね 1'
        is_expected.to have_content 'いいね'
      end
    end

    context 'いいね一覧のテスト' do
      
      subject { find('.post-container') }

      before do
        visit likes_user_path(user)
      end

      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ user.id.to_s }/likes"
      end
      it 'いいねのカウント表示が正しい' do
        likes = find_all('tr')[3]
        expect(likes).to have_content 'いいね'
        expect(likes).to have_content '1'
      end
      it '投稿者の画像・名前のリンクが正しい' do
        is_expected.to have_link other_user.name, href: user_path(other_user)
      end
      it 'いいねした投稿のカテゴリーが表示される' do
        is_expected.to have_content other_post.category_i18n
      end
      it 'いいねした投稿の本文が表示される' do
        is_expected.to have_content other_post.body
      end
      it '詳細ページへのリンクが表示される' do
        is_expected.to have_link '投稿詳細を見る', href: post_path(other_post)
      end
      it 'いいねした投稿の削除リンクは表示されない' do
        like_post = find_all('.post-reaction')[0]
        expect(like_post).not_to have_link '削除'
      end
      it 'コメントリンクが表示される' do
        like_post = find_all('.post-reaction')[0]
        expect(like_post).to have_link 'コメント', href: "/posts/#{ other_post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        like_post = find_all('.post-reaction')[0]
        expect(like_post).to have_link 'いいね', href: post_likes_path(other_post)
      end
    end

  end

  describe 'フォローのテスト' do

    before do
      visit user_path(other_user)
      click_link 'フォローする'
    end

    context 'フォロー作成と削除' do
      
      subject { find_all('tr')[2] }
      
      it 'フォローが正しく保存される' do
        visit current_path
        expect(other_user.followers.count).to eq 1
      end
      it 'フォローしたユーザーのフォロワー数が更新される' do
        is_expected.to have_content 'フォロワー'
        is_expected.to have_content '1'
      end
      it 'フォロー解除ボタンが表示される' do
        expect(page).to have_link 'フォロー中', href: user_relationships_path(other_user)
      end
      it 'フォローが正しく削除される' do
        click_link 'フォロー中'
        visit current_path
        expect(other_user.followers.count).to eq 0
      end
      it 'フォロー削除したユーザーのフォロワー数が更新される' do
        click_link 'フォロー中'
        is_expected.to have_content 'フォロワー'
        is_expected.to have_content '0'
      end
    end

    context 'フォロー一覧のテスト' do
      
      subject { find('.main-contents') }

      before do
        visit following_user_path(user)
      end

      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ user.id.to_s }/following"
      end
      it 'フォローのカウント表示が正しい' do
        following = find_all('tr')[1]
        expect(following).to have_content 'フォロー'
        expect(following).to have_content '1'
      end
      it 'フォローしているユーザーの名前のリンクが正しい' do
        is_expected.to have_link other_user.name, href: user_path(other_user)
      end
      it 'フォローしているユーザーの自己紹介が表示される' do
        is_expected.to have_content other_user.introduction
      end
      it 'フォロー解除ボタンが表示される' do
        is_expected.to have_link 'フォロー中', href: user_relationships_path(other_user)
      end
    end

    context 'フォロワー一覧のテスト' do
      
      subject { find('.main-contents') }

      before do
        visit followers_user_path(other_user)
      end

      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ other_user.id.to_s }/followers"
      end
      it 'フォロワーのカウント表示が正しい' do
        following = find_all('tr')[2]
        expect(following).to have_content 'フォロワー'
        expect(following).to have_content '1'
      end
      it 'フォロワーの名前のリンクが正しい' do
        is_expected.to have_link user.name, href: user_path(user)
      end
      it 'フォロワーの自己紹介が表示される' do
        is_expected.to have_content user.introduction
      end
    end
  end

  describe '通知のテスト' do
    
    subject { find('.main-contents') }

    describe 'コメント通知のテスト' do

      before do
        # 他人の投稿にコメント
        visit post_path(other_post)
        @comment = Faker::Lorem.characters(number: 25)
        fill_in 'post_comment[comment]', with: @comment
        click_button '送信'
        # ログアウト
        dropdown = find_all('.nav-link')[4]
        (dropdown).click
        click_link 'ログアウト'
        # 他人のアカウントでログイン
        visit new_user_session_path
        fill_in 'user[email]', with: other_user.email
        fill_in 'user[password]', with: other_user.password
        click_button 'ログイン'
        click_link '通知', match: :first
      end

      context '表示内容の確認' do
        it 'ヘッダーに未読通知バッチが表示される' do
          header = find('header')
          expect(header).to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it 'ページをリロードすると未読通知は消える' do
          visit current_path
          header = find('header')
          expect(header).not_to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it '通知一覧にコメント通知が表示される' do
          is_expected.to have_content 'コメントしました'
        end
        it 'コメント投稿者の名前とリンクが正しい' do
          is_expected.to have_link user.name, href: "/users/#{ user.id.to_s }"
        end
        it '通知にコメント本文が表示される' do
          is_expected.to have_content @comment
        end
      end
    end

    describe 'いいね通知のテスト' do

      before do
        # 他人の投稿にいいね
        visit post_path(other_post)
        click_link 'いいね'
        # ログアウト
        dropdown = find_all('.nav-link')[4]
        (dropdown).click
        click_link 'ログアウト'
        # 他人のアカウントでログイン
        visit new_user_session_path
        fill_in 'user[email]', with: other_user.email
        fill_in 'user[password]', with: other_user.password
        click_button 'ログイン'
        click_link '通知', match: :first
      end

      context '表示内容の確認' do
        it 'ヘッダーに未読通知バッチが表示される' do
          header = find('header')
          expect(header).to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it 'ページをリロードすると未読通知は消える' do
          visit current_path
          header = find('header')
          expect(header).not_to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it '通知一覧にいいね通知が表示される' do
          is_expected.to have_content 'いいねしました'
        end
        it 'いいねしたユーザーの名前とリンクが正しい' do
          is_expected.to have_link user.name, href: "/users/#{ user.id.to_s }"
        end
      end
    end

    describe 'フォロー通知のテスト' do

      before do
        # 他人をフォロー
        visit user_path(other_user)
        click_link 'フォローする'
        # ログアウト
        dropdown = find_all('.nav-link')[4]
        (dropdown).click
        click_link 'ログアウト'
        # 他人のアカウントでログイン
        visit new_user_session_path
        fill_in 'user[email]', with: other_user.email
        fill_in 'user[password]', with: other_user.password
        click_button 'ログイン'
        click_link '通知', match: :first
      end

      context '表示内容の確認' do
        it 'ヘッダーに未読通知バッチが表示される' do
          header = find('header')
          expect(header).to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it 'ページをリロードすると未読通知は消える' do
          visit current_path
          header = find('header')
          expect(header).not_to have_selector 'p', class: 'badge-danger', text: '1'
        end
        it '通知一覧にフォロー通知が表示される' do
          is_expected.to have_content 'フォローしました'
        end
        it 'フォローしてきたユーザーの名前とリンクが正しい' do
          is_expected.to have_link user.name, href: "/users/#{ user.id.to_s }"
        end
      end
    end

  end

end