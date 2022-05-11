#!/usr/bin/env raku
use v6;

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

multi sub MAIN('list', 'all', Str $prefix = '', Bool :r(:$resolve) = False) returns Int {
   if list-all($prefix, $resolve) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('add', Str:D $key, Str:D $path) returns Int {
   if add-path($key, $path) {
       exit 0;
   } else {
       exit 1;
   } 
}

multi sub MAIN('alias', Str:D $key, Str:D $path) returns Int {
   if add-alias($key, $path) {
       exit 0;
   } else {
       exit 1;
   } 
}
