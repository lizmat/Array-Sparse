[![Actions Status](https://github.com/lizmat/Array-Sparse/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Array-Sparse/actions) [![Actions Status](https://github.com/lizmat/Array-Sparse/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Array-Sparse/actions) [![Actions Status](https://github.com/lizmat/Array-Sparse/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Array-Sparse/actions)

NAME
====

Array::Sparse - role for sparsely populated Arrays

SYNOPSIS
========

```raku
use Array::Sparse;

my @a is Array::Sparse;
```

DESCRIPTION
===========

Exports an `Array::Sparse` role that can be used to indicate the implementation of an array (aka `Positional`) that will not allocate anything for indexes that are not used. It also allows indexes to be used that exceed the native integer size.

Unless memory is of the most importance, if you populate more than 5% of the indexes, you will be better of just using a normal array.

Since `Array::Sparse` is a role, you can also use it as a base for creating your own custom implementations of (sparse) arrays.

Iterating Methods
=================

Methods that iterate over the sparse array, will only report elements that actually exist. This affects methods such as `.keys`, `.values`, `.pairs`, `.kv`, `.iterator`, `.head`, `.tail`, etc.

SEE ALSO
========

If the numeric values of the sparse array do **not** exceed the native integer range, then the [`Hash::int`](https://raku.land/zef:lizmat/Hash::int) may also be of interest.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Array-Sparse . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2020, 2021, 2023, 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

