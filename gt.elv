#!/usr/bin/env elvish
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################
use str
use re
use github.com/zzamboni/elvish-modules/dir
fn goto {| @_args | 
    if (== (count $_args) 0) {
        dir:cd 
        e:exa -FlaahigHb  --colour-scale --time-style=full-iso
    } elif (== (count $_args) 1) {
        if (==s $_args[0] '--help') {
             var USAGE = (str:join ' ' [(e:paths.raku --help)])
             echo (re:replace '\bpaths.raku\b' "\n  goto" $USAGE)
        } elif (==s $_args[0] '-') {
            dir:cd -
            e:exa -FlaahigHb  --colour-scale --time-style=full-iso
        } else {
             var res = (e:paths.raku $_args[0])
             if (==s $res '') {
                echo "error: "$_args[0]" not found"
             } else {
                echo "\$res == `"$res"'"
                dir:cd $res
                e:exa -FlaahigHb  --colour-scale --time-style=full-iso
             }
        }
    } else {
        e:paths.raku $@_args
    }
}
