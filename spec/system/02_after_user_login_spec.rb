require 'rails_helper'

describe 'ユーザーログイン後のテスト', js: true do

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

  describe '投稿一覧画面のテスト' do

    before do
      visit posts_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/posts'
      end
      it '新着投稿が一番上に表示される' do
        top_post = find_all('.index-post-body')[0]
        expect(top_post).to have_content other_post.body
      end
      it '自分と他人の画像・名前のリンクが正しい' do
        expect(page).to have_link user.name, href: user_path(user)
        expect(page).to have_link other_user.name, href: user_path(other_user)
      end
      it '自分と他人の投稿カテゴリーが表示される' do
        expect(page).to have_content post.category_i18n
        expect(page).to have_content other_post.category_i18n
      end
      it '自分と他人の投稿本文が表示される' do
        expect(page).to have_content post.body
        expect(page).to have_content other_post.body
      end
      it '詳細ページへのリンクが表示される' do
        expect(page).to have_link '投稿詳細を見る', href: post_path(post)
        expect(page).to have_link '投稿詳細を見る', href: post_path(other_post)
      end
      it '自分の投稿に削除リンクが表示される' do
        my_post = find_all('.post-reaction')[1]
        expect(my_post).to have_link '削除', href: post_path(post)
      end
      it '他人の投稿には削除リンクが表示されない' do
        other_post = find_all('.post-reaction')[0]
        expect(other_post).not_to have_link '削除'
      end
      it 'コメントリンクが表示される' do
        expect(page).to have_link 'コメント', href: "/posts/#{ post.id.to_s }#comment-form"
        expect(page).to have_link 'コメント', href: "/posts/#{ other_post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        expect(page).to have_link 'いいね', href: post_likes_path(post)
        expect(page).to have_link 'いいね', href: post_likes_path(other_post)
      end
    end

    context '削除のテスト' do

      before do
        click_link '削除'
        click_button '削除する'
      end

      it '正しく削除される' do
        expect(Post.where(id: post.id).count).to eq 0
      end
      it '削除後のリダイレクト先が投稿一覧になっている' do
        expect(current_path).to eq '/posts'
      end
    end
  end

  describe '新規投稿画面のテスト' do

    before do
      visit new_post_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/posts/new'
      end
      it 'bodyフォームが表示される' do
        expect(page).to have_field 'post[body]'
      end
      it 'post_imageフォームは表示されない' do
        expect(page).not_to have_field 'post[post_image]'
      end
      it 'imageアイコンが表示される' do
        expect(page).to have_selector 'i', class: 'fa-image'
      end
      it 'カテゴリボタンが表示される' do
        expect(page).to have_field 'post[category]'
      end
      it 'カテゴリボタンのデフォルト選択が川柳になっている' do
        expect(page).to have_checked_field '川柳'
      end
      it '新規投稿ボタンが表示される' do
        expect(page).to have_button '送信'
      end
    end

    context '新規投稿のテスト' do

      before do
        fill_in 'post[body]', with: Faker::Lorem.characters(number: 20)
      end

      it '新しい投稿が正しく保存される' do
        expect{ click_button '送信' }.to change{ Post.count }.by(1)
      end
      it 'リダイレクト先が投稿詳細ページになっている' do
        click_button '送信'
        expect(current_path).to eq "/posts/#{ Post.last.id.to_s }"
      end
    end
  end

  describe '投稿詳細ページのテスト' do

    context '自分の投稿詳細画面の表示内容の確認' do

      before do
        visit post_path(post)
      end

      it 'プロフィール画像と名前のリンクが正しい' do
        post_detail = find('.main-contents')
        expect(post_detail).to have_link user.name, href: user_path(user)
      end
      it '投稿のカテゴリが表示される' do
        expect(page).to have_content post.category_i18n
      end
      it '投稿の本文が表示される' do
        expect(page).to have_content post.body
      end
      it '投稿削除リンクが表示される' do
        expect(page).to have_link '削除', href: post_path(post)
      end
      it 'コメントリンクが表示される' do
        expect(page).to have_link 'コメント', href: "/posts/#{ post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        expect(page).to have_link 'いいね', href: post_likes_path(post)
      end
      it 'commentフォームが表示される' do
        expect(page).to have_field 'post_comment[comment]'
      end
      it 'コメントカテゴリボタンが表示される' do
        expect(page).to have_field 'post_comment[category]'
      end
      it 'コメントカテゴリボタンのデフォルト選択が川柳になっている' do
        expect(page).to have_checked_field('川柳')
      end
      it 'コメント送信ボタンが表示される' do
        expect(page).to have_button '送信'
      end
      it 'サイドバーに自分のプロフィールが表示される' do
        user_info = find('.user-info')
        expect(user_info).to have_link user.name, href: user_path(user)
        expect(user_info).to have_content user.introduction
      end
      it '投稿が正しく削除される' do
        click_link '削除'
        click_button '削除する'
        expect(Post.where(id: post.id).count).to eq 0
      end
      it '削除後のリダイレクト先が投稿一覧になっている' do
        click_link '削除'
        click_button '削除する'
        expect(current_path).to eq '/posts'
      end
    end

    context '他人の投稿詳細画面の表示内容の確認' do

      before do
        visit post_path(other_post)
      end

      it 'プロフィール画像と名前のリンクが正しい' do
        post_detail = find('.main-contents')
        expect(post_detail).to have_link other_user.name, href: user_path(other_user)
      end
      it '投稿のカテゴリが表示される' do
        expect(page).to have_content other_post.category_i18n
      end
      it '投稿の本文が表示される' do
        expect(page).to have_content other_post.body
      end
      it '投稿削除リンクが表示されない' do
        expect(page).not_to have_link '削除'
      end
      it 'コメントリンクが表示される' do
        expect(page).to have_link 'コメント', href: "/posts/#{ other_post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        expect(page).to have_link 'いいね', href: post_likes_path(other_post)
      end
      it 'commentフォームが表示される' do
        expect(page).to have_field 'post_comment[comment]'
      end
      it 'コメントカテゴリボタンが表示される' do
        expect(page).to have_field 'post_comment[category]'
      end
      it 'コメントカテゴリボタンのデフォルト選択が川柳になっている' do
        expect(page).to have_checked_field('川柳')
      end
      it 'コメント送信ボタンが表示される' do
        expect(page).to have_button '送信'
      end
      it 'サイドバーに他人のプロフィールが表示される' do
        user_info = find('.user-info')
        expect(user_info).to have_link other_user.name, href: user_path(other_user)
        expect(user_info).to have_content other_user.introduction
      end
      it 'いいね' do
        click_link 'いいね'
        expect(page).to have_content 'いいね 1'
        visit current_path
        expect(other_post.likes.count).to eq 1
      end
    end
  end

  describe 'ユーザー一覧画面のテスト' do

    before do
      visit users_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users'
      end
      it '新着ユーザーが一番上に表示される' do
        top_user = find_all('.one-user')[0]
        expect(top_user).to have_content other_user.name
      end
      it '自分と他人のプロフィール画像が表示される' do
        users = find('.main-contents')
        expect(users).to have_selector('img', count: 2)
      end
      it '自分と他人の名前のリンクが正しい' do
        expect(page).to have_link user.name, href: user_path(user)
        expect(page).to have_link other_user.name, href: user_path(other_user)
      end
      it '自分と他人の自己紹介が表示される' do
        expect(page).to have_content user.introduction
        expect(page).to have_content other_user.introduction
      end
      it '自分にはフォローボタンが表示されない' do
        user_info = find_all('.one-user')[1]
        expect(user_info).not_to have_link 'フォローする'
      end
      it '他人にフォローボタンが表示される' do
        other_user_info = find_all('.one-user')[0]
        expect(other_user_info).to have_link 'フォローする'
      end
    end
  end

  describe '自分のユーザー詳細画面のテスト' do

    before do
      visit user_path(user)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ user.id.to_s }"
      end
      it '投稿一覧の画像・名前のリンク先が正しい' do
        expect(page).to have_link user.name, href: user_path(user)
      end
      it '投稿一覧に自分の投稿のカテゴリーが表示される' do
        expect(page).to have_content post.category_i18n
      end
      it '投稿一覧に自分の投稿本文が表示される' do
        expect(page).to have_content post.body
      end
      it '投稿詳細ページへのリンクが表示される' do
        post_box = find('.one-post')
        expect(post_box).to have_link '投稿詳細を見る', href: post_path(post)
      end
      it '投稿に削除リンクが表示される' do
        my_post = find('.post-reaction')
        expect(my_post).to have_link '削除', href: post_path(post)
      end
      it 'コメントリンクが表示される' do
        expect(page).to have_link 'コメント', href: "/posts/#{ post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        expect(page).to have_link 'いいね', href: post_likes_path(post)
      end
      it '他人の投稿は表示されない' do
        expect(page).not_to have_content other_post.body
        expect(page).not_to have_link '投稿詳細を見る', href: post_path(other_post)
      end
    end

    context 'サイドバーの確認' do
      it '自分のプロフィールが表示される' do
        user_info = find('.user-info')
        expect(user_info).to have_link user.name, href: user_path(user)
        expect(user_info).to have_content user.introduction
      end
      it 'プロフィール編集リンクが表示される' do
        user_info = find('.user-info')
        expect(user_info).to have_link 'プロフィール編集', href: edit_user_path(user)
      end
      it '通知設定リンクが表示される' do
        user_info = find('.user-info')
        expect(user_info).to have_link '通知設定', href: notifications_setting_path
      end
      it 'フォローボタンは表示されない' do
        user_info = find('.user-info')
        expect(user_info).not_to have_link 'フォローする'
      end
    end
  end

  describe '他人のユーザー詳細画面のテスト' do

    before do
      visit user_path(other_user)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ other_user.id.to_s }"
      end
      it '投稿一覧の画像・名前のリンク先が正しい' do
        expect(page).to have_link other_user.name, href: user_path(other_user)
      end
      it '投稿一覧に投稿のカテゴリーが表示される' do
        expect(page).to have_content other_post.category_i18n
      end
      it '投稿一覧に投稿本文が表示される' do
        expect(page).to have_content other_post.body
      end
      it '投稿詳細ページへのリンクが表示される' do
        post_box = find('.one-post')
        expect(post_box).to have_link '投稿詳細を見る', href: post_path(other_post)
      end
      it '投稿に削除リンクは表示されない' do
        others_post = find('.post-reaction')
        expect(others_post).not_to have_link '削除'
      end
      it 'コメントリンクが表示される' do
        expect(page).to have_link 'コメント', href: "/posts/#{ other_post.id.to_s }#comment-form"
      end
      it 'いいねボタンが表示される' do
        expect(page).to have_link 'いいね', href: post_likes_path(other_post)
      end
      it '自分の投稿は表示されない' do
        expect(page).not_to have_content post.body
        expect(page).not_to have_link '投稿詳細を見る', href: post_path(post)
      end
    end

    context 'サイドバーの確認' do
      it '他人のプロフィールが表示される' do
        other_user_info = find('.user-info')
        expect(other_user_info).to have_link other_user.name, href: user_path(other_user)
        expect(other_user_info).to have_content other_user.introduction
      end
      it 'フォローボタンが表示される' do
        other_user_info = find('.user-info')
        expect(other_user_info).to have_link 'フォローする'
      end
      it 'プロフィール編集リンクは表示されない' do
        other_user_info = find('.user-info')
        expect(other_user_info).not_to have_link 'プロフィール編集'
      end
      it '通知設定リンクは表示されない' do
        other_user_info = find('.user-info')
        expect(other_user_info).not_to have_link '通知設定'
      end
    end
  end

  describe '自分のプロフィール編集画面のテスト' do

    before do
      visit edit_user_path(user)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq "/users/#{ user.id.to_s }/edit"
      end
      it '名前編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[name]', with: user.name
      end
      it 'プロフィール画像フォームは表示されない' do
        expect(page).not_to have_field 'user[profile_image]'
      end
      it 'NoUserアイコンが表示される' do
        expect(page).to have_selector 'img', class: 'no-photo'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it '更新ボタンが表示される' do
        expect(page).to have_button '更新'
      end
    end

    context '更新成功のテスト' do

      before do
        @old_name = user.name
        @old_intro = user.introduction
        @new_name = Faker::Lorem.characters(number: 8)
        @new_intro = Faker::Lorem.characters(number: 50)
        fill_in 'user[name]', with: @new_name
        fill_in 'user[introduction]', with: @new_intro
        click_button '更新'
      end

      it 'nameが正しく更新される' do
        expect(user.reload.name).not_to eq @old_name
        expect(user.reload.name).to eq @new_name
      end
      it 'introductionが正しく更新される' do
        expect(user.reload.introduction).not_to eq @old_intro
        expect(user.reload.introduction).to eq @new_intro
      end
      it '更新後、自分のユーザ詳細画面にリダイレクトする' do
        expect(current_path).to eq "/users/#{ user.id.to_s }"
      end
    end
  end

  describe '他人のプロフィール編集画面のテスト' do

    it 'アクセスできず、マイページにリダイレクトされる' do
      visit edit_user_path(other_user)
      expect(current_path).to eq "/users/#{ user.id.to_s }"
    end

  end

  describe 'ユーザー登録情報変更画面のテスト' do

    before do
      visit edit_user_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/edit'
      end
      it 'email編集フォームに自分のemailが表示される' do
        expect(page).to have_field 'user[email]', with: user.email
      end
      it 'password編集フォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it '確認用password編集フォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it '現在のpasswordフォームが表示される' do
        expect(page).to have_field 'user[current_password]'
      end
      it '変更ボタンが表示される' do
        expect(page).to have_button '変更'
      end
      it '退会リンクが表示される' do
        expect(page).to have_link '退会する', href: withdraw_confirm_users_path
      end
    end

    context '更新成功のテスト' do

      before do
        @old_email = user.email
        @new_email = Faker::Internet.email
        fill_in 'user[email]', with: @new_email
        fill_in 'user[current_password]', with: 'password'
        click_button '変更'
      end

      it 'emailが正しく更新される' do
        expect(user.reload.email).not_to eq @old_email
        expect(user.reload.email).to eq @new_email
      end
      it '更新後、自分のユーザ詳細画面にリダイレクトする' do
        expect(current_path).to eq "/users/#{ user.id.to_s }"
      end
    end
  end

  describe '退会のテスト' do

    before do
      visit withdraw_confirm_users_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/withdraw_confirm'
      end
      it '退会確認メッセージが表示される' do
        expect(page).to have_content '本当に退会しますか？'
      end
      it 'パスワード入力フォームが表示される' do
        expect(page).to have_field 'password'
      end
      it 'キャンセルボタンが表示される' do
        expect(page).to have_link 'キャンセル', href: edit_user_registration_path
      end
      it '退会ボタンが表示される' do
        expect(page).to have_button '退会する'
      end
    end

    context '退会に失敗する' do
      it 'パスワードが空白' do
        fill_in 'password', with: ''
        click_button '退会する'
        expect(current_path).to eq '/users/edit'
        expect(page).to have_content 'パスワードが違います。'
      end
      it 'パスワードが違う' do
        fill_in 'password', with: 'userpass'
        click_button '退会する'
        expect(current_path).to eq '/users/edit'
        expect(page).to have_content 'パスワードが違います。'
      end
      it '正しいパスワードを入力後「キャンセル」を押す' do
        fill_in 'password', with: 'password'
        click_link 'キャンセル'
        expect(current_path).to eq '/users/edit'
      end
    end

    context '退会成功のテスト' do

      before do
        fill_in 'password', with: 'password'
        click_button '退会する'
      end

      it 'ユーザーが正しく退会（物理削除）される' do
        expect(User.where(id: user.id).count).to eq 0
      end
      it '退会後のリダイレクト先がトップ画面になっている' do
        expect(current_path).to eq '/'
        expect(page).to have_content '退会手続が完了しました。'
      end
      it '退会したアカウントではログインできない' do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        expect(current_path).to eq '/users/sign_in'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end
    end
  end

end