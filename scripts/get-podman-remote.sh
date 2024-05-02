#!/bin/bash

owner="containers"
repo="podman"
file_name="podman-remote-static-linux_amd64.tar.gz"

# GitHub APIのエンドポイントURL
api_url="https://api.github.com/repos/${owner}/${repo}/releases/latest"

# APIからリリース情報を取得
release_data=$(curl -s "${api_url}")

# リリースデータからアセットのダウンロードURLを抽出
download_url=$(echo "${release_data}" | grep -oE "https://.*?${file_name}")

# ファイルをダウンロード
if [ -n "${download_url}" ]; then
	curl -L -o "${file_name}" "${download_url}"
	echo "ファイル '${file_name}' がダウンロードされました。"
else
	echo "ファイル '${file_name}' が見つかりませんでした。"
	exit 1


# ファイルを /usr/local に展開
echo "ファイルを /usr/local に展開しています..."
sudo tar -C /usr/local -xzf "${file_name}"
echo "展開が完了しました。"

# ダウンロードしたファイルを削除
rm "${file_name}"
echo "ダウンロードしたファイルを削除しました。"
echo "次のコマンドでpodman machineへの接続を追加してください。"
echo "podman system connection add --default podman-machine-default-root unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock"
echo "sudo usermod --append --groups 10 \$(whoami)"
