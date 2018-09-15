[![Build Status](https://travis-ci.org/lizmat/Array-Sparse.svg?branch=master)](https://travis-ci.org/lizmat/Array-Sparse)

NAME
====

Array::Sparse - class for sparsely populated Arrays

SYNOPSIS
========

    use Array::Sparse;

    my @a is Array::Sparse;

DESCRIPTION
===========

This module adds a `is sparse` trait to `Arrays`. Its only use is to provide a more memory-efficient storage for arrays that are **very** big (as in millions of potential elements) but with only a very limited of elements actually given a value (maximum about 5 %). Unless memory is of the most importance, if you populate more than 5% of the keys, you will be better of just using a normal array.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Sparse . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

