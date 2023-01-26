unit module Paths:ver<0.1.0>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

use Terminal::ANSI::OO :t;
use Terminal::WCWidth;

# the home dir #
constant $home is export = %*ENV<HOME>.Str();

# config files
constant $config is export = "$home/.local/share/paths";

if $config.IO !~~ :d {
    $config.IO.mkdir();
}

# The config files to test for #
constant @config-files is export = qw{paths.p_th editors};

my Str @guieditors;

sub generate-configs(Str $file) returns Bool:D {
    my Bool $result = True;
    my IO::CatHandle:D $fd = "$config/$file".IO.open: :w;
    given $file {
        when 'paths.p_th' {
            my Str $content = q:to/END/;
            #paths #
            home                 => ~
            rkl                  => ~/rakulib
            bin                  => ~/bin

            END
            $content .=trim-trailing;
            my Bool $r = $fd.put: $content;
            "could not write $config/$file".say if ! $r;
            $result ?&= $r;
        }
        when 'editors' {
            my Str $content = q:to/END/;
                # these editors are gui editors
                # you can define multiple lines like these 
                # and the system will add to an array of strings 
                # to treat as guieditors (+= is prefered but = can be used).  

            END
            $content .=trim-trailing;
            for <gvim xemacs kate gedit> -> $guieditor {
                @guieditors.append($guieditor);
            }
            for @guieditors -> $guieditor {
                $content ~= "\n        guieditors  +=  $guieditor";
            }
            my Bool $r = $fd.put: $content;
            "could not write $config/$file".say if ! $r;
            $result ?&= $r;
        } # when 'editors' #
    } # given $file #
    my Bool $r = $fd.close;
    "error closing file: $config/$file".say if ! $r;
    $result ?&= $r;
    return $result;
} # sub generate-configs(Str $file) returns Bool:D #


my Bool:D $please-edit = False;
for @config-files -> $file {
    my Bool $result = True;
    if "$config/paths.p_th".IO !~~ :f {
        $please-edit = True;
        if "/etc/skel/.local/share/paths/$file".IO ~~ :f {
            try {
                CATCH {
                    when X::IO::Copy { 
                        "could not copy /etc/skel/.local/share/paths/$file -> $config/$file".say;
                        my Bool $r = generate-configs($file); 
                        $result ?&= $r;
                    }
                }
                my Bool $r = "/etc/skel/.local/share/paths/$file".IO.copy("$config/$file".IO, :createonly);
                if $r {
                    "copied /etc/skel/.local/share/paths/$file -> $config/$file".say;
                } else {
                    "could not copy /etc/skel/.local/share/paths/$file -> $config/$file".say;
                }
                $result ?&= $r;
            }
        } else {
            my Bool $r = generate-configs($file);
            "generated $config/$file".say if $r;
            $result ?&= $r;
        }
    }
} # for @config-files -> $file # 
edit-configs() if $please-edit;

role Key {
    token key { \w+ [ [ '-' | '.' | '+' | '@' ]+ \w* ]* }
}

role KeyActions {
    method key($/) {
        make $/<key>.made
    }
}

role Paths {
    token path          { [ <absolute-path> | <relative-path> ] }
    token absolute-path { [ <sep> | <tilde> | <tilde> <path-segment> <sep> | <tilde> <sep> ] [ <path-segments> ]? }
    token tilde         { '~' }
    token sep           { '/' }
    token relative-path { <path-segments> }
    token path-segment  { \w+ [ <-[ / ]>+ \w* ]* }
    token path-segments { <path-segment>+ % '/' }
}

