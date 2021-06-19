[![Actions Status](https://github.com/FCO/Pod-Test-Code/workflows/test/badge.svg)](https://github.com/FCO/Pod-Test-Code/actions)

NAME
====

Pod::Test::Code - Tests code blocks from pod

SYNOPSIS
========

```raku
# Your test:
use Pod::Test::Code;
test-code-snippets; # It will test all code blocks from all modules
                    # declared as `provides` on your META6.json

# or

test-code-snippets "My::Module::To::Be::Tested";
```

On your docs (please, take a look at [this pod](https://github.com/FCO/Pod-Test-Code/blob/main/lib/Pod/Test/Code.rakumod#L121-L147)):

```raku
is 1, 1, "This seems to be working"; # Pod is using:
                                     # =begin code :lang<raku>
```

```raku
note "bla"; # Pod is using:
            # =begin code :lives-ok("testing lives ok") :lang<raku>
```

```raku
die "bla"; # Pod is using:
           # =begin code :dies-ok("testing dies ok") :lang<raku>
```

```raku
note "bla"; # Pod is using:
            # =begin code :subtest("blablabla") :lang<raku>
```

```json
{ "bla": "ble" }
```

```raku
is "test.json".IO.slurp.chomp, q|{ "bla": "ble" }|;
```

DESCRIPTION
===========

Pod::Test::Code is a way to test your pod's code

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

