set nocompatible
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'Raimondi/delimitMate'

call vundle#end()
filetype plugin indent on

set number
set foldenable
set foldmethod=syntax
set foldcolumn=1
set foldlevel=5
hi Folded ctermfg=green