role PathsActions {
    method path($/) {
        my Str $abs-rel-path;
        with $/<absolute-path> {
            $abs-rel-path = $/<absolute-path>.made;
        } orwith $/<relative-path> {
            $abs-rel-path = $/<relative-path>.made;
        }
        make $abs-rel-path;
    }
    method absolute-path($/) {
        my Str $abs-path;
        with $/<path-segments> {
            if ~$/.starts-with('/') {
                $abs-path = $/.made ~ $/<path-segments>.made;
            } elsif ~$/.starts-with('~/') {
                $abs-path = $/<tilde>.made ~ $<sep>.made ~ $/<path-segments>.made;
            } elsif ~$/.starts-with('~') {
                with $/<path-segment> {
                    $abs-path = $/<tilde>.made ~ $/<path-segment>.made ~ $/<sep>.made ~ $/<path-segments>.made;
                } else {
                    $abs-path = $/<tilde>.made ~ $/<path-segments>.made;
                }
            }
        } else {
            if ~$/ eq '~' {
                $abs-path = $/<tilde>.made;
            } elsif ~$/ eq '~/' {
                $abs-path = $/<tilde>.made ~ $/<sep>.made;
            } elsif ~$/ eq '/' {
                $abs-path = $/<sep>.made;
            } elsif ~$/.starts-with('/') {
                $abs-path = $/<sep>.made ~ $/<path-segments>.made;
            } elsif ~$/.starts-with('~') {
                $abs-path = $/<tilde>.made ~ $/<path-segment>.made ~ $/<sep>.made ~ $/<path-segments>.made;
            }
        }
        make $abs-path;
    }
    method tilde($/) { make $/<tilde>.made }
    method sep($/)   { make $/<sep>.made }
    method path-relative($/) {
        make $/<path-segments>.made
    }
    method path-segment($/) { make $/.made }
    method path-segments($/) {
        my @made-elts = gather for $/<path-segment> {
            take $_.made
        };
        make @made-elts.join('/');
    }
}

grammar PathsFile does Key does Paths {
    token TOP           {  <line>+ % "\n" }
    token line          { [ <_line> | '#' <.ws> <comment> ]? }
    token _line         { <.ws> [ <dir> | <alias> ] }
    token comment       { .* }
    token dir           { <key> <.ws> '=>' <.ws> <path> <.ws> [ '#' <.ws> <comment> ]? }
    token alias         { <key> <.ws> '-->' <.ws> <target> <.ws> [ '#' <.ws> <comment> ]? }
    token target        { <key> }
}

class PathFileActions does KeyActions does PathActions {
    method TOP($/) {
        my %made-elts = gather for $/<line> {
            $_.made
        };
        make %made-elts;
    }
    method line($/) {
        with $/<_line> {
            make $/<_line>.made;
        } orwith $/<comment> {
            sink $/<comment>.made;
        }
    }
    method _line($/) {
        my %val;
        with $/<dir> {
            %val = $/<dir>.made;
        } orwith $/<alias> {
            %val = $/<alias>.made;
        }
        make %val;
    }
    method comment($/) { make $/<comment>.made }
    method dir    ($/) {
        my %val = type => 'dir', value => $/<path>.made;
        with $/<comment> {
            %val«comment» = $/<comment>.made;
        }
        make $/<key>.made => %val;
    }
    method alias  ($/) {
        my %val =  type => 'alias', value => $/<target>.made;
        with $/<comment> {
            %val«comment» = $/<comment>.made;
        }
        make $/<key>.made => %val;
    }
    method target ($/) { make $/<key>.made }
}

grammar KeyValid does Key {
    token TOP { <key> }
}

class KeyValidAction does KeyActions {
    method TOP($/) { make $/<TOP>.made }
}

grammar Path does Paths {
    token TOP { <path> }
}

class PathActions does PathsActions {
    method TOP($/) { make $/<TOP>.made }
}

