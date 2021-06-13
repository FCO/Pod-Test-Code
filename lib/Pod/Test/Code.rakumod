unit class Pod::Test::Code:ver<0.0.1>:auth<cpan:FCO>;
use Module::Pod;
use JSON::Fast;

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

multi test-code-snippets is export {
    my $meta = "./META6.json".IO.slurp;
    my %meta = from-json $meta;
    my @pod = %meta<provides>.keys.map: |*.&pod-from-module;
    test-code-snippets-from-pod @pod
}

multi test-code-snippets(Str $module) is export {
    test-code-snippets-from-pod pod-from-module $module
}

sub test-code-snippets-from-pod(@pod) is export {
    my @code = get-code-nodes(@pod).grep: { (.config<lang> // "").lc eq "raku" };
    @code = @code.map: -> $node {
        do given $node.config {
            when *.<lives-ok> {
                my $lives-ok= .<lives-ok> || "";
                qq:to/END/;
                lives-ok \{
                    { $node.contents.join: "" }
                \}, "$lives-ok";
                END
            }
            when *.<dies-ok> {
                my $dies-ok= .<dies-ok> || "";
                qq:to/END/;
                dies-ok \{
                    { $node.contents.join: "" }
                \}, "$dies-ok";
                END
            }
            default {
                |$node.contents
            }
        }
    }
    use MONKEY-SEE-NO-EVAL;
    EVAL qq:to/END/;
        use v6;
        use Test;
        lives-ok \{
            { @code.join: "" }
        \}, "The Pod6 code snipets live ok";
        done-testing;
    END
}

#dd get-code-nodes($=pod);
#test-code-snippets $=pod;

=begin pod

=head1 NAME

Pod::Test::Code - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

is 1, 1, "This seems to be working";

=end code

=begin code :lives-ok("testing lives ok") :lang<raku>

say "bla";

=end code

=begin code :dies-ok("testing dies ok") :lang<raku>

die "bla";

=end code

=head1 DESCRIPTION

Pod::Test::Code is ...

=head1 AUTHOR

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
