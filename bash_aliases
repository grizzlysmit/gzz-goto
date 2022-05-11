# vim: :set filetype=sh :autoindent #
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################
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
          else
             arg=$(paths.raku "$1")
             if [ -z "$arg" ]
             then
                 echo "error: $1 not found"
             else
                 cd "$arg"
                 eb
             fi
          fi;;
      *) paths.raku "$@";;
   esac
}
# vim: :set filetype=sh :autoindent #
