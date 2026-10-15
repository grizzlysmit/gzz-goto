#unit module Build:ver<0.1.44>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

class Build {
    method build($dist-path) {
        # do build stuff to your module
        # which is located at $dist-path
        dd %?RESOURCES;
        my Str:D $path = "/usr/lib/perl6/site/bin";
        my Proc $r = run 'cd', "$path";
        $r = run 'ln', '-s', "$path/paths.raku", "paths.raku";
        $r = run 'ln', '-s', "goto", "paths.raku";
        $r = run 'ln', '-s', "g",    "paths.raku";
        $r = run 'cd', "/usr/local/bin/";
        $r = run 'ln', '-s', "$path/paths.raku", "paths.raku";
        $r = run 'ln', '-s', "$path/goto", "goto";
        $r = run 'ln', '-s', "$path/g", "g";
        $r = run 'ln', '-s', "$path/goto-init.raku", "goto-init.raku";
    }
}
