require 'rails_helper'

describe 'ユーザーログイン前のテスト', js: true do

  before do
    visit root_path
  end

  describe 'トップ画面のテスト' do

    # visible: false でふわっと表示(非表示)要素も含めてテスト
    subject { find('.welcome-info', visible: false) }

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/'
      end
      it 'アバウトリンクが表示される' do
        is_expected.to have_link 'CigarPostとは？', href: about_path, visible: false
      end
      it '新規登録リンクが表示される' do
        is_expected.to have_link '新規登録', href: new_user_registration_path, visible: false
      end
      it 'ログインリンクが表示される' do
        is_expected.to have_link 'ログイン', href: new_user_session_path, visible: false
      end
      it 'Googleログインリンクが表示される' do
        is_expected.to have_link 'Googleアカウントでログイン', visible: false
      end
    end
  end

  describe 'アバウト画面のテスト' do
    before do
      visit about_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/about'
      end
    end
  end

  describe 'ヘッダーのテスト：ログイン前' do

    subject { find('header') }

    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        is_expected.to have_content 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        is_expected.to have_link 'CigarPost', href: root_path
      end
      it '新規登録リンクが表示される' do
        is_expected.to have_link '新規登録', href: new_user_registration_path
      end
      it 'ログインリンクが表示される' do
        is_expected.to have_link 'ログイン', href: new_user_session_path
      end
    end
  end

  describe 'ユーザー新規登録のテスト' do
    before do
      visit new_user_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_up'
      end
      it '「新規登録」と表示される' do
        expect(page).to have_selector('h2', text: '新規登録')
      end
      it 'nameフォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'profile_imageフォームは表示されない' do
        expect(page).not_to have_field 'user[profile_image]'
      end
      it 'NoUserアイコンが表示される' do
        expect(page).to have_selector 'img', class: 'no-photo'
      end
      it 'introductionフォームが表示される' do
        expect(page).to have_field 'user[introduction]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
    end

    context '新規登録成功のテスト' do

      before do
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 5)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button '新規登録' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先がマイページになっている' do
        click_button '新規登録'
        expect(current_path).to eq "/users/#{ User.last.id.to_s }"
      end
    end

  end

  describe 'ユーザーログイン' do

    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_in'
      end
      it '「ログイン」と表示される' do
        expect(page).to have_selector('h2', text: 'ログイン')
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'ログインボタンが表示される' do
        expect(page).to have_button 'ログイン'
      end
    end

    context 'ログイン成功のテスト' do

      before do
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
      end

      it 'ログイン後のリダイレクト先がホーム(タイムライン)になっている' do
        expect(current_path).to eq '/home'
      end
    end

    context 'ログイン失敗のテスト' do

      before do
        fill_in 'user[email]', with: ''
        fill_in 'user[password]', with: ''
        click_button 'ログイン'
      end

      it 'ログインに失敗し、ログイン画面にリダイレクトされている' do
        expect(current_path).to eq '/users/sign_in'
      end
    end

  end

  describe 'ヘッダーのテスト：ユーザーログイン後' do

    subject { find('header') }

    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        is_expected.to have_content 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        is_expected.to have_link 'CigarPost', href: timeline_path
      end
      it '新規投稿リンクが表示される' do
        is_expected.to have_link '投稿する', href: new_post_path
      end
      it '投稿一覧リンクが表示される' do
        is_expected.to have_link '投稿一覧', href: posts_path
      end
      it 'ユーザー一覧リンクが表示される' do
        is_expected.to have_link 'ユーザー', href: users_path
      end
      it '通知一覧リンクが表示される' do
        is_expected.to have_link '通知', href: notifications_path
      end
      it 'ドロップダウンメニューが表示される' do
        dropdown = find_all('.nav-link')[4]
        expect(dropdown).to have_selector 'img', class: 'user-icon'
      end
      it 'ドロップダウンメニューの内容が正しい' do
        dropdown = find_all('.nav-link')[4]
        (dropdown).click
        menu = find('.dropdown-menu')
        expect(menu).to have_link 'ホーム', href: timeline_path
        expect(menu).to have_link 'マイページ', href: user_path(user)
        expect(menu).to have_link 'プロフィール編集', href: edit_user_path(user)
        expect(menu).to have_link '通知設定', href: notifications_setting_path
        expect(menu).to have_link '登録情報変更', href: edit_user_registration_path
        expect(menu).to have_link 'ログアウト', href: destroy_user_session_path
      end
    end
  end

  describe 'ユーザーログアウトのテスト' do

    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      dropdown = find_all('.nav-link')[4]
      (dropdown).click
      click_link 'ログアウト'
    end

    context 'ログアウト成功のテスト' do
      it 'ログアウト後のリダイレクト先がトップ画面になっている' do
        expect(current_path).to eq '/'
      end
      it 'ログアウトメッセージが表示されている' do
        expect(page).to have_content 'ログアウトしました。'
      end
    end
  end

  describe 'アクセス権限のテスト' do

    subject { current_path }

    context 'ログイン前にアクセスできる' do

      let!(:info) { create(:information) }

      it 'アバウトページにアクセスできる' do
        visit about_path
        is_expected.to eq '/about'
      end
      it '投稿一覧にアクセスできる' do
        visit posts_path
        is_expected.to eq '/posts'
      end
      it 'お知らせ一覧にアクセスできる' do
        visit information_index_path
        is_expected.to eq '/information'
      end
      it 'お知らせ詳細にアクセスできる' do
        visit information_path(info)
        is_expected.to eq "/information/#{ info.id.to_s }"
      end
    end

    context '未ログインではアクセスできない' do

      let!(:user) { create(:user) }
      let!(:post) { create(:post) }

      it 'ユーザー一覧ページにアクセスできない' do
        visit users_path
        is_expected.to eq new_user_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it 'ユーザー詳細ページにアクセスできない' do
        visit user_path(user)
        is_expected.to eq new_user_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '投稿詳細ページにアクセスできない' do
        visit post_path(post)
        is_expected.to eq new_user_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '新規投稿ページにアクセスできない' do
        visit new_post_path
        is_expected.to eq new_user_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側ユーザー一覧ページにアクセスできない' do
        visit admin_users_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側投稿一覧ページにアクセスできない' do
        visit admin_posts_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側コメント一覧ページにアクセスできない' do
        visit admin_post_comments_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側お知らせ一覧ページにアクセスできない' do
        visit admin_information_index_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
    end

    context 'ユーザーログイン＆管理者未ログインではアクセスできない' do

      let(:user) { create(:user) }

      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
      end

      it '管理者側ユーザー一覧ページにアクセスできない' do
        visit admin_users_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側投稿一覧ページにアクセスできない' do
        visit admin_posts_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側コメント一覧ページにアクセスできない' do
        visit admin_post_comments_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
      it '管理者側お知らせ一覧ページにアクセスできない' do
        visit admin_information_index_path
        is_expected.to eq new_admin_session_path
        expect(page).to have_content 'ログインしてください'
      end
    end
  end

end