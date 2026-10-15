#unit module Build:ver<0.1.44>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

class Build {
    method build($dist-path) {
        # do build stuff to your module
        # which is located at $dist-path
        Proc $r = run 'ln', '-s', "$dist-path/paths.raku", "/usr/local/bin/paths.raku";
        Proc $r = run 'cd', "$dist-path";
        Proc $r = run 'ln', '-s', "goto", "paths.raku";
        Proc $r = run 'ln', '-s', "g",    "paths.raku";
        Proc $r = run 'ln', '-s', "$dist-path/paths.raku", "/usr/local/bin/paths.raku";
        Proc $r = run 'ln', '-s', "$dist-path/goto", "/usr/local/bin/goto";
        Proc $r = run 'ln', '-s', "$dist-path/g", "/usr/local/bin/g";
        Proc $r = run 'ln', '-s', "$dist-path/goto-init.raku", "/usr/local/bin/goto-init.raku";
        Proc $r = run 'ln', '-s', "$dist-path/=begin", "/usr/local/bin/=begin";
        Proc $r = run 'ln', '-s', "$dist-path/=end", "/usr/local/bin/=end";
    }
}
