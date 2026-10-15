## vim: :set filetype=raku :autoindent #
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################


my %*SUB-MAIN-OPTS;
%*SUB-MAIN-OPTS«named-anywhere» = True;
#%*SUB-MAIN-OPTS<bundling>       = True;

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
use str
use re
use github.com/zzamboni/elvish-modules/dir
use os
fn goto {| @_args | 
    if (== (count $_args) 0) {
        dir:cd 
        e:exa -F -laahigHb  --colour-scale --time-style=full-iso --icons=always
    } elif (== (count $_args) 1) {
        if (==s $_args[0] '--help') {
             e:goto --help
        } elif (or (==s $_args[0] '--version') (==s $_args[0] '-v'))  {
             e:goto --version
        } elif (==s $_args[0] '-') {
            dir:cd -
            e:exa -F -laahigHb  --colour-scale --time-style=full-iso --icons=always
        } else {
             var res = (e:goto $_args[0])
             if (==s $res '') {
                if (os:is-dir &follow-symlink=$true $_args[0]) {
                    cd $_args[0]
                    e:exa -F -laahigHb  --colour-scale --time-style=full-iso --icons=always
                } else {
                    echo "error: "$_args[0]" not found"
                }
             } else {
                dir:cd $res
                e:exa -F -laahigHb  --color-scale --time-style=full-iso --icons=always
             }
        }
    } else {
        e:goto $@_args
    }
}
fn g {| @_args |
  goto $@_args
}
ENDELVISH

multi sub MAIN('bash', --> Int:D){
    $bash.say;
    exit 0;
}

multi sub MAIN('elvish', --> Int:D){
    $elvish.say;
    exit 0;
}

multi sub MAIN('init', Str:D :$shell = 'bash', Str:D :$config is copy = '' --> Int){
    my Str:D $home = %*ENV«HOME».Str;
    given $shell {
        when 'bash' {
            $config = ".bashrc" if $config eq '';
            my $path = qx[which goto-init.raku];
            "$home/$config".IO.spurt(qq[\neval "\$($path bash)"\n], :append);
        }
        when 'elv'|'elvish'  {
            my Str:D $conf = %*ENV«XDG_DATA_HOME».Str // '.local/share';
            $config = "$conf/elvish/rc.elv" if $config eq '';
            my $path = qx[which goto-init.raku];
            "$home/$config".IO.spurt(qq[\neval "\$($path bash)"\n], :append);
        }
    }
}

## vim: :set filetype=sh :autoindent #
