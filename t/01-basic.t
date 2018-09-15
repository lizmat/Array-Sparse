use v6.c;
use Test;

use Array::Sparse;

plan 5;

my @a is sparse= ^10;

dd @a[$_] for ^10;

dd $_ for @a;

@a[9]:delete;

dd $_ for @a;


# vim: ft=perl6 expandtab sw=4
