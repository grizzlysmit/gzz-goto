# vim: :set filetype=sh :autoindent #
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################
# shellcheck disable=SC2120
function eb(){
    if  type exa >> /dev/null 2>&1 
    then
        if [ $# -eq 0 ]
        then
            exa -FlaahigHb  --colour-scale --time-style=full-iso
        else
            exa -FlaahigHb  --colour-scale --time-style=full-iso "$@"
        fi
    else
        if [ $# -eq 0 ]
        then
            ls -Flaghi --colour
        else
            ls -Flaghi --colour "$@"
        fi
    fi
}
function goto(){
   case $# in
       0) cd;;
       1) if [[ "$1" == "--help" ]]
          then
             USAGE="$(paths.raku --help)"
             echo "${USAGE//paths.raku/goto}"
          elif [ "$1" == "-" ]
          then
              cd -
              # shellcheck disable=SC2119
              eb
          else
             arg=$(paths.raku "$1")
             if [ -z "$arg" ]
             then
                 echo "error: $1 not found"
             else
                 cd "$arg"
                 # shellcheck disable=SC2119
                 eb
             fi
          fi;;
      *) paths.raku "$@";;
   esac
}
# vim: :set filetype=sh :autoindent #
