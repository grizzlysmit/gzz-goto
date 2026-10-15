#unit module Build:ver<0.1.44>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

class Build {
    method build($dist-path) {
        # do build stuff to your module
        # which is located at $dist-path
        my Proc $r = run 'ln', '-s', "$dist-path/paths.raku", "/usr/local/bin/paths.raku";
        $r = run 'cd', "$dist-path";
        $r = run 'ln', '-s', "goto", "paths.raku";
        $r = run 'ln', '-s', "g",    "paths.raku";
        $r = run 'ln', '-s', "$dist-path/paths.raku", "/usr/local/bin/paths.raku";
        $r = run 'ln', '-s', "$dist-path/goto", "/usr/local/bin/goto";
        $r = run 'ln', '-s', "$dist-path/g", "/usr/local/bin/g";
        $r = run 'ln', '-s', "$dist-path/goto-init.raku", "/usr/local/bin/goto-init.raku";
    }
}
