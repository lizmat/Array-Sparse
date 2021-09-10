[![Actions Status](https://github.com/lizmat/Array-Sparse/workflows/test/badge.svg)](https://github.com/lizmat/Array-Sparse/actions)

NAME
====

Array::Sparse - role for sparsely populated Arrays

SYNOPSIS
========

    use Array::Sparse;

    my @a is Array::Sparse;

DESCRIPTION
===========

Exports an `Array::Sparse` role that can be used to indicate the implementation of an array (aka Positional) that will not allocate anything for indexes that are not used. It also allows indexes to be used that exceed the native integer size.

Unless memory is of the most importance, if you populate more than 5% of the indexes, you will be better of just using a normal array.

Since `Array::Sparse` is a role, you can also use it as a base for creating your own custom implementations of arrays.

Iterating Methods
=================

Methods that iterate over the sparse array, will only report elements that actually exist. This affects methods such as `.keys`, `.values`, `.pairs`, `.kv`, `.iterator`, `.head`, `.tail`, etc.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Array-Sparse . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2020, 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

