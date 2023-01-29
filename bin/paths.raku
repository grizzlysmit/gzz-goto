#!/usr/bin/env raku
use v6;
use ECMA262Regex;

my %*SUB-MAIN-OPTS;
%*SUB-MAIN-OPTS«named-anywhere» = True;
#%*SUB-MAIN-OPTS<bundling>       = True;

use Paths;

multi sub MAIN(Str:D $key --> int){
    say path($key);
    return 0;
}

multi sub MAIN('edit', 'configs') returns Int {
   if edit-configs() {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('list', 'keys', Str $prefix = '', Bool:D :c(:color(:$colour)) = False, Int:D :l(:$page-length) = 50, Str :p(:$pattern) = Str, Str :e(:$ecma-pattern) = Str) returns Int {
    my Regex $_pattern;
    with $pattern {
        $_pattern = rx:i/ <$pattern> /;
    } orwith $ecma-pattern {
        $_pattern = ECMA262Regex.compile("^$ecma-pattern\$");
    } else {
        $_pattern = rx:i/^ .* $/;
    }
    if say-list-keys($prefix, $colour, $_pattern, $page-length) {
       exit 0;
    } else {
       exit 1;
    } 
}

multi sub MAIN('list', 'all', Str:D $prefix = '', Bool:D :r(:$resolve) = False, Bool:D :c(:color(:$colour)) = False, Int:D :l(:$page-length) = 50, Str :p(:$pattern) = Str, Str :e(:$ecma-pattern) = Str) returns Int {
    my Regex $_pattern;
    with $pattern {
        $_pattern = rx:i/ <$pattern> /;
    } orwith $ecma-pattern {
        $_pattern = ECMA262Regex.compile("^$ecma-pattern\$");
    } else {
        $_pattern = rx:i/^ .* $/;
    }
    if list-all($prefix, $resolve, $colour, $page-length, $_pattern) {
       exit 0;
    } else {
       exit 1;
    } 
} # multi sub MAIN('list', 'all', Str $prefix = '', Bool:D :r(:$resolve) = False, Bool:D :c(:color(:$colour)) = False, Str :p(:$pattern) = Str, Str :e(:$ecma-pattern) = Str) returns Int #

multi sub MAIN('add', Str:D $key, Str:D $path, Bool:D :s(:set(:$force)) = False, Str :c(:$comment) = Str) returns Int {
   if add-path($key, $path, $force, $comment) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('delete', Str:D $key, Bool:D :o(:$comment-out) = False) returns Int {
   if delete-key($key, $comment-out) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('del', Str:D $key, Bool:D :o(:$comment-out) = False) returns Int {
   if delete-key($key, $comment-out) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('tidy', 'file') returns Int {
   if tidy-file() {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('alias', Str:D $key, Str:D $target, Bool:D :s(:set(:$force)) = False, Bool:D :d(:really-force(:$overwrite-dirs)) = False, Str :c(:$comment) = Str) returns Int {
   if add-alias($key, $target, $force, $overwrite-dirs, $comment) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('comment', Str:D $key, Str:D $comment) returns Int {
   if add-comment($key, $comment) {
       exit 0;
   } else {
       exit 1;
   } 
}
