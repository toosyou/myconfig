#!/bin/bash

# install necessary packages
if [ `uname -s` == "Linux"];then
    sudo apt-get -y -f -m install zsh mosh vim tmux git wget thefuck
elif [ `uname -s` == "Darwin"];then
    echo "This OS is not supported yet!"
    exit 0
else
    echo "This OS is not supported yet!"
    exit 0
fi

# link tmux configure
ln -s tmux.conf ~/.tmux.conf

# get awsome vim configure
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# install vundle and append vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -s vundle.vim ~/.vundle.vim
sed -i '1s/^/source ~/.vundle.vim\n/' ~/.vimrc
vim +PluginInstall +qall # install plugins

# install oh-my-zsh, font, autosuggesion and zsh-syntax-highlighting
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
# font
wget https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme -O $ZSH_CUSTOM/themes/bullet-train.zsh-theme
sed -i 's/ZSH_THEME="*"/ZSH_THEME="bullet-train"/g' ~/.zshrc
# autosuggesion
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc
# append .zshrc
cat zshrc >> ~/.zshrc
