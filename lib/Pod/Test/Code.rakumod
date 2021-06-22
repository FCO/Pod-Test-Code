unit class Pod::Test::Code:ver<0.0.3>:auth<cpan:FCO>;
use Module::Pod;
use JSON::Fast;
use Test::Output;

multi get-code-nodes($) { [] }

multi get-code-nodes(Pod::Block::Code $node) {
    [ $node ]
}

multi get-code-nodes(Pod::Block $node) {
    get-code-nodes $node.contents
}

multi get-code-nodes(@node) {
    [ @node.map: |*.&get-code-nodes ]
}

multi test-code-snippets(:$meta-path where .IO.f = "./META6.json") is export {
    my $meta = $meta-path.IO.slurp;
    my %meta = from-json $meta;
    my %pod = |%meta<provides>.keys.map: { $_ => .&pod-from-module.&get-code-nodes };
    test-code-snippets-from-pod %pod
}

multi test-code-snippets(Str $module) is export {
    test-code-snippets-from-pod %( $module => pod-from-module($module).&get-code-nodes )
}

sub test-code-snippets-from-pod(%pod) is export {
    chdir $*TMPDIR;
    my %tests = do for %pod.kv -> $mod, @pod {
        my @c = get-code-nodes(@pod);
        @c.map: {
            next unless .config<file>:exists && !.config<ignore>;
            my $file = $*CWD.add: .config<file> // "tmp-file";
            $file.spurt: :close, .contents.join: "";
        }
        my @code = @c.grep: {
            (.config<lang> // "").lc eq one(<raku perl6>)
            && !.config<ignore>
        }
        @code = @code.map: -> $node {
            do given $node.config {
                when *.<output> {
                    my $output-rx = do if .<output> === True {
                        rx/"#" \s* OUTPUT \s* ":" \s* (.* $$)/
                    } else {
                        .<output>.EVAL
                    }
                    my $content = $node.contents.join: "";
                    my $out = "";
                    if $content ~~ $output-rx {
                        $out = $_ with $0
                    }
                    $out = do if $out ~~ Positional {
                        $out.map(~*).join: ""
                    } else {
                        ~$out
                    }
                    $out .= raku;
                    qq:to/END/;
                    output-is -> \{
                        { $node.contents.join: "" }
                    \}, $out, "testing output";
                    END
                }
                when *.<lives-ok> {
                    my $lives-ok = .<lives-ok> || "";
                    qq:to/END/;
                    lives-ok -> \{
                        { $node.contents.join: "" }
                    \}, "$lives-ok";
                    END
                }
                when *.<dies-ok> {
                    my $dies-ok = .<dies-ok> || "";
                    qq:to/END/;
                    dies-ok \{
                        { $node.contents.join: "" }
                    \}, "$dies-ok";
                    END
                }
                when *.<subtest> {
                    my $subtest = .<subtest> || "";
                    qq:to/END/;
                    subtest \{
                        { $node.contents.join: "" }
                    \}, "$subtest";
                    END
                }
                default {
                    |$node.contents
                }
            }
        }
        $mod => @code if @code
    }
    use MONKEY-SEE-NO-EVAL;
    EVAL qq:to/END/;
        use v6;
        use Test;
        lives-ok -> \{
            ok { +%tests } > 0, "No Raku code blocks to test";\n{
                do for %tests.kv -> $mod, $test {
                    qq:to/EOT/.indent: 8;
                    subtest \{
                        $test
                    \}, "$mod"
                    EOT
                }
            }
        \}, "The Pod6 code snipets live ok";
        done-testing;
    END
}

=begin pod

=head1 NAME

Pod::Test::Code - Tests code blocks from pod

=head1 SYNOPSIS

=begin code :lang<raku> :ignore

# Your test:
use Pod::Test::Code;
test-code-snippets; # It will test all code blocks from all modules
                    # declared as `provides` on your META6.json

# or

test-code-snippets "My::Module::To::Be::Tested";

=end code

On your docs (please, take a look at L<this pod|https://github.com/FCO/Pod-Test-Code/blob/main/lib/Pod/Test/Code.rakumod#L121-L147>):

=begin code :lang<raku>

is 1, 1, "This seems to be working"; # Pod is using:
                                     # =begin code :lang<raku>

=end code

=begin code :lives-ok("testing lives ok") :lang<raku>

note "bla"; # Pod is using:
            # =begin code :lives-ok("testing lives ok") :lang<raku>

=end code

=begin code :dies-ok("testing dies ok") :lang<raku>

die "bla"; # Pod is using:
           # =begin code :dies-ok("testing dies ok") :lang<raku>

=end code

=begin code :subtest("blablabla") :lang<raku>

note "bla"; # Pod is using:
            # =begin code :subtest("blablabla") :lang<raku>

=end code

=begin code :file<test.json> :lang<json>
{ "bla": "ble" }
=end code

=begin code :lang<raku>
is "test.json".IO.slurp.chomp, q|{ "bla": "ble" }|;
=end code

=begin code :output :lang<raku>
print 42 # OUTPUT: 42
=end code

=begin code :output('rx/"# OUTPUT:" \n [ ^^ <.ws> "# " ( .*? \n ) <.ws> ]*/') :lang<raku>
say 42;
say 13;
say 3.14;

# OUTPUT:
# 42
# 13
# 3.14
=end code

=head1 DESCRIPTION

Pod::Test::Code is a way to test your pod's code

=head1 AUTHOR

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
