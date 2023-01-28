#!/usr/bin/env raku
use v6;

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

multi sub MAIN('list', 'keys', Str $prefix = '') returns Int {
   if say-list-keys($prefix) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('list', 'all', Str:D $prefix = '', Bool:D :r(:$resolve) = False, Bool:D :c(:color(:$colour)) = False, Int:D :p(:$page-length) = 50) returns Int {
   if list-all($prefix, $resolve, $colour, $page-length) {
       exit 0;
   } else {
       exit 1;
   } 
} # multi sub MAIN('list', 'all', Str $prefix = '', Bool:D :r(:$resolve) = False, Bool:D :c(:color(:$colour)) = False) returns Int #

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
