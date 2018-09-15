use v6.c;
use Test;

use Array::Sparse;

plan 5;

my @a is sparse = ^10;

dd @a[$_] for ^10;

dd $_ for @a;

@a[9]:delete;

dd $_ for @a;

dd @a[3,5,7]:delete;

dd @a[]:v;

dd @a.keys;
dd @a.values;

# vim: ft=perl6 expandtab sw=4