my Str  @lines     = slurp("$config/paths.p_th").split("\n");
my Str  %the-paths = @lines.map( { my Str $e = $_; $e ~~ s/ '#' .* $$ //; $e } ).map( { $_.trim() } ).grep({ !rx/ [ ^^ \s* '#' .* $$ || ^^ \s* $$ ] / }).map: { my ($key, $value) = $_.split(rx/ \s*  '=>' \s* /, 2); my $e = $key => $value; $e };
my Hash %the-lot   = @lines.grep({ !rx/ [ ^^ \s* '#' .* $$ || ^^ \s* $$ ] / }).map: { my $e = $_; ($e ~~ rx/^ \s* $<key> = [ \w+ [ [ '.' || '-' || '@' || '+' ]+ \w* ]* ] \s* '=>' \s* $<path> = [ <-[ # ]>+ ] \s* [ '#' \s* $<comment> = [ .* ] ]?  $/) ?? (~$<key> => { value => (~$<path>).trim, comment => ($<comment> ?? ~$<comment> !! Str), }) !! { my ($key, $value) = $_.split(rx/ \s*  '=>' \s* /, 2); my $r = $key => $value; $r } };

# the editor to use #
my Str $editor = '';
if %*ENV<GUI_EDITOR>:exists {
    $editor = %*ENV<GUI_EDITOR>.Str();
} elsif %*ENV<VISUAL>:exists {
    $editor = %*ENV<VISUAL>.Str();
} elsif %*ENV<EDITOR>:exists {
    $editor = %*ENV<EDITOR>.Str();
} else {
    my Str $gvim = qx{/usr/bin/which gvim 2> /dev/null };
    my Str $vim  = qx{/usr/bin/which vim  2> /dev/null };
    my Str $vi   = qx{/usr/bin/which vi   2> /dev/null };
    if $gvim {
        $editor = $gvim;
    } elsif $vim {
        $editor = $vim;
    } elsif $vi {
        $editor = $vi;
    }
}

# The default name of the gui editor #
my Str @gui-editors = slurp("$config/editors").split("\n").map( { my Str $e = $_; $e ~~ s/ '#' .* $$ //; $e } ).map( { $_.trim() } ).grep: { !rx/ [ ^^ \s* '#' .* $$ || ^^ \s* $$ ] / };
my Str $gui-editor = "";
#my Str @guieditors;
#@gui-editors.raku.say;
if @gui-editors {
    #@gui-editors.raku.say;
    for @gui-editors -> $geditor {
        #"'$geditor'".say;
        #"Got here $?FILE [$?LINE]".say;
        if $geditor ~~ rx/ ^^ 'geditor' \s* '=' $<ed> = [ .+ ] $$ / {
            #"Got here $?FILE [$?LINE]".say;
            $gui-editor = ~$<ed>;
            #"'$gui-editor'".say;
            $gui-editor .=trim;
            #"'$gui-editor'".say;
        } elsif $geditor ~~ rx/ ^^ \s* 'guieditors' \s* '+'? '=' $<ed> = [ .+ ] $$ / {
            my Str $guieditor = ~$<ed>;
            $guieditor .=trim;
            @guieditors.append($guieditor);
        }
    }
}
if %*ENV<GUI_EDITOR>:exists {
    my Str $guieditor = ~%*ENV<GUI_EDITOR>;
    if ! @guieditors.grep( { $_ eq $guieditor.IO.basename } ) {
        @guieditors.prepend($guieditor.IO.basename);
    }
}



sub resolve-dir(Str $dir, Bool $relitive-to-home = True) returns Str is export {
    my Str $Dir = $dir.trim;
    #$Dir.say;
    $Dir = $home if $Dir eq '~';
    $Dir ~~ s! ^^ '~' \/ !$home\/!;
    if $Dir ~~ rx! ^^ $<start> = [ '~' <-[ \/ ]> +  ] \/ ! {
        my Str $start = ~$<start>;
        given $start {
            when '~root' { $Dir ~~ s! ^^ '~' !\/!; }
            default {
                my Str @candidates = dir('/home', test => { "/home/$_".IO.d && $_ ne '.' && $_ ne '..' }).map: { $_.Str };
                my Str $start_d = $start.substr(1);
                my Str $candidate = @candidates.grep: { rx/ \/ $start_d $$ / };
                if $candidate {
                    $Dir ~~ s! ^^ $start \/ !$candidate\/!;
                } else {
                    "cannot resolve $start".say;
                    return $dir;
                }
            }
        }
    }
    $Dir = "$home/$Dir" if $relitive-to-home && $Dir !~~ rx! ^^ \/ !;
    #$Dir.say;
    return $Dir;
}

sub path(Str:D $go-here --> Str:D) is export {
    my Str $return = '';
    if %the-paths{$go-here}:exists {
        $return = %the-paths{$go-here};
        $return = resolve-dir($return);
    }
    return $return;
}

sub edit-configs() returns Bool:D is export {
    if $editor {
        my $option = '';
        my @args;
        my $edbase = $editor.IO.basename;
        if $edbase eq 'gvim' {
            $option = '-p';
            @args.append('-p');
        }
        my Str $cmd = "$editor $option ";
        @args.append(|@config-files);
        for @config-files -> $file {
            $cmd ~= "'$config/$file' ";
        }
        $cmd ~= '&' if @guieditors.grep: { rx/ ^^ $edbase $$ / };
        chdir($config.IO);
        #my $proc = run( :in => '/dev/tty', :out => '/dev/tty', :err => '/dev/tty', $editor, |@args);
        my $proc = run($editor, |@args);
        return $proc.exitcode == 0 || $proc.exitcode == -1;
    } else {
        "no editor found please set GUI_EDITOR, VISUAL or EDITOR to your preferred editor.".say;
        "e.g. export GUI_EDITOR=/usr/bin/gvim".say;
        return False;
    }
}

sub list-keys(Str $prefix = '' --> Array[Str]) is export {
    my Str @keys;
    for %the-paths.keys -> $key {
        if $key.starts-with($prefix, :ignorecase) {
            @keys.push($key);
        }
    }
    return @keys;
}

sub say-list-keys(Str $prefix = '' --> Bool:D) is export {
    my @keys = list-keys($prefix).sort: { .lc };
    my Int:D $key-width        = 0;
    my Int:D $comment-width    = 0;
    for @keys -> $key {
        my Str %val = %the-lot{$key};
        my Str $comment = %val«comment»;
        $key-width         = max($key-width,     wcswidth($key));
        with $comment {
            $comment-width = max($comment-width, wcswidth($comment));
        } else {
            $key.say;
        }
    }
    $key-width     += 2;
    $comment-width += 2;
    for @keys -> $key {
        my Str %val = %the-lot{$key};
        my Str $comment = %val«comment»;
        with $comment {
            printf "%-*s # %-*s\n", $key-width, $key, $comment-width, $comment;
        } else {
            $key.say;
        }
    }
    return True;
}

sub centre(Str:D $text, Int:D $width is copy, Str:D $fill = ' ' --> Str) {
    my Str $result = $text;
    $width -= wcswidth($result);
    $width = $width div wcswidth($fill);
    my Int:D $w  = $width div 2;
    $result = $fill x $w ~ $result ~ $fill x ($width - $w);
    return $result;
}

sub list-all(Str:D $prefix, Bool:D $resolve, Bool:D $colour, Int:D $page-length --> Bool:D) is export {
    my Str @result;
    my Int:D $key-width        = 0;
    my Int:D $value-width      = 0;
    my Int:D $comment-width    = 0;
    for %the-lot.kv -> $key, %val {
        if $key.starts-with($prefix, :ignorecase) {
            my Str $value      = %val«value»;
            my Str $comment    = %val«comment»;
            $value             = resolve-dir($value) if $resolve;
            $key-width         = max($key-width,     wcswidth($key));
            $value-width       = max($value-width,   wcswidth($value));
            with $comment {
                $comment-width = max($comment-width, wcswidth($comment));
            }
        }
    } # for %the-lot.kv -> $key, %val #
    $key-width     += 2;
    $value-width   += 2;
    $comment-width += 2;
    my Bool:D $comment-present = False;
    for %the-lot.kv -> $key, %val {
        if $key.starts-with($prefix, :ignorecase) {
            my Str $value   = %val«value»;
            my Str $comment = %val«comment»;
            $value = resolve-dir($value) if $resolve;
            with $comment {
                @result.push(sprintf("%-*s => %-*s # %-*s", $key-width, $key, $value-width, $value, $comment-width, $comment));
                $comment-present = True;
            } else {
                @result.push(sprintf("%-*s => %-*s", $key-width, $key, $value-width, $value));
            }
        }
    } # for %the-lot.kv -> $key, %val #
    my Int:D $width = $key-width + $value-width + $comment-width + 7;
    my Int:D $cnt = 0;
    if $colour {
        with $comment-present {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s => %-*s # %-*s", $key-width, 'key', $value-width, 'value', $comment-width, 'comment') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
            $cnt++;
        } else {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s => %-*s", $key-width, 'key', $value-width, 'value') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
            $cnt++;
        }
    } else {
        with $comment-present {
            printf("%-*s => %-*s # %-*s\n", $key-width, 'key', $value-width, 'value', $comment-width, 'comment');
            $cnt++;
            say '=' x $width;
            $cnt++;
        } else {
            printf("%-*s => %-*s\n", $key-width, 'key', $value-width, 'value');
            $cnt++;
            say '=' x $width;
            $cnt++;
        }
    }
    for @result.sort( { .lc } ) -> $value {
        if $colour {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, $value) ~ t.text-reset;
            $cnt++;
            if $cnt % $page-length == 0 {
                with $comment-present {
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
                    $cnt++;
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s => %-*s # %-*s", $key-width, 'key', $value-width, 'value', $comment-width, 'comment') ~ t.text-reset;
                    $cnt++;
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
                    $cnt++;
                } else {
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
                    $cnt++;
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s => %-*s", $key-width, 'key', $value-width, 'value') ~ t.text-reset;
                    $cnt++;
                    put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, centre('', $width, '=')) ~ t.text-reset;
                    $cnt++;
                }
            } # if $cnt % $page-length == 0 #
        } else { # if $colour #
            $value.say;
            $cnt++;
            if $cnt % $page-length == 0 {
                with $comment-present {
                    say '=' x $width;
                    $cnt++;
                    printf("%-*s => %-*s # %-*s\n", $key-width, 'key', $value-width, 'value', $comment-width, 'comment');
                    $cnt++;
                    say '=' x $width;
                    $cnt++;
                } else {
                    say '=' x $width;
                    $cnt++;
                    printf("%-*s => %-*s\n", $key-width, 'key', $value-width, 'value');
                    $cnt++;
                    say '=' x $width;
                    $cnt++;
                }
            } # if $cnt % $page-length == 0 #
        } # if $colour ... else ... #
    }
    if $colour {
        put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue ~ sprintf("%-*s", $width, '') ~ t.text-reset;
        $cnt++;
    } else {
        "".say;
    }
    return True;
} # sub list-all(Str:D $prefix, Bool:D $resolve, Bool:D $colour, Int:D $page-length --> Bool:D) is export #

sub add-tildes(Str:D $path is copy --> Str:D) {
    $path .=trim;
    $path  = '~' if $path eq $home;
    $path ~~ s{^ $home '/' } = '~/';
    $path ~~ s{^ '/home/' }  = '~';
    $path ~~ s!\/$!!;
    return $path;
}

sub add-path(Str:D $key, Str:D $path, Bool $force, Str $comment --> Bool) is export {
    if %the-paths{$key}:exists {
        if $force {
            CATCH {
                when X::IO::Rename {
                    $*ERR.say: $_;
                    return False;
                }
                default: {
                    $*ERR.say: $_;
                    return False;
                }
            }
            my Str $line = sprintf "%-20s => %-50s", $key, add-tildes($path);
            with $comment {
                $line ~= " # $comment";
            }
            my IO::Handle:D $input  = "$config/paths.p_th".IO.open:     :r, :nl-in("\n")   :chomp;
            my IO::Handle:D $output = "$config/paths.p_th.new".IO.open: :w, :nl-out("\n"), :chomp(True);
            my Str $ln;
            while $ln = $input.get {
                if $ln ~~ rx/^ \s* <$key> \s* '=>' \s* .* $/ {
                    $output.say: $line;
                } else {
                    $output.say: $ln
                }
            }
            $input.close;
            $output.close;
            if "$config/paths.p_th.new".IO.move: "$config/paths.p_th" {
                return True;
            } else {
                return False;
            }
        } else {
            $*ERR.say: "duplicate key use -s|--set|--force to override";
            return False;
        }
    }
    my Str $config-path = "$config/paths.p_th";
    my Str $line = sprintf "%-20s => %-50s", $key, add-tildes($path);
    with $comment {
        $line ~= " # $comment";
    }
    $line ~= "\n";
    $config-path.IO.spurt($line, :append);
    return True;
} # sub add-path(Str:D $key, Str:D $path, Bool $force, Str $comment --> Bool) is export #

sub delete-key(Str:D $key, Bool:D $comment-out --> Bool) is export {
    CATCH {
        when X::IO::Rename {
            $*ERR.say: $_;
            return False;
        }
        default: {
            $*ERR.say: $_;
            return False;
        }
    }
    my IO::Handle:D $input  = "$config/paths.p_th".IO.open:     :r, :nl-in("\n")   :chomp;
    my IO::Handle:D $output = "$config/paths.p_th.new".IO.open: :w, :nl-out("\n"), :chomp(True);
    my Str $ln;
    while $ln = $input.get {
        if $ln ~~ rx/^ \s* <$key> \s* '=>' \s* .* $/ {
            $output.say: "# $ln" if $comment-out;
        } else {
            $output.say: $ln
        }
    }
    $input.close;
    $output.close;
    if "$config/paths.p_th.new".IO.move: "$config/paths.p_th" {
        return True;
    } else {
        return False;
    }
} # sub delete-key(Str:D $key, Bool:D $comment-out --> Bool) is export #

sub tidy-file( --> Bool) is export {
    CATCH {
        when X::IO::Rename {
            $*ERR.say: $_;
            return False;
        }
        default: {
            $*ERR.say: $_;
            return False;
        }
    }
    my IO::Handle:D $input  = "$config/paths.p_th".IO.open:     :r, :nl-in("\n")   :chomp;
    my IO::Handle:D $output = "$config/paths.p_th.new".IO.open: :w, :nl-out("\n"), :chomp(True);
    my Str $ln;
    while $ln = $input.get {
        if $ln ~~ rx/^ \s* $<key> = [ \w+ [ [ '.' || '-' || '@' || '+' ]+ \w* ]* ] \s* '=>' \s* $<path> = [ <-[ # ]>+ ] \s* [ '#' \s* $<comment> = [ .* ] ]?  $/ {
            my Str $line = sprintf "%-20s => %-50s", ~$<key>, add-tildes(~$<path>);
            with $<comment> {
                $line ~= " # $<comment>";
            }
            $output.say: $line;
        } else {
            $output.say: $ln
        }
    }
    $input.close;
    $output.close;
    if "$config/paths.p_th.new".IO.move: "$config/paths.p_th" {
        return True;
    } else {
        return False;
    }
} # sub tidy-file( --> Bool) is export #

sub add-alias(Str:D $key, Str:D $target, Bool:D $force, Str $comment is copy --> Bool) is export {
    if %the-paths{$target}:!exists {
        "target: $target doesnot exist".say;
        return False;
    }
    without $comment {
        my Str %val = %the-lot{$target};
        with %val«comment» {
            $comment = %val«comment»;
        }
    }
    return add-path($key, %the-paths{$target}, $force, $comment);
}

sub add-comment(Str:D $key, Str:D $comment --> Bool) is export {
    CATCH {
        when X::IO::Rename {
            $*ERR.say: $_;
            return False;
        }
        default: {
            $*ERR.say: $_;
            return False;
        }
    }
    my IO::Handle:D $input  = "$config/paths.p_th".IO.open:     :r, :nl-in("\n")   :chomp;
    my IO::Handle:D $output = "$config/paths.p_th.new".IO.open: :w, :nl-out("\n"), :chomp(True);
    my Str $ln;
    while $ln = $input.get {
        if $ln ~~ rx/^ \s* $<key> = [ \w+ [ [ '.' || '-' || '@' || '+' ]+ \w* ]* ] \s* '=>' \s* $<path> = [ <-[ # ]>+ ] \s* [ '#' \s* $<comment> = [ .* ] ]?  $/ {
            my Str $line = sprintf "%-20s => %-50s", ~$<key>, add-tildes(~$<path>);
            if $key eq ~$<key> {
                $line ~= " # $comment" unless $comment.trim eq '';
            } orwith $<comment> {
                $line ~= " # $<comment>" unless ~$<comment>.trim eq '';
            }
            $output.say: $line;
        } else {
            $output.say: $ln
        }
    }
    $input.close;
    $output.close;
    if "$config/paths.p_th.new".IO.move: "$config/paths.p_th" {
        return True;
    } else {
        return False;
    }
}
