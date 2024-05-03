FROM ubuntu:latest

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    bash \
    findutils

# ローカルからリポジトリをコピー
COPY . /root/dotfiles

# スクリプトに実行権限を付与
RUN chmod +x /root/dotfiles/scripts/dotfiles_symlink.sh

# スクリプトを実行
CMD ["/root/dotfiles/scripts/dotfiles_symlink.sh"]
