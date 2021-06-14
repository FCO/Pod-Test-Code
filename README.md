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

On your docs:

```raku
is 1, 1, "This seems to be working";
```

```raku
note "bla";
```

```raku
die "bla";
```

```raku
note "bla";
```

DESCRIPTION
===========

Pod::Test::Code is ...

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

