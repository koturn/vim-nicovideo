vim-nicovideo
=============

Vimでニコニコ動画を見ることができます！
(※単なる[mplayer](http://www.mplayerhq.hu/design7/news.html)のフロントエンドプラグインです)

以下のパクりです．

- [percol (peco)でニコニコ動画を選択して再生する - Qiita](http://qiita.com/tigberd/items/9530714391340472ad96)


## Usage

ニコニコ動画にログインする必要があるので，まず.vimrcで次の変数にそれぞれ
ニコニコ動画の登録に用いたメールアドレスとパスワードを代入してください．

```vim
" メールアドレス
let g:nicovideo#mail_address = 'xxx.yyy.zzz@dummy.mail'
" パスワード
let g:nicovideo#password = 'xyzwXYZW1234'
```

以上で下準備は完了です．

基本機能として，ニコニコ動画のURL，もしくは動画IDを指定すると，その動画を再生
するコマンドを実装しています．
このコマンドを実行すると，動画API(getflv)を通じて，指定された動画のURLを取得し，
そのデータをmplayerに流すことで，動画を再生します．

```vim
:NicoVideo http://www.nicovideo.jp/watch/sm12345678
```

```vim
:NicoVideo sm12345678
```

また，[unite.vim](https://github.com/Shougo/unite.vim)にも対応しており，動画の
ランキングから選択して，動画を再生することができます．


まず，以下のコマンドを実行して，ランキングのRSSを取得してください．
(XMLのパースにやや時間を要します)

```vim
:NicoVideoUpdateRanking
```

次に，以下のコマンドを実行することで，ランキングのリストが表示されます．
好きな動画を選択して，動画を再生してください．

```vim
:Unite nicovideo
```


## Dependent plugins

- [vimproc.vim](https://github.com/Shougo/vimproc.vim)
- [unite.vim](https://github.com/Shougo/unite.vim)


## Requirements

- [curl](http://curl.haxx.se/)
- [mplayer](http://www.mplayerhq.hu/design7/news.html)


## References

- [percol (peco)でニコニコ動画を選択して再生する - Qiita](http://qiita.com/tigberd/items/9530714391340472ad96)


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
