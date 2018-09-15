use v6.c;
use Test;

use Array::Sparse;

plan 3;

my @a is Array::Sparse = ^10;

is @a.gist,                  "[0 1 2 3 4 5 6 7 8 9]", 'does .gist work ok';
is @a.Str,                    "0 1 2 3 4 5 6 7 8 9",  'does .Str work ok';
is @a.perl, "Array::Sparse.new(0,1,2,3,4,5,6,7,8,9)", 'does .perl work ok';

=finish

dd @a[$_] for ^10;

dd $_ for @a;

@a[9]:delete;

dd $_ for @a;

dd @a[3,5,7]:delete;

dd @a[]:v;

dd @a.keys;
dd @a.values;

# vim: ft=perl6 expandtab sw=4
