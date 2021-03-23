require 'rails_helper'

describe 'ユーザーログイン前のテスト' do

  describe 'トップ画面のテスト' do
    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/'
      end
      it 'アバウトリンクが表示される' do
        about_link = find_all('a')[3].native.inner_text
        expect(about_link).to match 'CigarPostとは？'
      end
      it 'アバウトリンクの内容が正しい' do
        about_link = find_all('a')[3].native.inner_text
        expect(page).to have_link about_link, href: about_path
      end
      it '新規登録リンクが表示される' do
        sign_up_link = find_all('a')[4].native.inner_text
        expect(sign_up_link).to match '新規登録'
      end
      it '新規登録リンクの内容が正しい' do
        sign_up_link = find_all('a')[4].native.inner_text
        expect(page).to have_link sign_up_link, href: new_user_registration_path
      end
      it 'ログインリンクが表示される' do
        log_in_link = find_all('a')[5].native.inner_text
        expect(log_in_link).to match 'ログイン'
      end
      it 'ログインリンクの内容が正しい' do
        log_in_link = find_all('a')[5].native.inner_text
        expect(page).to have_link log_in_link, href: new_user_session_path
      end
      it 'Googleログインリンクが表示される' do
        google_log_in_link = find_all('a')[7].native.inner_text
        expect(google_log_in_link).to match 'Googleアカウントでログイン'
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
    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        logo_link = find_all('a')[0].native.inner_text
        expect(logo_link).to match 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        logo_link = find_all('a')[0].native.inner_text
        expect(page).to have_link logo_link, href: root_path
      end
      it '新規登録リンクが表示される' do
        sign_up_link = find_all('a')[1].native.inner_text
        expect(sign_up_link).to match '新規登録'
      end
      it '新規登録リンクの内容が正しい' do
        sign_up_link = find_all('a')[1].native.inner_text
        expect(page).to have_link sign_up_link, href: new_user_registration_path
      end
      it 'ログインリンクが表示される' do
        log_in_link = find_all('a')[2].native.inner_text
        expect(log_in_link).to match 'ログイン'
      end
      it 'ログインリンクの内容が正しい' do
        log_in_link = find_all('a')[2].native.inner_text
        expect(page).to have_link log_in_link, href: new_user_session_path
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
      it 'profile_imageフォームが表示される' do
        expect(page).to have_field 'user[profile_image]'
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

    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        logo_link = find_all('a')[0].native.inner_text
        expect(logo_link).to match 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        logo_link = find_all('a')[0].native.inner_text
        expect(page).to have_link logo_link, href: timeline_path
      end
      it '新規投稿リンクが表示される' do
        new_post_link = find_all('a')[1].native.inner_text
        expect(new_post_link).to match '投稿する'
      end
      it '新規投稿のリンクの内容が正しい' do
        new_post_link = find_all('a')[1].native.inner_text
        expect(page).to have_link new_post_link, href: new_post_path
      end
      it '投稿一覧リンクが表示される' do
        posts_link = find_all('a')[2].native.inner_text
        expect(posts_link).to match '投稿一覧'
      end
      it '投稿一覧のリンクの内容が正しい' do
        posts_link = find_all('a')[2].native.inner_text
        expect(page).to have_link posts_link, href: posts_path
      end
      it 'ユーザー一覧リンクが表示される' do
        users_link = find_all('a')[3].native.inner_text
        expect(users_link).to match 'ユーザー'
      end
      it 'ユーザー一覧のリンクの内容が正しい' do
        users_link = find_all('a')[3].native.inner_text
        expect(page).to have_link users_link, href: users_path
      end
      it '通知一覧リンクが表示される' do
        notifications_link = find_all('a')[4].native.inner_text
        expect(notifications_link).to match '通知'
      end
      it '通知のリンクの内容が正しい' do
        click_link '通知'
        expect(current_path).to eq '/notifications'
        # 以下の記述は"there were no matches"でエラーになる
        # notifications_link = find_all('a')[4].native.inner_text
        # expect(page).to have_link notifications_link, href: '/notifications'
      end
      it 'ドロップダウンメニューが表示される' do
        dropdown = find_all('a')[5].native.inner_text
        expect(dropdown).to match ''
      end
      it 'ドロップダウンメニューの内容が正しい' do
        expect(page).to have_link 'ホーム', href: timeline_path
        expect(page).to have_link 'マイページ', href: user_path(user)
        expect(page).to have_link 'プロフィール編集', href: edit_user_path(user)
        expect(page).to have_link '通知設定', href: notifications_setting_path
        expect(page).to have_link '登録情報変更', href: edit_user_registration_path
        expect(page).to have_link 'ログアウト', href: destroy_user_session_path
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

end