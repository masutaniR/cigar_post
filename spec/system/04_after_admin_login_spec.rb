require 'rails_helper'

describe '管理者画面のテスト', js: true do

  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post) { create(:post, user_id: user.id) }
  let!(:other_post) { create(:post, user_id: other_user.id) }
  let!(:comment) { create(:post_comment, user_id: user.id, post_id: other_post.id) }
  let!(:other_comment) { create(:post_comment, user_id: other_user.id, post_id: post.id) }
  let!(:info) { create(:information) }

  before do
    visit new_admin_session_path
  end

  describe 'ヘッダーのテスト：管理者ログイン前' do

    context '表示内容の確認' do
      it 'サイト名が表示される' do
        header = find('header')
        expect(header).to have_content 'CigarPost'
      end
      it 'サイト名のリンクの内容が正しい' do
        header = find('header')
        expect(header).to have_link 'CigarPost', href: root_path
      end
      it 'ユーザー新規登録リンクが表示される' do
        header = find('header')
        expect(header).to have_link '新規登録', href: new_user_registration_path
      end
      it 'ユーザーログインリンクが表示される' do
        header = find('header')
        expect(header).to have_link 'ログイン', href: new_user_session_path
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
          header = find('header')
          expect(header).to have_content 'CigarPost'
        end
        it 'サイト名のリンクの内容が正しい' do
          header = find('header')
          expect(header).to have_link 'CigarPost', href: admin_users_path
        end
        it 'ユーザー一覧リンクが表示される' do
          header = find('header')
          expect(header).to have_link 'ユーザー', href: admin_users_path
        end
        it '投稿一覧リンクが表示される' do
          header = find('header')
          expect(header).to have_link '投稿', href: admin_posts_path
        end
        it 'コメント一覧リンクが表示される' do
          header = find('header')
          expect(header).to have_link 'コメント', href: admin_post_comments_path
        end
        it 'お知らせ一覧リンクが表示される' do
          header = find('header')
          expect(header).to have_link 'お知らせ', href: admin_information_index_path
        end
        it 'ログアウトリンクが表示される' do
          header = find('header')
          expect(header).to have_link 'ログアウト', href: destroy_admin_session_path
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
        click_button '凍結する'
      end

      context 'アカウント凍結のテスト' do
        it 'ユーザー詳細ページにリダイレクトされる' do
          expect(current_path).to eq "/admin/users/#{ user.id.to_s }"
        end
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
          click_button '解除する'
        end

        it 'ユーザー詳細ページにリダイレクトされる' do
          expect(current_path).to eq "/admin/users/#{ user.id.to_s }"
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

    describe '投稿一覧画面のテスト' do

      before do
        visit admin_posts_path
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/admin/posts'
        end
        it '新着投稿が一番上に表示される' do
          top_post = find_all('tr')[1]
          expect(top_post).to have_content other_post.body
        end
        it '各投稿者の名前が表示される' do
          expect(page).to have_content user.name
          expect(page).to have_content other_user.name
        end
        it '投稿者名のリンクが正しい' do
          expect(page).to have_link user.name, href: admin_user_path(user)
          expect(page).to have_link other_user.name, href: admin_user_path(other_user)
        end
        it '投稿カテゴリーが表示される' do
          expect(page).to have_content post.category_i18n
          expect(page).to have_content other_post.category_i18n
        end
        it '投稿本文が表示される' do
          expect(page).to have_content post.body
          expect(page).to have_content other_post.body
        end
        it '投稿詳細ページへのリンクが表示される' do
          expect(page).to have_link '詳細', href: admin_post_path(post)
          expect(page).to have_link '詳細', href: admin_post_path(other_post)
        end
      end
    end

    describe '投稿詳細ページのテスト' do

      before do
        visit admin_post_path(post)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq "/admin/posts/#{ post.id.to_s }"
        end
        it '投稿削除ボタンが表示される' do
          expect(page).to have_link '投稿を削除', href: admin_post_path(post)
        end
        it 'プロフィール画像と名前のリンクが正しい' do
          post_detail = find('.main-contents')
          expect(post_detail).to have_link user.name, href: admin_user_path(user)
        end
        it '投稿のカテゴリが表示される' do
          expect(page).to have_content post.category_i18n
        end
        it '投稿の本文が表示される' do
          expect(page).to have_content post.body
        end
        it 'サイドバーに投稿者のプロフィールが表示される' do
          user_info = find('.user-info')
          expect(user_info).to have_content user.name
          expect(user_info).to have_content user.introduction
          expect(user_info).to have_content user.email
          expect(user_info).to have_content user.created_at.to_s(:datetime_jp)
          expect(user_info).to have_content '利用可能'
        end
        it 'コメント一覧が表示される' do
          comment_box = find('#comment-container')
          expect(comment_box).to have_content 'コメント一覧'
        end
      end

      context '投稿削除のテスト' do

        before do
          click_link '投稿を削除'
          click_button '削除する'
        end

        it '投稿が正しく削除される' do
          expect(Post.where(id: post.id).count).to eq 0
        end
        it '削除後のリダイレクト先が投稿一覧になっている' do
          expect(current_path).to eq '/admin/posts'
        end
      end

      context 'コメント一覧表示の確認' do
        it 'コメント投稿者のプロフィール画像と名前のリンクが正しい' do
          comment_box = find('#comment-container')
          expect(comment_box).to have_link other_user.name, href: admin_user_path(other_user)
        end
        it 'コメントのカテゴリが表示される' do
          expect(page).to have_content other_comment.category_i18n
        end
        it 'コメント本文が表示される' do
          expect(page).to have_content other_comment.comment
        end
        it 'コメント削除ボタンが表示される' do
          expect(page).to have_link 'コメントを削除', href: admin_post_post_comment_path(post, other_comment)
        end
      end
    end

    describe 'コメント一覧画面のテスト' do

      before do
        visit admin_post_comments_path
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/admin/post_comments'
        end
        it '新着投稿が一番上に表示される' do
          top_comment = find_all('tr')[1]
          expect(top_comment).to have_content other_comment.comment
        end
        it '各コメント投稿者の名前が表示される' do
          expect(page).to have_content user.name
          expect(page).to have_content other_user.name
        end
        it 'コメント投稿者名のリンクが正しい' do
          expect(page).to have_link user.name, href: admin_user_path(user)
          expect(page).to have_link other_user.name, href: admin_user_path(other_user)
        end
        it 'コメントカテゴリーが表示される' do
          expect(page).to have_content comment.category_i18n
          expect(page).to have_content other_comment.category_i18n
        end
        it 'コメント本文が表示される' do
          expect(page).to have_content comment.comment
          expect(page).to have_content other_comment.comment
        end
        it '投稿詳細ページへのリンクが表示される' do
          expect(page).to have_link '詳細', href: "/admin/posts/#{ comment.post.id.to_s }#comment-#{ comment.id.to_s }"
          expect(page).to have_link '詳細', href: "/admin/posts/#{ other_comment.post.id.to_s }#comment-#{ other_comment.id.to_s }"
        end
      end
    end

    describe 'お知らせ一覧画面のテスト' do

      before do
        visit admin_information_index_path
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/admin/information'
        end
        it 'お知らせ新規投稿ページへのリンクが表示される' do
          expect(page).to have_link '新規投稿', href: new_admin_information_path
        end
        it 'お知らせのタイトルが表示される' do
          expect(page).to have_content info.title
        end
        it 'お知らせのリンクが正しい' do
          expect(page).to have_link info.title, href: admin_information_path(info)
        end
      end
    end

    describe 'お知らせ新規投稿のテスト' do

      before do
        visit new_admin_information_path
      end

      context '新規投稿画面表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/admin/information/new'
        end
        it 'titleフォームが表示される' do
          expect(page).to have_field 'information[title]'
        end
        it 'bodyフォームが表示される' do
          expect(page).to have_field 'information[body]'
        end
        it '確認ボタンが表示される' do
          expect(page).to have_button '確認画面へ'
        end
      end

      context '確認画面のテスト' do

        before do
          @new_info_title = Faker::Lorem.characters(number: 15)
          @new_info_body = Faker::Lorem.characters(number: 500)
          fill_in 'information[title]', with: @new_info_title
          fill_in 'information[body]', with: @new_info_body
          click_button '確認画面へ'
        end

        it '投稿前のお知らせが表示される' do
          expect(page).to have_content @new_info_title
          expect(page).to have_content @new_info_body
        end
        it 'お知らせはまだ保存されていない' do
          expect(Information.all.count).to eq 1
        end
        it '送信ボタンが表示される' do
          expect(page).to have_button '送信'
        end
        it '戻るボタンが表示される' do
          expect(page).to have_button '入力画面に戻る'
        end
      end

      context '入力画面に戻るテスト' do

        before do
          @new_info_title = Faker::Lorem.characters(number: 15)
          @new_info_body = Faker::Lorem.characters(number: 500)
          fill_in 'information[title]', with: @new_info_title
          fill_in 'information[body]', with: @new_info_body
          click_button '確認画面へ'
          click_button '入力画面に戻る'
        end

        it 'titleフォームに入力した内容が表示される' do
          expect(page).to have_field 'information[title]', with: @new_info_title
        end
        it 'bodyフォームに入力した内容が表示される' do
          expect(page).to have_field 'information[body]', with: @new_info_body
        end
        it '確認ボタンが表示される' do
          expect(page).to have_button '確認画面へ'
        end
      end

      context '新規投稿のテスト' do

        before do
          @new_info_title = Faker::Lorem.characters(number: 15)
          @new_info_body = Faker::Lorem.characters(number: 500)
          fill_in 'information[title]', with: @new_info_title
          fill_in 'information[body]', with: @new_info_body
          click_button '確認画面へ'
        end

        it '新しい投稿が正しく保存される' do
          expect{ click_button '送信' }.to change{ Information.count }.by(1)
        end
        it 'リダイレクト先がお知らせ詳細ページになっている' do
          click_button '送信'
          expect(current_path).to eq "/admin/information/#{ Information.last.id.to_s }"
        end
        it '投稿されたお知らせがトップ画面に表示される' do
          click_button '送信'
          click_link 'ログアウト'
          visit root_path
          expect(page).to have_link @new_info_title, href: "/information/#{ Information.last.id.to_s }"
        end
      end
    end

    describe 'お知らせ詳細ページのテスト' do

      before do
        visit admin_information_path(info)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq "/admin/information/#{ info.id.to_s }"
        end
        it '投稿日時が表示される' do
          expect(page).to have_content info.created_at.to_s(:datetime_jp)
        end
        it 'お知らせのタイトルが表示される' do
          expect(page).to have_content info.title
        end
        it 'お知らせの本文が表示される' do
          expect(page).to have_content info.body
        end
        it 'お知らせ編集ボタンが表示される' do
          expect(page).to have_link '編集', href: edit_admin_information_path(info)
        end
        it 'お知らせ削除ボタンが表示される' do
          expect(page).to have_link '削除', href: admin_information_path(info)
        end
      end

      context 'お知らせ削除テスト' do

        before do
          click_link '削除'
          click_button '削除する'
        end

        it 'お知らせが正しく削除される' do
          expect(Information.where(id: info.id).count).to eq 0
        end
        it '削除後のリダイレクト先がお知らせ一覧になっている' do
          expect(current_path).to eq '/admin/information'
        end
        it '削除されたお知らせはトップ画面に表示されない' do
          click_link 'ログアウト'
          visit root_path
          expect(page).not_to have_content info.title
        end
      end
    end

    describe 'お知らせ編集ページのテスト' do

      before do
        visit admin_information_path(info)
        click_link '編集'
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq "/admin/information/#{ info.id.to_s }/edit"
        end
        it 'title編集フォームに入力した内容が表示される' do
          expect(page).to have_field 'information[title]', with: info.title
        end
        it 'bodyフォームに入力した内容が表示される' do
          expect(page).to have_field 'information[body]', with: info.body
        end
        it '変更ボタンが表示される' do
          expect(page).to have_button '変更'
        end
      end

      context '更新成功のテスト' do

        before do
          @old_title = info.title
          @old_body = info.body
          @new_title = Faker::Lorem.characters(number: 8)
          @new_body = Faker::Lorem.characters(number: 600)
          fill_in 'information[title]', with: @new_title
          fill_in 'information[body]', with: @new_body
          click_button '変更'
          click_button '更新'
        end

        it 'titleが正しく更新される' do
          expect(info.reload.title).not_to eq @old_title
          expect(info.reload.title).to eq @new_title
        end
        it 'bodyが正しく更新される' do
          expect(info.reload.body).not_to eq @old_body
          expect(info.reload.body).to eq @new_body
        end
        it '更新後、お知らせ詳細画面にリダイレクトする' do
          expect(current_path).to eq "/admin/information/#{ info.id.to_s }"
        end
        it 'お知らせ詳細に更新日時が表示される' do
          expect(page).to have_content info.updated_at.to_s(:datetime_jp)
        end
        it '更新されたお知らせがトップ画面に表示される' do
          click_link 'ログアウト'
          visit root_path
          expect(page).not_to have_content @old_title
          expect(page).to have_link @new_title, href: "/information/#{ info.id.to_s }"
        end
      end
    end

  end

end