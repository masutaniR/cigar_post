$(document).on('turbolinks:load', function () {
  $(function () {
    // 画像をプレビュー表示させる.prev-contentを作成
    function buildHTML(image) {
      var html =
        `
        <div class="post-prev-content">
          <img src="${image}", alt="preview" class="post-prev-image rounded">
        </div>
        `
      return html;
    }

    // 画像が選択された時に発火
    $('.post-img-field').on('change', function () {
      // .file_filedからデータを取得して変数fileに代入
      var file = this.files[0];
      // FileReaderオブジェクトを作成
      var reader = new FileReader();
      // DataURIScheme文字列を取得
      reader.readAsDataURL(file);
      // 読み込みが完了したら処理を実行
      reader.onload = function () {
        // 読み込んだファイルの内容を取得して変数imageに代入
        var image = this.result;
        // プレビュー画像がなければ処理を実行
        if ($('.post-prev-content').length == 0) {
          // 読み込んだ画像ファイルをbuildHTMLに渡す
          var html = buildHTML(image)
          // 作成した.prev-contentをiconの代わりに表示
          $('.post-prev-contents').prepend(html);
          // 画像が表示されるのでiconを隠す
          $('.post-no-photo').hide();
        } else {
          // もし既に画像がプレビューされていれば画像データのみ入れ替え
          $('.post-prev-content .post-prev-image').attr({ src: image });
        }
      }
    });
  });
});