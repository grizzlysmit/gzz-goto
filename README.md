GOTO
====

## Basics 

To set up the underpinings 

```sh
cd <path>

git clone https://github.com/grizzlysmit/gzz-goto.git

cd

mkdir rakulib

cd rakulib

ln -s <path>/gzz-goto/rakulib/Paths.rakumod

cd

mkdir bin

cd bin

ln -s <path>/gzz-goto/bin/paths.raku
```

where `<path>` is the path you have chosen to clone the github repository to.

 - make sure $HOME/bin is in your search path, and also raku needs to be installed.

## config files 

if you have sysamin privaliges you may want to put config files in `/etc/skel/.local/share/paths/`

just run 
```sh
sudo cp -rv <path>/.local/ /etc/skel/
```

## To use  from bash

```sh
cd

ln -s <path>/gzz-goto/bash_aliases ~/.goto_bash_aliases

or

ln -s <path>/gzz-goto/bash_aliases ~/.prefered_name 

and adjust bellow.

gvim -p ~/.bashrc
# or use another editor of your choice.
```

add 

```sh
if [ -e "$HOME/.goto_bash_aliases" ]
then
    # shellcheck disable=SC1090
    source ~/.goto_bash_aliases
fi
```

line `# shellcheck disable=SC1090` for those who use shellcheck linter ideally you should use it or something equivalent 

## To use from elvish

```elvish
use epm

epm:install github.com/grizzlysmit/gzz-goto
```

add this to your rc.elv

 - these four lines are optional if you have done the epm:install above then  this is redundant but if you want your rc.elv to be portable then add them anyway

```elvish
use epm

epm:install &silent-if-installed         ^
     github.com/grizzlysmit/gzz-goto
```

 - definately add these lines.

```elvish
use github.com/grizzlysmit/gzz-goto/gt

fn goto {|@_args|
    gt:goto $@_args
}
```
