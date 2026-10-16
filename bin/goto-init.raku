#!/usr/bin/env raku
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################

use Usage::Utils;

my %*SUB-MAIN-OPTS;
%*SUB-MAIN-OPTS«named-anywhere» = True;
#%*SUB-MAIN-OPTS<bundling>       = True;

=begin pod

=begin head2

Table of Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>

=NAME goto-init.raku 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)

=end pod

my Version:D $version = v0.1.63;

=begin pod

=VERSION v0.1.63
=TITLE goto-init
=SUBTITLE GOTO is a cd alternative that acts like a database of bookmarks to different places in the directory tree. This is the init program for goto.


=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/gzz-goto/gt/blob/main/LICENSE>


L<Top of Document|#table-of-contents>

=head1 Introduction

This is the init program for GOTO is a mixture of a Raku app path.raku and a module Paths.rakumod  that implements it and a set of script to apply them inside a shell instance This is important as you need the scripts to call cd from within the shell process in order to actually change it's current directory otherwise we would only change a subprocesses current directory and then nothing would have been achieved on exit.  The scripts are .goto_bash_aliases -> /home/grizzlysmit/Projects/elvish/gzz-goto/bash_aliases in bash and the combination of some lines in your rc.elv file and a elevish module gt.elv.

L<See gzz-goto/gt|https://github.com/grizzlysmit/gzz-goto/gt>.

=end pod

sub version(--> Version:D){
    return $version;
}

my $bash = q:to/ENDBASH/;
if [ -n "$RAKULIB" ]
then
    export RAKULIB="$RAKULIB,$HOME/rakulib"
else
    export RAKULIB="$HOME/rakulib"
fi

# shellcheck disable=SC2120
function eb(){
    if  type exa >> /dev/null 2>&1 
    then
        exa -F -laahigHb  --color-scale --time-style=full-iso --icons=always "$@"
    else
        ls -Flaghi --color "$@"
    fi
}

function goto(){
   case $# in
       0) cd
          eb;;
       1) if [[ "$1" == "--help" ]]
          then
             #USAGE="$(paths.raku --help)"
             #echo "${USAGE//paths.raku/goto}"
             command goto --help
          elif [[ "$1" == "--version" ]] || [[ "$1" == "-v" ]]
          then
              command goto --version
          elif [[ "$1" == "-" ]]
          then
              cd -
              # shellcheck disable=SC2119
              eb
          else
             arg=$(command goto "$1")
             if [ -z "$arg" ]
             then
                 if [ -d "$1" ]
                 then
                     cd "$1"
                     eb
                 else
                     echo "error: $1 not found"
                 fi
             else
                 cd "$arg"
                 # shellcheck disable=SC2119
                 eb
             fi
          fi;;
      *) command goto "$@";;
   esac
}

function g(){
   case $# in
       0) cd
          eb;;
       1) if [[ "$1" == "--help" ]]
          then
             #USAGE="$(paths.raku --help)"
             #echo "${USAGE//paths.raku/g}"
             command g --help
          elif [[ "$1" == "--version" ]] || [[ "$1" == "-v" ]]
          then
              command g --version
          elif [[ "$1" == "-" ]]
          then
              cd -
              # shellcheck disable=SC2119
              eb
          else
             arg=$(command goto "$1")
             if [ -z "$arg" ]
             then
                 if [ -d "$1" ]
                 then
                     cd "$1"
                     eb
                 else
                     echo "error: $1 not found"
                 fi
             else
                 cd "$arg"
                 # shellcheck disable=SC2119
                 eb
             fi
          fi;;
      *) command goto "$@";;
   esac
}
ENDBASH

my $elvish = q:to/ENDELVISH/;
epm:install &silent-if-installed github.com/grizzlysmit/gzz-goto        

use github.com/grizzlysmit/gzz-goto/gt

fn goto {|@_args|
    gt:goto $@_args
}

fn g {|@_args|
    gt:g $@_args
}
ENDELVISH

multi sub MAIN(Bool:D :v(:$version) = False, Bool:D :h(:$help) = False, Bool:D :n(:nocolor(:$nocolour)) = False --> int){
    if $help {
        my %named-args;
        my @args;
        say-coloured($*USAGE, $nocolour, |%named-args, |@args);
        exit 0;
    }
    if $version {
        say version();
        exit 0;
    } else {
        my %named-args;
        my @args;
        say-coloured($*USAGE, $nocolour, %named-args, @args);
        exit 0;
    }
}

multi sub MAIN('bash', Bool:D :v(:$version) = False, Bool:D :h(:$help) = False, Bool:D :n(:nocolor(:$nocolour)) = False --> Int:D){
    if $help {
        my %named-args;
        my @args;
        say-coloured($*USAGE, $nocolour, |%named-args, |@args);
        exit 0;
    }
    if $version {
        say version();
        exit 0;
    }
    $bash.say;
    exit 0;
}

multi sub MAIN('elvish', Bool:D :v(:$version) = False, Bool:D :h(:$help) = False, Bool:D :n(:nocolor(:$nocolour)) = False --> Int:D){
    if $help {
        my %named-args;
        my @args;
        say-coloured($*USAGE, $nocolour, |%named-args, |@args);
        exit 0;
    }
    if $version {
        say version();
        exit 0;
    }
    $elvish.say;
    exit 0;
}

multi sub MAIN('init', Str:D :$shell = 'bash', Str:D :$config is copy = '',
                    Bool:D :v(:$version) = False, Bool:D :h(:$help) = False, Bool:D :n(:nocolor(:$nocolour)) = False --> Int){
    if $help {
        my %named-args;
        my @args;
        say-coloured($*USAGE, $nocolour, |%named-args, |@args);
        exit 0;
    }
    if $version {
        say version();
        exit 0;
    }
    my Str:D $home = %*ENV«HOME».Str;
    given $shell {
        when 'bash' {
            $config = ".bashrc" if $config eq '';
            my $path = qx[which goto-init.raku];
            if $config.IO.is-relative {
                "$home/$config".IO.spurt(qq[\neval "\$($path bash)"\n], :append);
            } else {
                "$config".IO.spurt(qq[\neval "\$($path bash)"\n], :append);
            }
        }
        when 'elv'|'elvish'  {
            my Str:D $conf = %*ENV«XDG_DATA_HOME».Str // "$home/.local/share";
            $config = "$conf/elvish/rc.elv" if $config eq '';
            my $path = qx[which goto-init.raku];
            "$config".IO.spurt(qq[\n$elvish"\n], :append);
        }
    }
}

#`«««
    ***********************************************************
    *                                                         *
    *                       USAGE Stuff                       *
    *                                                         *
    ***********************************************************
#»»»

sub USAGE(Bool:D :n(:nocolor(:$nocolour)) = False, *%named-args, *@args --> Int) {
    say-coloured($*USAGE, $nocolour, %named-args, @args);
    exit 0;
}

multi sub GENERATE-USAGE(&main, |capture --> Int) {
    my @capture = |(capture.list);
    my @_capture;
    if @capture && @capture[0] eq 'help' {
        @_capture = |@capture[1 .. *];
    } else {
        @_capture = |@capture;
    }
    my %capture = |(capture.hash);
    if %capture«nocolour» || %capture«nocolor» || %capture«n» {
        say-coloured($*USAGE, True, |%capture, |@_capture);
    } else {
        #dd @capture;
        say-coloured($*USAGE, False, |%capture, |@_capture);
        #&*GENERATE-USAGE(&main, |capture)
    }
    exit 0;
}

## vim: :set filetype=sh :autoindent #
