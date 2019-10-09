# myconfig
Use `curl` or `wget` to install packages and configures!  
Both **linux** and **macos** supported!  
  
**NOTE: myconfig will OVERWRITE your `oh-my-zsh`, `vim` and `tmux` configures!**
  
**via curl**
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/toosyou/myconfig/master/install.sh)"
```
  
**via wget**  
```shell
bash -c "$(wget https://raw.githubusercontent.com/toosyou/myconfig/master/install.sh -O -)"
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
    - [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)(with C-family languages support)
- tmux  
    - mouse support  
    - [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (tmux >= 2.3)  
    - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) (tmux >= 2.3)  
    - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) (tmux >= 2.3)  
    - [tmux-yank](https://github.com/tmux-plugins/tmux-yank) (tmux >= 2.3)  
    - [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)(tmux >= 2.3)  
- git
- wget
- python3
- pip3

## If pip or pip3 does not work under Linux machine (Impoer Error: Cannot import name main), please try the following solution:
```
sudo vim /usr/bin/pip3 (or pip)
or
sudo vim $(which pip3) (or $(which pip))
```

and, change from
```
from pip import main
if __name__ == '__main__':
    sys.exit(main())
```

to 

```
from pip import __main__
if __name__ == '__main__':
    sys.exit(__main__._main())
```

# Contact me
- email: toosyou.tw@gmail.com
