GOTO
====

## Basics 

cd path

git clone https://github.com/grizzlysmit/gzz-goto.git

cd

mkdir rakulib

cd rakulib

ln -s path/gzz-goto/rakulib/Paths.rakumod

cd

mkdir bin

cd bin

ln -s path/gzz-goto/bin/paths.raku

make sure $HOME/bin is in your search path.
and also raku needs to be installed.

## To use  from bash

cd

ln -s path/gzz-goto/bash_aliases

gvim -p .bashrc

add 

if [ -e "$HOME/bash_aliases" ]
then
    source ~/.bash_aliases
fi



## To use from elvish

use epm

epm:install github.com/grizzlysmit/gzz-goto.git

add this to your rc.elv

use 
