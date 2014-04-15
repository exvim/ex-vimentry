# Intro

ex-vimentry is the vimentry file parser. When you open the file with suffix   
`.exvim`, `.vimentry` or `.vimproject`, ex-vimentry will automatically parse
the content in it, and apply the settings once Vim started.

More details, check `:help vimentry`.

## Requirements

- Vim 7.0 or higher.
- [exvim/ex-utility](https://github.com/exvim/ex-utility) 

## Installation

ex-vimentry is written based on [exvim/ex-utility](https://github.com/exvim/ex-utility). This 
is the basic library of ex-vim-plugins. Follow the readme file in ex-utility
and install it first.

ex-vimentry follows the standard runtime path structure, and as such it can 
be installed with a variety of plugin managers:
    
To install using [Vundle](https://github.com/gmarik/vundle):

    # add this line to your .vimrc file
    Bundle 'exvim/ex-vimentry'

To install using [Pathogen](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone https://github.com/exvim/ex-vimentry

To install using [NeoBundle](https://github.com/Shougo/neobundle.vim):

    # add this line to your .vimrc file
    NeoBundle 'exvim/ex-vimentry'

[Download zip file](https://github.com/exvim/ex-vimentry/archive/master.zip):

    cd ~/.vim
    unzip ex-vimentry-master.zip
    copy all of the files into your ~/.vim directory

## Syntax
