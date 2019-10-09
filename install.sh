#!/bin/bash
set -e

#get the root access first and check the OS type
function git_get(){
    original_path=$(pwd)
    if cd $2; then # exists then update it
        git pull && cd $original_path
    else # not exists then clone it
        git clone $1 $2
    fi
}

# check if the user has sudo privilege
while true; do
    read -p "Are you a sudoer? [y/N]: " yn
    case $yn in
        [Yy]* ) is_sudoer=1; break;;
        [Nn]* ) is_sudoer=0; break;;
        "") is_sudoer=0; break;;
        * ) ;;
    esac
done

# install necessary packages
if [ $is_sudoer -eq 1 ]; then
	if [ "$(uname -s)" = "Linux" ]; then
    	echo $(uname -s)
	    sudo apt-get update
	    for i in zsh mosh vim tmux node install git wget python-dev python-pip python3-dev python3-pip nodejs xsel cmake; do
	        sudo apt-get --yes --force-yes -f -m install $i
	    done

	    # fix 'no such file: /usr/local/bin/node' issue
	    sudo ln -s /usr/bin/nodejs /usr/local/bin/node
	elif [ "$(uname -s)" = "Darwin" ]; then # mac
	    echo $(uname -s)

	    # check if brew exists. If not, install it
	    hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	    brew install wget zsh mosh tmux reattach-to-user-namespace
	    brew install git python3 node gnu-sed cmake
        brew install thefuck cmake
        brew install vim && brew install macvim
        brew link macvim

        # Alfons0329 add installation of pip and pip3
        easy_install pip pip3
        brew install git
        npm install -g bower
	else
	    echo $(uname -s)
	    echo "This OS is not supported yet!"
	    exit 0
	fi
fi

# git clone every thing
CLONE_PATH=$HOME/.myconfig
git_get https://github.com/toosyou/myconfig $CLONE_PATH

# install thefuck if not exists
if [ "$(uname -s)" = "Linux" ]; then
    hash thefuck 2>/dev/null || pip3 install --user thefuck
fi

# link tmux configure
min_tmux_version=2.0
tmux_version=$(tmux -V| cut -d" " -f 2| tr -d $'\n'| tr -d $'\r')
tmux_version_check=$(awk "BEGIN{ print ($tmux_version > $min_tmux_version) ? \"1\" : \"0\" }")

if [ $tmux_version_check -eq 0 ];then # use mini tmux configure
    ln -sf $CLONE_PATH/tmux19.conf ~/.tmux.conf
else
    # install tmux-package-manager(TPM)
    git_get https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ln -sf $CLONE_PATH/tmux.conf ~/.tmux.conf

    # install packages
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

# get awsome vim configure
git_get https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
# link my runtime configure
ln -sf $CLONE_PATH/vim_runtimerc.vim  ~/.vim_runtime/my_configs.vim

# install vundle and append vimrc
git_get https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -sf $CLONE_PATH/vundle.vim ~/.vundle.vim
if [ "$(uname -s)" = "Darwin" ]; then # mac
    gsed -i '1isource ~/.vundle.vim'$'\n' ~/.vimrc
else
	sed -i '1isource ~/.vundle.vim'$'\n' ~/.vimrc
fi
if [ "$(uname -s)" = "Darwin" ]; then # mac
    mvim -v +PluginInstall +qall # install plugins
else
    vim +PluginInstall +qall # install plugins
fi

~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# install oh-my-zsh, font, autosuggesion and zsh-syntax-highlighting
ZSH_CUSTOM=~/.oh-my-zsh/custom
# oh-my-zsh
if [ "$(uname -s)" = "Darwin" ]; then # mac
    sh -c "`wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | gsed 's/chsh -s/# chsh -s/g' | gsed 's/env zsh/# env zsh/g'`"
else
    sh -c "`wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sed 's/chsh -s/# chsh -s/g' | sed 's/env zsh/# env zsh/g'`"
fi

wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/templates/zshrc.zsh-template -O ~/.zshrc

# font
mkdir -p $ZSH_CUSTOM/themes
wget -O $ZSH_CUSTOM/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme

if [ "$(uname -s)" = "Darwin" ]; then # mac
    gsed -i 's/ZSH_THEME=/ZSH_THEME="bullet-train" # /g' ~/.zshrc
    gsed -i '1ialias vim="mvim -v"'$'\n' ~/.zshrc
else
	sed -i 's/ZSH_THEME=/ZSH_THEME="bullet-train" # /g' ~/.zshrc
fi

# autosuggesion
git_get git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
if [ "$(uname -s)" = "Darwin" ]; then # mac
    gsed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc
else
	sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc
fi

# zsh-syntax-highlighting
git_get https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [ "$(uname -s)" = "Darwin" ]; then # mac
    gsed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc
else
	sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc
fi

# append .zshrc
echo "source $CLONE_PATH/zshrc" >> ~/.zshrc

# chsh and switch to zsh
USERNAME=`whoami`
printf "Time to change your default shell to zsh!\n"

if [ $is_sudoer -eq 1 -a "$(uname -s)" != "Darwin" ]; then
    sudo usermod -s $(grep /zsh$ /etc/shells | tail -1) $USERNAME
else
    chsh -s $(which zsh)

    # cannot change shell
    if [ $? -ne 0 ]; then
        echo "***************************************"
        echo "******** SHELL CHANGING FAILED ********"
        echo "** Try 'chsh -s $(which zsh)' again! **"
        echo "*** Or contact the admin if failed! ***"
        echo "***************************************"
    fi
fi

env zsh
