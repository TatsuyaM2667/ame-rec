# ame-rec

画面を動画に録る小さなコマンド(wf-recorder の代わり)。

[ame-shell](https://github.com/TatsuyaM2667/ame-shell)(Wayland のデスクトップシェル)の一部を、単独で使えるように切り出したものです。
ame-shell は画面の要らない仕事を、1 つのことをして標準入出力でやりとりする小さなコマンドに分けています。これはその 1 つです。

## 使い方

```text
ame-rec: 画面を動画に録る(wf-recorder の代わり)。

  ame-rec -f 保存先.mp4 [-o 出力の名前] [-r 1 秒のコマ数] [--no-audio] [--cpu]

撮るのは自分(ext-image-copy-capture-v1。画面が変わったときだけ 1 コマ)、動画にするのは ffmpeg(標準入力に生の画素を流す)。
音は既定の出力で鳴っている音(PulseAudio の口の @DEFAULT_MONITOR@)。
変換は GPU(VAAPI の h264)を先に試し、使えなければ CPU(libx264)。--cpu で初めから CPU。
止めるのは SIGINT / SIGTERM(ffmpeg に終わりを伝え、ファイルを閉じてから終わる)。
終了コード: 0 保存した / 1 画面につながらない・撮れない・ffmpeg が無い / 2 使い方の誤り
```

## ビルド

```sh
zig build -Doptimize=ReleaseSafe   # zig-out/bin(Zig 0.13、libc・wayland-client・wayland-scanner)
zig build test
```

実行に要るもの: `ffmpeg`

## このリポジトリについて

正本は ame-shell の `src/cmd/ame-rec.zig` です。このリポジトリは `scripts/split-repos.sh` が生成して同期しています。
直したいところがあれば ame-shell の方へお願いします。

ライセンス: GPL-3.0(ame-shell と同じ)
