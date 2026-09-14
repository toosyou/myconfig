#!/bin/bash
# Builds the Dockerfile and runs install.sh end-to-end inside it as a
# non-root, passwordless-sudo user, then asserts on the resulting state.
# MYCONFIG_SOURCE_PATH (baked into the image) points install.sh at this
# checked-out working tree instead of GitHub, so it tests local changes.
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_TAG=myconfig-test

docker build -t "$IMAGE_TAG" .

docker run --rm "$IMAGE_TAG" bash -c '
set -e
bash /home/tester/myconfig-src/install.sh

echo "--- checking results ---"
fail() { echo "FAIL: $1" >&2; exit 1; }

shell=$(getent passwd "$(whoami)" | cut -d: -f7)
[ "$shell" = "$(which zsh)" ] || fail "login shell is $shell, expected $(which zsh)"

[ -L ~/.tmux.conf ] || fail "~/.tmux.conf is not a symlink"
readlink -f ~/.tmux.conf | grep -q "myconfig/tmux.conf" || fail "~/.tmux.conf does not point at myconfig tmux.conf"

grep -q "source ~/.vundle.vim" ~/.vimrc || fail "~/.vimrc does not source ~/.vundle.vim"
[ -d ~/.vim/bundle/Vundle.vim ] || fail "Vundle.vim not installed"
[ -d ~/.vim/bundle/delimitMate ] || fail "delimitMate not installed"
[ -d ~/.vim/bundle/vim-gitgutter ] || fail "vim-gitgutter not installed"

[ -d ~/.oh-my-zsh ] || fail "oh-my-zsh not installed"
grep -q "source .*/.myconfig/zshrc" ~/.zshrc || fail "~/.zshrc does not source myconfig zshrc"

echo "ALL CHECKS PASSED"
'
