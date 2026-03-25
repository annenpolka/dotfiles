# dotfiles init.sh E2Eテスト用
# Usage: docker build -t dotfiles-test .

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git bash curl sudo zsh build-essential procps file \
    && rm -rf /var/lib/apt/lists/*

# Homebrewはrootで動かないため非rootユーザーを作成
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# リポジトリをコピーし、git initで.gitを作成（.dockerignoreで.gitを除外しているため）
COPY --chown=testuser:testuser . /home/testuser/dotfiles
RUN cd /home/testuser/dotfiles \
    && git init \
    && git config user.email "test@test.com" \
    && git config user.name "test" \
    && git add -A \
    && git commit -m "docker test"

# init.shを実行
RUN bash /home/testuser/dotfiles/init.sh

# シンボリックリンクの検証
RUN test -L /home/testuser/.zshrc \
    && test -L /home/testuser/.tmux.conf \
    && test -L /home/testuser/.gitconfig \
    && test -L /home/testuser/.config/sheldon \
    && test -L /home/testuser/.config/ghostty \
    && test -L /home/testuser/.claude \
    && test -L /home/testuser/.codex \
    && echo "All symlink checks passed"

# ユニットテストも実行
RUN bash /home/testuser/dotfiles/tests/test.sh

CMD ["zsh", "-l", "-c", "echo 'Bootstrap verified successfully'"]
