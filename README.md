Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [class Gzz_readline](#class-gzz_readline) or [on raku.land class Gzz_readline](#class-gzz-readline)

NAME
====

goto 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.0

TITLE
=====

goto

SUBTITLE
========

GOTO is a cd alternative that acts like a database of bookmarks to different places in the directory tree.

```elvish
use github.com/grizzlysmit/gzz-goto/gt
fn goto {|@_args|
    gt:goto $@_args
}

fn g {|@_args|
    gt:g $@_args
}
```

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/gzz-goto/gt/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

GOTO is a mixture of a Raku app path.raku and a module Paths.rakumod that implements it and a set of script to apply them inside a shell instance This is important as you need the scripts to call cd from within the shell process in order to actually change it's current directory otherwise we would only change a subprocesses current directory and then nothing would have been achieved on exit. The scripts are .goto_bash_aliases -> /home/grizzlysmit/Projects/elvish/gzz-goto/bash_aliases in bash and the combination of some lines in your rc.elv file and a elevish module gt.elv.

[See gzz-goto/gt](https://github.com/grizzlysmit/gzz-goto/gt).

multi sub MAIN(Str:D $key --> int)
----------------------------------

```raku
multi sub MAIN(Str:D $key --> int){
    say path($key);
    return 0;
}
```

[Top of Document](#table-of-contents)

GOTO
----

### Basics from github

To set up the underpinings 

```bash
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

where **path** is the path you have chosen to clone the github repository to.

  * make sure $HOME/bin is in your search path, and also raku needs to be installed.

config files 
-------------

if you have sysamin privaliges you may want to put config files in `/etc/skel/.local/share/paths/`

just run 

```bash
sudo cp -rv <path>/.local/ /etc/skel/
```

To use from bash
----------------

```bash
cd

ln -s <path>/gzz-goto/bash_aliases ~/.goto_bash_aliases

or

ln -s <path>/gzz-goto/bash_aliases ~/.prefered_name 

and adjust bellow.

gvim -p ~/.bashrc
# or use another editor of your choice.
```

add 

```bash
if [ -e "$HOME/.goto_bash_aliases" ]
then
    # shellcheck disable=SC1090
    source ~/.goto_bash_aliases
fi
```

line `# shellcheck disable=SC1090` for those who use shellcheck linter ideally you should use it or something equivalent 

To use from elvish
------------------

```elvish
use epm

epm:install github.com/grizzlysmit/gzz-goto
```

add this to your rc.elv

  * these four lines are optional if you have done the epm:install above then this is redundant but if you want your rc.elv to be portable then add them anyway

```elvish
use epm

epm:install &silent-if-installed         ^
     github.com/grizzlysmit/gzz-goto
```

  * definately add these lines.

```elvish
use github.com/grizzlysmit/gzz-goto/gt

fn goto {|@_args|
    gt:goto $@_args
}
```

