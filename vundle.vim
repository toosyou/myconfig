set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'Raimondi/delimitMate'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'

call vundle#end()
filetype plugin indent on

let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'
let g:ycm_completion_confirm_key = '<enter>'

set mouse=a
set number
set foldenable
set foldmethod=syntax
set foldcolumn=1
set foldlevel=5
hi Folded ctermfg=green

let g:ycm_python_binary_path = '/usr/bin/python3'
