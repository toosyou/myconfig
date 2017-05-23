#!/bin/bash

# install necessary packages
if [ "$(uname -s)" = "Linux" ]; then
    sudo apt-get update
    sudo apt-get --yes --force-yes -f -m install zsh mosh vim tmux bc
    sudo apt-get --yes --force-yes -f -m git wget python3-dev python3-pip
elif [ "$(uname -s)" = "Darwin" ]; then
    echo $(uname -s)
    echo "This OS is not supported yet!"
    exit 0
else
    echo $(uname -s)
    echo "This OS is not supported yet!"
    exit 0
fi

# install thefuck
pip3 install --user thefuck

# link tmux configure
if [ $( echo "$(tmux -V| cut -d" " -f 2| tr -d $'\n'| tr -d $'\r') <= 2.3 " | bc -l ) -eq 1 ];then
    ln -sf `pwd`/tmux19.conf ~/.tmux.conf
else
    ln -sf `pwd`/tmux.conf ~/.tmux.conf
fi

# get awsome vim configure
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# install vundle and append vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -sf `pwd`/vundle.vim ~/.vundle.vim
sed -i '1isource ~/.vundle.vim\n' ~/.vimrc
vim +PluginInstall +qall # install plugins

# install oh-my-zsh, font, autosuggesion and zsh-syntax-highlighting
ZSH_CUSTOM=~/.oh-my-zsh/custom
# oh-my-zsh
sh -c "`wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sed 's/chsh -s/# chsh -s/g' | sed 's/env zsh/# env zsh/g'`"
wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/templates/zshrc.zsh-template -O ~/.zshrc
# font
mkdir -p $ZSH_CUSTOM/themes
wget -O $ZSH_CUSTOM/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
sed -i 's/ZSH_THEME=/ZSH_THEME="bullet-train" # /g' ~/.zshrc
# autosuggesion
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc
# append .zshrc
cat zshrc >> ~/.zshrc

# chsh and switch to zsh
printf "Time to change your default shell to zsh!\n"
chsh -s $(grep /zsh$ /etc/shells | tail -1)
env zsh
