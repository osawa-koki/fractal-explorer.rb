#!/bin/bash

# appディレクトリ以下の全てのファイルのパスを取得
file_paths=($(find ./app -type f))

# 配列内のファイルパスを出力
for file_path in "${file_paths[@]}"
do
  echo "file path: $file_path"
  ruby "$file_path"
done
