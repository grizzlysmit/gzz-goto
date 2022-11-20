unit module Paths:ver<0.1.0>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;


# the home dir #
constant $home is export = %*ENV<HOME>.Str();

# config files
constant $config is export = "$home/.local/share/paths";

if $config.IO !~~ :d {
    $config.IO.mkdir();
}

# The config files to test for #
constant @config-files is export = qw{paths.p_th editors};

sub generate-configs(Str $file) returns Bool:D {
    my Bool $result = True;
    my IO::CatHandle:D $fd = "$config/$file".IO.open: :w;
    given $file {
        when 'paths.p_th' {
            my Str $content = q:to/END/;
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
            my Bool $r = $fd.put: q:to/END/;
                # these editors are gui editors
                # you can define multiple lines like these 
                # and the system will add to an array of strings 
                # to treat as guieditors (+= is prefered but = can be used).  

            END
            $content .=trim-trailing;
            for qw{gvim xemacs kate gedit} -> $guieditor {
                @guieditors.append($guieditor);
            }
            for @guieditors -> $guieditor {
                $content ~= "\n        guieditors  +=  $guieditor";
            }
            "could not write $config/$file".say if ! $r;
            $result ?&= $r;
        }
    } # given $file #
    my Bool $r = $fd.close;
    "error closing file: $config/$file".say if ! $r;
    $result ?&= $r;
    return $result;
}


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

my Str %the-paths = slurp("$config/paths.p_th").split("\n").map( { my Str $e = $_; $e ~~ s/ '#' .* $$ //; $e } ).map( { $_.trim() } ).grep({ !rx/ [ ^^ \s* '#' .* $$ || ^^ \s* $$ ] / }).map: { my ($key, $value) = $_.split(rx/ \s*  '=>' \s* /, 2); my $e = $key => $value; $e };

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
my Str @guieditors;
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

#dd %the-paths;


sub resolve-dir(Str $dir, Bool $relitive-to-home = True) returns Str is export {
    my Str $Dir = $dir;
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
    my @keys = list-keys($prefix).sort;
    for @keys -> $key {
        $key.say;
    }
    return True;
}

sub list-all(Str $prefix = '', Bool $resolve = False --> Bool:D) is export {
    my Str @result;
    for %the-paths.kv -> $key, $val {
        if $key.starts-with($prefix, :ignorecase) {
            my Str $value = $val;
            $value = resolve-dir($val) if $resolve;
            @result.push(sprintf("%-20s => %s", $key, $value));
        }
    }
    for @result.sort -> $value {
        $value.say;
    }
    return True;
}

sub add-tildes(Str:D $path is copy --> Str:D) {
    $path = '~' if $path eq $home;
    $path ~~ s{^ $home '/' } = '~/';
    $path ~~ s{^ '/home/' }  = '~';
    $path ~~ s!\/$!!;
    return $path;
}

sub add-path(Str:D $key, Str:D $path --> Bool) is export {
    return False if %the-paths{$key}:exists;
    my Str $config-path = "$config/paths.p_th";
    my Str $line = sprintf "\n%-20s => %s", $key, add-tildes($path);
    $config-path.IO.spurt($line, :append);
    return True;
}

sub add-alias(Str:D $key, Str:D $target --> Bool) is export {
    return False if %the-paths{$target}:!exists;
    return add-path($key, %the-paths{$target});
}
