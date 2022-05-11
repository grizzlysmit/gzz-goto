GOTO
====

## Basics 

To set up the underpinings 

```sh
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
```

 - make sure $HOME/bin is in your search path, and also raku needs to be installed.

## To use  from bash

```sh
cd

ln -s path/gzz-goto/bash_aliases

gvim -p .bashrc

add 

if [ -e "$HOME/bash_aliases" ]
then
    source ~/.bash_aliases
fi
```

## To use from elvish

```elv
use epm

epm:install github.com/grizzlysmit/gzz-goto
```

add this to your rc.elv

 - these two lines are optional if you have done the epm:install above then  this is redundant but if you want your rc.elv to be portable then add them anyway

```elv
use epm

epm:install &silent-if-installed         ^
     github.com/grizzlysmit/gzz-goto
```

 - definately add these lines.

```elv
use github.com/grizzlysmit/gzz-goto/gt

fn goto {|@_args|
    gt:goto $@_args
}
```
