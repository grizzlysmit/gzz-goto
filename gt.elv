#!/usr/bin/env elvish
##############################################################
#                                                            #
# goto function makes getting places in the file system easy #
#                                                            #
##############################################################
use str
use re
use github.com/zzamboni/elvish-modules/dir
use os
fn goto {| @_args | 
    if (== (count $_args) 0) {
        dir:cd 
        e:exa -F -laahigHb  --colour-scale --time-style=full-iso
    } elif (== (count $_args) 1) {
        if (==s $_args[0] '--help') {
             e:goto --help
        } elif (==s $_args[0] '-') {
            dir:cd -
            e:exa -F -laahigHb  --colour-scale --time-style=full-iso
        } else {
             var res = (e:goto $_args[0])
             if (==s $res '') {
                if (os:is-dir &follow-symlink=$true $_args[0]) {
                    cd $_args[0]
                    e:exa -F -laahigHb  --colour-scale --time-style=full-iso
                } else {
                    echo "error: "$_args[0]" not found"
                }
             } else {
                dir:cd $res
                e:exa -F -laahigHb  --colour-scale --time-style=full-iso
             }
        }
    } else {
        e:goto $@_args
    }
}
