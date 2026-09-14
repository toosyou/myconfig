#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# get the root access first and check the OS type
function git_get(){
    original_path=$(pwd)
    if cd $2; then # exists then update it
        git pull && cd $original_path
    else # not exists then clone it
        git clone $1 $2
    fi
}

# prompt for a yes/no toggle unless it's already set via env var (used for
# non-interactive/automated runs, e.g. the Docker test harness)
function prompt_toggle(){
    local var_name=$1
    local prompt_text=$2
    local default=$3 # "Y" or "N"
    eval "local current=\${$var_name:-}"

    if [ -n "$current" ]; then
        return
    fi

    local hint="[y/N]"
    [ "$default" = "Y" ] && hint="[Y/n]"

    while true; do
        read -p "$prompt_text $hint: " yn
        case $yn in
            [Yy]* ) eval "$var_name=1"; break;;
            [Nn]* ) eval "$var_name=0"; break;;
            "" )
                if [ "$default" = "Y" ]; then eval "$var_name=1"; else eval "$var_name=0"; fi
                break;;
            * ) ;;
        esac
    done
}

# clone/update this repo, or copy it from a local path (MYCONFIG_SOURCE_PATH)
# when testing local changes instead of what's on GitHub
function get_myconfig(){
    if [ -n "$MYCONFIG_SOURCE_PATH" ]; then
        rm -rf $CLONE_PATH
        cp -a "$MYCONFIG_SOURCE_PATH" $CLONE_PATH
    else
        git_get https://github.com/toosyou/myconfig $CLONE_PATH
    fi
}

prompt_toggle MYCONFIG_SUDOER "Are you a sudoer?" N
prompt_toggle MYCONFIG_INSTALL_PACKAGES "Install base packages via apt-get (zsh, vim, tmux, git, ...)?" Y
prompt_toggle MYCONFIG_INSTALL_ZSH "Set up zsh + oh-my-zsh?" Y
prompt_toggle MYCONFIG_INSTALL_VIM "Set up vim + Vundle?" Y
prompt_toggle MYCONFIG_INSTALL_TMUX "Set up tmux?" Y

is_sudoer=$MYCONFIG_SUDOER

# install necessary packages
if [ "$is_sudoer" -eq 1 ] && [ "$MYCONFIG_INSTALL_PACKAGES" -eq 1 ]; then
    packages=(
        zsh
        mosh
        vim
        vim-nox
        tmux
        git
        wget
        curl
        python3-dev
        python3-pip
        xsel
    )

    sudo apt-get update

    for package in "${packages[@]}"; do
        sudo DEBIAN_FRONTEND=noninteractive apt-get --yes -f -m install "$package"
    done
fi

USERNAME=`whoami`

# git clone every thing
CLONE_PATH=$HOME/.myconfig
get_myconfig

# link tmux configure
if [ "$MYCONFIG_INSTALL_TMUX" -eq 1 ]; then
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
fi

if [ "$MYCONFIG_INSTALL_VIM" -eq 1 ]; then
    # get awsome vim configure
    git_get https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    # link my runtime configure
    ln -sf $CLONE_PATH/vim_runtimerc.vim  ~/.vim_runtime/my_configs.vim

    # install vundle and append vimrc
    git_get https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    ln -sf $CLONE_PATH/vundle.vim ~/.vundle.vim
    sed -i '1isource ~/.vundle.vim'$'\n' ~/.vimrc
    vim +PluginInstall +qall # install plugins

    # fix vim_mru_files
    if [ "`stat -c %U ~/.vim_mru_files`" = "root" ]; then
        sudo chown $USERNAME:$USERNAME ~/.vim_mru_files
    fi
fi

if [ "$MYCONFIG_INSTALL_ZSH" -eq 1 ]; then
    # install oh-my-zsh, font, autosuggesion and zsh-syntax-highlighting
    ZSH_CUSTOM=~/.oh-my-zsh/custom
    # oh-my-zsh
    RUNZSH='no' CHSH='no' sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

    curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/templates/zshrc.zsh-template -o ~/.zshrc

    # font
    mkdir -p $ZSH_CUSTOM/themes
    curl -o $ZSH_CUSTOM/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme

    sed -i 's/ZSH_THEME=/ZSH_THEME="bullet-train" # /g' ~/.zshrc

    # autosuggesion
    git_get https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc

    # zsh-syntax-highlighting
    git_get https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc

    # append .zshrc
    echo "source $CLONE_PATH/zshrc" >> ~/.zshrc

    # move the cache file to $ZSH/cache/
    sed -i 's/source $ZSH\/oh-my-zsh.sh/export ZSH_COMPDUMP=$ZSH\/cache\/.zcompdump-$HOST\n&/' ~/.zshrc

    # chsh and switch to zsh
    printf "Time to change your default shell to zsh!\n"

    if [ "$is_sudoer" -eq 1 ]; then
        sudo usermod -s $(grep /zsh$ /etc/shells | tail -1) $USERNAME
    else
        echo $(which zsh) | sudo tee -a /etc/shells >/dev/null
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

    # only drop into an interactive zsh session when actually attached to a
    # terminal (keeps non-interactive/automated runs, e.g. the Docker test,
    # from hanging at the end)
    if [ -t 1 ]; then
        env zsh
    fi
fi
