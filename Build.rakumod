#unit module Build:ver<0.1.44>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

class Build {
    method build($dist-path) {
        # do build stuff to your module
        # which is located at $dist-path
        dd %?RESOURCES;
        my IO::Path $CWD = $*CWD;
        my Str:D $path = "/usr/lib/perl6/site/bin";
        chdir($path.IO);
        my Proc $r = run 'ln', '-s', "paths.raku",           "goto"           unless "goto".IO            ~~ :l;
        $r = run         'ln', '-s', "paths.raku",           "g"              unless "g".IO               ~~ :l;
        $r = run         'ln', '-s', "goto-init.raku",       "goto-init"      unless "goto-init".IO       ~~ :l;
        chdir("/usr/local/bin/".IO);
        $r = run         'ln', '-s', "$path/paths.raku",     "paths.raku"     unless "paths.raku".IO      ~~ :l;
        $r = run         'ln', '-s', "$path/goto",           "goto"           unless "goto".IO            ~~ :l;
        $r = run         'ln', '-s', "$path/g",              "g"              unless "g".IO               ~~ :l;
        $r = run         'ln', '-s', "$path/goto-init.raku", "goto-init.raku" unless "goto-init.raku".IO  ~~ :l;
        $r = run         'ln', '-s', "$path/goto-init",      "goto-init"      unless "goto-init".IO       ~~ :l;
        chdir($CWD);
    }
}
