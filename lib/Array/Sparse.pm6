use v6.c;

use Array::Agnostic;

class Array::Sparse:ver<0.0.1>:auth<cpan:ELIZABETH> does Array::Agnostic {
    has %!sparse;
    has $.end = -1;

    method AT-POS(int $pos) is raw {
        $!end = $pos if $pos > $!end;
        %!sparse.AT-KEY($pos)
    }

    method EXISTS-POS(Int:D $pos) {
        %!sparse.EXISTS-KEY($pos)
    }

    method ASSIGN-POS(Int:D $pos, \value) is raw {
        $!end = $pos if $pos > $!end;
        %!sparse.ASSIGN-KEY($pos,value)
    }

    method BIND-POS(Int:D $pos, \value) is raw {
        $!end = $pos if $pos > $!end;
        %!sparse.BIND-KEY($pos,value)
    }

    method DELETE-POS(Int:D $pos) {
        if %!sparse.EXISTS-KEY($pos) {
            if $pos == $!end {
                my \result = %!sparse.DELETE-KEY($pos);
                $!end = %!sparse.elems
                  ?? %!sparse.keys.map( *.Int ).max
                  !! -1;
                result
            }
            else {
                %!sparse.DELETE-KEY($pos);
            }
        }
        else {
            Nil
        }
    }

    method CLEAR() {
        %!sparse = ();
        $!end = -1;
    }

    method STORE(*@values, :$initialize) {
        self.CLEAR unless $initialize;
        $!end = @values - 1;

        %!sparse.ASSIGN-KEY($_,@values.AT-POS($_)) for 0 .. $!end;
        self;
    }

    my class Iterate does Iterator {
        has %.sparse;
        has $.end;
        has $.index = -1;

        method pull-one() is raw {
            $!index < $!end
              ?? %!sparse.AT-KEY(++$!index)
              !! IterationEnd
        }
    }
    method iterator() { Iterate.new( :%!sparse, :$!end ) }

    method elems() { $!end + 1 }
}

=begin pod

=head1 NAME

Array::Sparse - class for sparsely populated Arrays

=head1 SYNOPSIS

  use Array::Sparse;

  my @a is Array::Sparse;

=head1 DESCRIPTION

This module adds a C<is sparse> trait to C<Arrays>.  Its only use is to
provide a more memory-efficient storage for arrays that are B<very> big
(as in millions of potential elements) but with only a very limited of
elements actually given a value (maximum about 5 %).  Unless memory is
of the most importance, if you populate more than 5% of the keys, you will
be better of just using a normal array.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Sparse .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
