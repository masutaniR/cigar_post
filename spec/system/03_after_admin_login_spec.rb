require 'rails_helper'

describe '管理者画面のテスト' do

  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post) { create(:post, user_id: user.id) }
  let!(:other_post) { create(:post, user_id: other_user.id) }
  let!(:comment) { create(:post_comment, user_id: user.id, post_id: other_post.id) }
  let!(:other_comment) { create(:post_comment, user_id: other_user.id, post_id: post.id) }

  before do
    visit new_admin_session_path
  end

  describe 'ヘッダーのテスト：管理者ログイン前' do

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        logo_link = find_all('a')[0].native.inner_text
        expect(logo_link).to match 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        logo_link = find_all('a')[0].native.inner_text
        expect(page).to have_link logo_link, href: root_path
      end
      it 'ユーザー新規登録リンクが表示される' do
        sign_up_link = find_all('a')[1].native.inner_text
        expect(sign_up_link).to match '新規登録'
      end
      it 'ユーザー新規登録リンクの内容が正しい' do
        sign_up_link = find_all('a')[1].native.inner_text
        expect(page).to have_link sign_up_link, href: new_user_registration_path
      end
      it 'ユーザーログインリンクが表示される' do
        log_in_link = find_all('a')[2].native.inner_text
        expect(log_in_link).to match 'ログイン'
      end
      it 'ユーザーログインリンクの内容が正しい' do
        log_in_link = find_all('a')[2].native.inner_text
        expect(page).to have_link log_in_link, href: new_user_session_path
      end
    end
  end

  describe '管理者ログイン' do

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/admin/sign_in'
      end
      it '「管理者ログイン」と表示される' do
        expect(page).to have_selector('h2', text: '管理者ログイン')
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'admin[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'admin[password]'
      end
      it 'ログインボタンが表示される' do
        expect(page).to have_button 'ログイン'
      end
    end

    context 'ログイン成功のテスト' do

      before do
        fill_in 'admin[email]', with: admin.email
        fill_in 'admin[password]', with: admin.password
        click_button 'ログイン'
      end

      it 'ログイン後のリダイレクト先がユーザー一覧になっている' do
        expect(current_path).to eq '/admin/users'
      end
    end

    context 'ログイン失敗のテスト' do

      before do
        fill_in 'admin[email]', with: user.email
        fill_in 'admin[password]', with: 'password'
        click_button 'ログイン'
      end

      it 'ログインに失敗し、管理者ログイン画面にリダイレクトされている' do
        expect(current_path).to eq '/admin/sign_in'
      end
    end
  end

  describe '管理者ログイン後' do

    before do
      fill_in 'admin[email]', with: admin.email
      fill_in 'admin[password]', with: admin.password
      click_button 'ログイン'
    end

    describe 'ヘッダーのテスト：管理者ログイン後' do

      context '表示内容の確認' do
        it 'サイト名が表示される' do
          logo_link = find_all('a')[0].native.inner_text
          expect(logo_link).to match 'CigarPost'
        end
        it 'サイト名のリンクの内容が正しい' do
          logo_link = find_all('a')[0].native.inner_text
          expect(page).to have_link logo_link, href: admin_users_path
        end
        it 'ユーザー一覧リンクが表示される' do
          users_link = find_all('a')[1].native.inner_text
          expect(users_link).to match 'ユーザー'
        end
        it 'ユーザー一覧のリンクの内容が正しい' do
          users_link = find_all('a')[1].native.inner_text
          expect(page).to have_link users_link, href: admin_users_path
        end
        it '投稿一覧リンクが表示される' do
          posts_link = find_all('a')[2].native.inner_text
          expect(posts_link).to match '投稿'
        end
        it '投稿一覧のリンクの内容が正しい' do
          posts_link = find_all('a')[2].native.inner_text
          expect(page).to have_link posts_link, href: admin_posts_path
        end
        it 'コメント一覧リンクが表示される' do
          comments_link = find_all('a')[3].native.inner_text
          expect(comments_link).to match 'コメント'
        end
        it 'コメント一覧のリンクの内容が正しい' do
          comments_link = find_all('a')[3].native.inner_text
          expect(page).to have_link comments_link, href: admin_post_comments_path
        end
        it 'お知らせ一覧リンクが表示される' do
          info_link = find_all('a')[4].native.inner_text
          expect(info_link).to match 'お知らせ'
        end
        it 'お知らせ一覧のリンクの内容が正しい' do
          info_link = find_all('a')[4].native.inner_text
          expect(page).to have_link info_link, href: admin_information_index_path
        end
        it 'ログアウトリンクが表示される' do
          logout_link = find_all('a')[5].native.inner_text
          expect(logout_link).to match 'ログアウト'
        end
        it 'ログアウトリンクの内容が正しい' do
          logout_link = find_all('a')[5].native.inner_text
          expect(page).to have_link logout_link, href: destroy_admin_session_path
        end
      end
    end

    describe '管理者ログアウトのテスト' do

      before do
        click_link 'ログアウト'
      end

      context 'ログアウト成功のテスト' do
        it 'ログアウト後のリダイレクト先が管理者ログイン画面になっている' do
          expect(current_path).to eq '/admin/sign_in'
        end
        it 'ログアウトメッセージが表示されている' do
          expect(page).to have_content 'ログアウトしました。'
        end
      end
    end

    describe 'ユーザー一覧画面のテスト' do

      # ログイン後の遷移先だが、明示的にvisitを記述
      before do
        visit admin_users_path
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/admin/users'
        end
        it '新着ユーザーが一番上に表示される' do
          top_user = find_all('tr')[1]
          expect(top_user).to have_content other_user.name
        end
        it '各ユーザーの名前が表示される' do
          expect(page).to have_content user.name
          expect(page).to have_content other_user.name
        end
        it 'ユーザー名のリンクが正しい' do
          expect(page).to have_link user.name, href: admin_user_path(user)
          expect(page).to have_link other_user.name, href: admin_user_path(other_user)
        end
        it 'ユーザーのメールアドレスが表示される' do
          expect(page).to have_content user.email
          expect(page).to have_content other_user.email
        end
        it 'ユーザーステータスが表示される' do
          expect(page).to have_content('利用可能', count: 2)
        end
      end
    end

    describe 'ユーザー詳細画面のテスト' do

      before do
        visit admin_user_path(user)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq "/admin/users/#{ user.id.to_s }"
        end
        it '投稿一覧の画像・名前のリンク先が正しい' do
          posts = find('.post-index')
          expect(posts).to have_link user.name, href: admin_user_path(user)
        end
        it '投稿一覧に投稿のカテゴリーが表示される' do
          expect(page).to have_content post.category_i18n
        end
        it '投稿一覧に投稿本文が表示される' do
          expect(page).to have_content post.body
        end
        it '投稿詳細ページへのリンクが表示される' do
          posts = find('.post-index')
          expect(posts).to have_link '詳細', href: admin_post_path(post)
        end
        it 'ユーザーの投稿一覧ページへのリンクが表示される' do
          posts = find('.post-index')
          expect(posts).to have_link 'すべて見る', href: admin_posts_path(user_id: user.id)
        end
        it '他人の投稿は表示されない' do
          expect(page).not_to have_content other_post.body
        end
        it 'コメント一覧の画像・名前のリンク先が正しい' do
          comments = find('.comment-index')
          expect(comments).to have_link user.name, href: admin_user_path(user)
        end
        it 'コメント一覧に投稿のコメントカテゴリーが表示される' do
          expect(page).to have_content comment.category_i18n
        end
        it 'コメント一覧にコメント本文が表示される' do
          expect(page).to have_content comment.comment
        end
        it 'コメント投稿詳細ページへのリンクが表示される' do
          comments = find('.comment-index')
          expect(comments).to have_link '詳細', href: "/admin/posts/#{ comment.post.id.to_s }#comment-#{ comment.id.to_s }"
        end
        it 'ユーザーのコメント一覧ページへのリンクが表示される' do
          comments = find('.comment-index')
          expect(comments).to have_link 'すべて見る', href: admin_post_comments_path(user_id: user.id)
        end
        it '他人のコメントは表示されない' do
          expect(page).not_to have_content other_comment.comment
        end
      end

      context 'サイドバーの確認' do
        it 'ユーザーのプロフィールが表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_content user.name
          expect(user_info).to have_content user.introduction
          expect(user_info).to have_content user.email
          expect(user_info).to have_content user.created_at.to_s(:datetime_jp)
          expect(user_info).to have_content '利用可能'
        end
        it 'アカウント凍結ボタンが表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_button 'アカウント凍結'
        end
      end
    end

    describe 'ユーザーアカウント凍結のテスト' do

      before do
        visit admin_user_path(user)
        click_button 'アカウント凍結'
      end

      context 'アカウント凍結のテスト' do
        it 'ユーザーステータスが正しく更新される' do
          expect(user.reload.is_active).to eq false
        end
        it '更新されたユーザーステータスが正しく表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_content '凍結中'
        end
        it '凍結解除ボタンが表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_button 'アカウント凍結解除'
        end
        it '凍結されたアカウントではログインできない' do
          click_link 'ログアウト'
          visit new_user_session_path
          fill_in 'user[email]', with: user.email
          fill_in 'user[password]', with: user.password
          click_button 'ログイン'
          expect(current_path).to eq '/users/sign_in'
          expect(page).to have_content 'アカウントが凍結されています。'
        end
      end
      
      context 'アカウント凍結解除のテスト' do
        
        before do
          click_button 'アカウント凍結解除'
        end
        
        it 'ユーザーステータスが正しく更新される' do
          expect(user.reload.is_active).to eq true
        end
        it '更新されたユーザーステータスが正しく表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_content '利用可能'
        end
        it 'アカウント凍結ボタンが表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_button 'アカウント凍結'
        end
        it '凍結解除されたアカウントでログインできる' do
          click_link 'ログアウト'
          visit new_user_session_path
          fill_in 'user[email]', with: user.email
          fill_in 'user[password]', with: user.password
          click_button 'ログイン'
          expect(current_path).to eq '/home'
          expect(page).to have_content 'ログインしました。'
        end
      end
    end

  end

end