#unit module Build:ver<0.1.44>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

class Build {
    method build($dist-path) {
        # do build stuff to your module
        # which is located at $dist-path
        dd %?RESOURCES;
        my IO::Path $CWD = $*CWD;
        my Str:D $path = "/usr/lib/perl6/site/bin";
        chdir($path.IO);
        my Proc $r = run 'ln', '-s', "paths.raku",              "goto"                unless "goto".IO               ~~ :e;
        $r = run         'ln', '-s', "paths.raku-j",            "goto-j"              unless "goto-j".IO             ~~ :e;
        $r = run         'ln', '-s', "paths.raku-js",           "goto-js"             unless "goto-js".IO            ~~ :e;
        $r = run         'ln', '-s', "paths.raku-m",            "goto-m"              unless "goto-m".IO             ~~ :e;
        $r = run         'ln', '-s', "paths.raku",              "g"                   unless "g".IO                  ~~ :e;
        $r = run         'ln', '-s', "paths.raku-j",            "g-j"                 unless "g-j".IO                ~~ :e;
        $r = run         'ln', '-s', "paths.raku-js",           "g-js"                unless "g-js".IO               ~~ :e;
        $r = run         'ln', '-s', "paths.raku-m",            "g-m"                 unless "g-m".IO                ~~ :e;
        $r = run         'ln', '-s', "goto-init.raku",          "goto-init"           unless "goto-init".IO          ~~ :e;
        $r = run         'ln', '-s', "goto-init.raku-j",        "goto-init-j"         unless "goto-init-j".IO        ~~ :e;
        $r = run         'ln', '-s', "goto-init.raku-js",       "goto-init-js"        unless "goto-init-js".IO       ~~ :e;
        $r = run         'ln', '-s', "goto-init.raku-m",        "goto-init-m"         unless "goto-init-m".IO        ~~ :e;
        chdir("/usr/local/bin/".IO);
        $r = run         'ln', '-s', "$path/paths.raku",        "paths.raku"          unless "paths.raku".IO         ~~ :e;
        $r = run         'ln', '-s', "$path/paths.raku-j",      "paths.raku-j"        unless "paths.raku-j".IO       ~~ :e;
        $r = run         'ln', '-s', "$path/paths.raku-js",     "paths.raku-js"       unless "paths.raku-js".IO      ~~ :e;
        $r = run         'ln', '-s', "$path/paths.raku-m",      "paths.raku-m"        unless "paths.raku-m".IO       ~~ :e;
        $r = run         'ln', '-s', "$path/goto",              "goto"                unless "goto".IO               ~~ :e;
        $r = run         'ln', '-s', "$path/goto-j",            "goto-j"              unless "goto-j".IO             ~~ :e;
        $r = run         'ln', '-s', "$path/goto-js",           "goto-js"             unless "goto-js".IO            ~~ :e;
        $r = run         'ln', '-s', "$path/goto-m",            "goto-m"              unless "goto-m".IO             ~~ :e;
        $r = run         'ln', '-s', "$path/g",                 "g"                   unless "g".IO                  ~~ :e;
        $r = run         'ln', '-s', "$path/g-j",               "g-j"                 unless "g-j".IO                ~~ :e;
        $r = run         'ln', '-s', "$path/g-js",              "g-js"                unless "g-js".IO               ~~ :e;
        $r = run         'ln', '-s', "$path/g-m",               "g-m"                 unless "g-m".IO                ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init.raku",    "goto-init.raku"      unless "goto-init.raku".IO     ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init.raku-j",  "goto-init.raku-j"    unless "goto-init.raku-j".IO   ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init.raku-js", "goto-init.raku-js"   unless "goto-init.raku-js".IO  ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init.raku-m",  "goto-init.raku-m"    unless "goto-init.raku-m".IO   ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init",         "goto-init"           unless "goto-init".IO          ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init-j",       "goto-init-j"         unless "goto-init-j".IO        ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init-js",      "goto-init-js"        unless "goto-init-js".IO       ~~ :e;
        $r = run         'ln', '-s', "$path/goto-init-m",       "goto-init-m"         unless "goto-init-m".IO        ~~ :e;
        chdir($CWD);
    }
}
