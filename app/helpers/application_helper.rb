module ApplicationHelper
  # ページごとに表示名を変える
  def full_title(page_title = "")
    base_title = 'CigarPost'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  # 検索ワードと合致するキーワードを太字にする
  def emphasize_keyword(body, keyword)
    highlight(body, keyword, :highlighter => '<strong>\1</strong>')
  end
end
