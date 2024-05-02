FROM ubuntu:latest

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    bash \
    findutils

# dotfilesリポジトリのクローン
RUN git clone https://github.com/annenpolka/dotfiles.git /root/dotfiles

# Bashスクリプトをコンテナにコピー
COPY scripts/dotfiles_symlink.sh /root/dotfiles_symlink.sh

# スクリプトに実行権限を付与
RUN chmod +x /root/dotfiles_symlink.sh

# スクリプトを実行
CMD ["/root/dotfiles_symlink.sh"]
