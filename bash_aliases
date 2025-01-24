# vim: :set filetype=sh :autoindent #
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################
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
        exa -F -laahigHb  --colour-scale --time-style=full-iso --icons=always "$@"
    else
        ls -Flaghi --color --author "$@"
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
          elif [ "$1" == "-" ]
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
          elif [ "$1" == "-" ]
          then
              cd -
              # shellcheck disable=SC2119
              eb
          else
             arg=$(command g "$1")
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
      *) command g "$@";;
   esac
}
# vim: :set filetype=sh :autoindent #
