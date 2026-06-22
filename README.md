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

NAME
====

Paths.rakumod 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.0

TITLE
=====

Paths.rakumod

SUBTITLE
========

A Raku module to implement the paths command which keeps and accesses a database of bookmarks in the directory tree.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Syntax-Highlighters/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

A Raku module to implement the paths command which keeps and accesses a database of bookmarks in the directory tree.

class Gzz_readline
------------------

```raku
#`«««
    ##################################################################
    #                                                                #
    #    grammars for parsing paths.p_ts the paths data base file    #
    #                                                                #
    ##################################################################
#»»»

grammar Key {
    regex key { \w* [ <-[\h]>+ \w* ]* }
}

role KeyActions {
    method key($/) {
        my $k = (~$/).trim;
        dd $k if $debug;
        make $k;
    }
}

grammar Paths {
    token path         { [ <absolute-path> || <relative-path> ] }
    token absolute-path { [ '/' | '~' | '~/' ]  <path-segments>? }
    token relative-path { <path-segments> }
    regex path-segments { <path-segment> [ '/' <path-segment> ]* '/'? }
    regex path-segment  { \w* [ [ <-[\/\#\s]>+ || \h+ ]+ \w* ]* }
} 

role PathsActions {
    method path($/) {
        my Str $abs-rel-path;
        if $/<absolute-path> {
            $abs-rel-path = $/<absolute-path>.made;
        } elsif $/<relative-path> {
            $abs-rel-path = $/<relative-path>.made;
        }
        dd $abs-rel-path if $debug;
        make $abs-rel-path;
    }
    method absolute-path($/) {
        my Str $abs-path;
        if $/<path-segments> {
            $abs-path = ~$/<path-segments>.trim;
            dd $abs-path if $debug;
        } else {
            $abs-path = ~$/.trim;
            dd $abs-path if $debug;
        }
        dd $abs-path if $debug;
        make $abs-path;
    }
    method path-relative($/) {
        my $path-relative = ~$/<path-segments>.made;
        dd $path-relative if $debug;
        make $path-relative;
    }
    method path-segment($/) {
        my $path-segment = (~$/).trim;
        dd $path-segment if $debug;
        make $path-segment;
    }
    method path-segments($/) {
        my @path-segments = $/».made;
        dd @path-segments if $debug;
        make @path-segments.join('/');
    }
}

grammar PathsFile is Key is Paths {
    token TOP                 { <line> [ \v+ <line> ]* \v* }
    regex line                { [ <white-space-line> || <dir> || <alias> || <header-line> || <line-of-hashes> || <comment-line> ] }
    regex white-space-line    { ^^ \h* $$ }
    token header-line         { ^^ \h* '#' <header> \h* $$ }
    token header              { 'key' \h+ 'sep' \h+ 'path' \h+ ':' \h+ '#' \h+ 'comment' }
    token line-of-hashes      { ^^ \h* '#'+ $$ }
    regex comment-line        { ^^ \h* '#' <-[\v]>* $$ }
    token dir                 { <key> \h* '=>' \h* <path> \h* [ '#' \h* <comment> \h* ]? }
    token alias               { <key> \h* '-->' \h* <target=.key> \h* [ '#' \h* <comment> \h* ]? }
    token comment             { <-[\n]>* }
}

my $line-no = 0;
class PathFileActions does KeyActions does PathsActions {
    method line($/) {
        my %line;
        if $/<white-space-line> {
            %line = $/<white-space-line>.made;
        }elsif $/<dir> {
            %line = $/<dir>.made;
        } elsif $/<alias> {
            %line = $/<alias>.made;
        } elsif $/<header-line> {
            %line = $/<header-line>.made;
        } elsif $/<line-of-hashes> {
            %line = $/<line-of-hashes>.made;
        } elsif $/<comment-line> {
            %line = $/<comment-line>.made;
        }
        dd %line if $debug;
        make %line;
    }
    method white-space-line($/) {
        $line-no++;
        my %white-space-line = type => 'white-space-line', line-no => $line-no, value => ~$/;
        make ~$line-no => %white-space-line;
    }
    method header-line($/) {
        $line-no++;
        my %header-line = type => 'header-line', line-no => $line-no, value => $/<header>.made;
        make ~$line-no => %header-line;
    }
    method header($/) {
        my $header = ~$/;
        make $header;
    }
    method line-of-hashes($/) {
        $line-no++;
        my %line-of-hashes = type => 'line-of-hashes', line-no => $line-no, value => ~$/;
        make '##' => %line-of-hashes;
    }
    method comment-line($/) {
        $line-no++;
        my %comment-line = type => 'comment-line', line-no => $line-no, value => ~$/;
        make ~$line-no => %comment-line;
    }
    method comment($/)   { make ~$/; }
    method dir   ($/)  {
        my %dir = type => 'dir', path => $/<path>.made;
        if $/<comment> {
            my Str $com = ~($/<comment>).trim;
            %dir«comment» = $com;
        }
        $line-no++;
        %dir«line-no» = $line-no;
        dd $line-no if $debug;
        dd %dir if $debug;
        make $/<key>.made => %dir;
    }
    method alias  ($/) {
        $line-no++;
        my %alias =  type => 'alias', line-no => $line-no, path => $/<target>.made;
        if $/<comment> {
            my $com = ~($/<comment>).trim;
            #$com ~~ s:g/ $<closer> = [ '}' ] /\\$<closer>/;
            %alias«comment» = $com;
        }
        dd %alias if $debug;
        make $/<key>.made => %alias;
    }
    method target ($/) { make $/<key>.made }
    method TOP($match) {
        my %top = $match<line>.map: *.made;
        dd %top if $debug;
        $match.make: %top;
    }
} # class PathFileActions does KeyActions does PathsActions #
```

[Top of Document](#table-of-contents)

