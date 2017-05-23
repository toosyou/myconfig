# myconfig
Use `curl` or `wget` to install packages and configures!  
Both **linux** and **macos** supported!  
  
**NOTE: myconfig will OVERWRITE you `oh-my-zsh`, `vim` and `tmux` configures!**
  
**via curl**
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/toosyou/myconfig/master/install.sh)"
```
  
**via wget**  
```shell
sh -c "$(wget https://raw.githubusercontent.com/toosyou/myconfig/master/install.sh -O -)"
```

## Snapshots
### Ubuntu 14.04 LTS
![ubuntu.gif](https://github.com/toosyou/myconfig/blob/master/ubuntu.gif)  
- Only **one** password is needed to sudo `apt-get` and `chsh`.  
- Whole installation lasts about **one** minute, and you're ready to roll!  

# Installed packages
- [brew](https://brew.sh/) (macos only)
- zsh  
    - [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)  
    - [bullet-train.zsh](https://github.com/caiogondim/bullet-train.zsh)  
      - Which needs powerline compatible fonts like [Vim Powerline patched fonts](https://github.com/Lokaltog/powerline-fonts), [Input Mono](http://input.fontbureau.com/) or [Monoid](http://larsenwork.com/monoid/).  
    - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)  
    - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)  
    - some **aliases** with commands that I always type wrong.  
- [mosh](https://mosh.org/)
- [thefuck](https://github.com/nvbn/thefuck)
- vim  
    - [Vundle](https://github.com/VundleVim/Vundle.vim)  
    - [The ultimate Vim configuration: vimrc](https://github.com/amix/vimrc)  
    - [delimitMate](https://github.com/Raimondi/delimitMate)  
- tmux  
    - mouse support  
    - [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (tmux >= 2.3)  
    - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) (tmux >= 2.3)  
    - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) (tmux >= 2.3)  
    - [tmux-yank](https://github.com/tmux-plugins/tmux-yank) (tmux >= 2.3)  
    - [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)(tmux >= 2.3)  
- bc
- git
- wget
- python3
- pip3

# Contact me
- email: toosyou.tw@gmail.com
