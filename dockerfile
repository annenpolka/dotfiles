FROM ubuntu:latest

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y git

# dotfilesリポジトリをクローン
RUN git clone https://github.com/annenpolka/dotfiles.git /app/dotfiles

# スクリプトをコンテナにコピー
COPY init.sh /app/init.sh

# スクリプトに実行権限を付与
RUN chmod +x /app/init.sh

# デフォルトのワークディレクトリを設定
WORKDIR /app

# コンテナ起動時のデフォルトコマンドを設定
CMD ["/bin/bash"]