use v6.d;

use Array::Agnostic:ver<0.0.13>:auth<zef:lizmat>;

role Array::Sparse does Array::Agnostic {
    has %!sparse;
    has $.end = -1;

#--- Mandatory method required by Array::Agnostic ------------------------------
    method AT-POS(::?ROLE:D: Int:D $pos) is raw {
        if %!sparse.EXISTS-KEY($pos) || $pos < $!end {  # $!end cannot change
            %!sparse.AT-KEY($pos)
        }
        else {                                          # $!end will change
            Proxy.new(
                FETCH => -> $ { %!sparse.AT-KEY($pos) },
                STORE => -> $, \value is raw {
                    $!end = $pos if $pos > $!end;
                    %!sparse.ASSIGN-KEY($pos, value);
                }
            )
        }
    }

    method EXISTS-POS(::?ROLE:D: Int:D $pos) {
        %!sparse.EXISTS-KEY($pos)
    }

    method BIND-POS(::?ROLE:D: Int:D $pos, \value) is raw {
        $!end = $pos if $pos > $!end;
        %!sparse.BIND-KEY($pos,value)
    }

    method DELETE-POS(::?ROLE:D: Int:D $pos) {
        if %!sparse.EXISTS-KEY($pos) {
            if $pos == $!end {
                my \result = %!sparse.DELETE-KEY($pos);
                self!find-end;
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

    method elems(::?ROLE:D:) { $!end + 1 }

#---- Optional methods for performance -----------------------------------------

    # so we don't have to do the Proxy dance
    method ASSIGN-POS(::?ROLE:D: $pos, \value) {
        $!end = $pos if $pos > $!end;
        %!sparse.ASSIGN-KEY($pos,value)
    }

    # so we don't have to DELETE-POS everything
    method CLEAR(::?ROLE:D:) {
        %!sparse = ();
        $!end = -1;
    }

    # so we don't have to check non-existing keys
    method move-indexes-up(::?ROLE:D: $up, $start = 0 --> Nil) {
        my $elems = $.elems;   # so we don't need to fetch it all the time
        for %!sparse.keys.grep($start <= * < $elems).sort( -* ) {
            is-container(my \value = %!sparse.DELETE-KEY($_))
              ?? %!sparse.ASSIGN-KEY($_ + $up, value)
              !! %!sparse.BIND-KEY(  $_ + $up, value);
        }
        $!end += $up;          # adjust last elem
    }

    # so we don't have to check non-existing keys
    method move-indexes-down(::?ROLE:D: $down, $start = $down --> Nil) {

        # clear out all keys that are to be gone (may be missed when moving)
        %!sparse.DELETE-KEY($_) for %!sparse.keys.grep(* < $start);

        my $elems = $.elems;   # so we don't need to fetch it all the time
        for %!sparse.keys.grep($start <= * < $elems).sort( +* ) -> $from {
            my $to    = $from - $down;
            my \value = %!sparse.DELETE-KEY($from);  # something to move
            if is-container(value) {
                %!sparse.DELETE-KEY($to);            # could have been bound
                %!sparse.ASSIGN-KEY($to, value);
            }
            else {
                %!sparse.BIND-KEY($to, value);       # don't care what it was
            }
        }
        $!end -= $down;                              # adjust last elem
    }

#---- Methods with slightly different semantics --------------------------------
    method iterator(::?ROLE:D:) {
        self.values.iterator
    }
    method keys(::?ROLE:D:) {
        %!sparse.keys.map( +* ).sort
    }
    method values(::?ROLE:D:) {
        %!sparse.keys.sort( +* ).map: { %!sparse.AT-KEY($_) }
    }
    method pairs(::?ROLE:D:) {
        self.keys.map: { Pair.new($_, %!sparse.AT-KEY($_)) }
    }
    method antipairs(::?ROLE:D:) {
        self.keys.map: { Pair.new(%!sparse.AT-KEY($_), $_) }
    }

    my class KV does Iterator {
        has $.backend;
        has $.iterator;
        has $!index;

        method pull-one() is raw {
            with $!index {
                my $index = $!index;
                $!index  := Int;
                $!backend.AT-KEY($index)          # on the value now
            }
            else {
                $!index := $!iterator.pull-one    # key or IterationEnd
            }
        }
    }
    method kv(::?ROLE:D:) {
        Seq.new(KV.new(backend => %!sparse, iterator => self.keys.iterator))
    }

#---- Our own private methods --------------------------------------------------
    method !find-end(--> Nil) {
        $!end = %!sparse.elems
          ?? %!sparse.keys.map( *.Int ).max
          !! -1;
    }
}

=begin pod

=head1 NAME

Array::Sparse - role for sparsely populated Arrays

=head1 SYNOPSIS

=begin code :lang<raku>

use Array::Sparse;

my @a is Array::Sparse;

=end code

=head1 DESCRIPTION

Exports an C<Array::Sparse> role that can be used to indicate the implementation
of an array (aka Positional) that will not allocate anything for indexes that
are not used.  It also allows indexes to be used that exceed the native
integer size.

Unless memory is of the most importance, if you populate more than 5% of the
indexes, you will be better of just using a normal array.

Since C<Array::Sparse> is a role, you can also use it as a base for creating
your own custom implementations of arrays.

=head1 Iterating Methods

Methods that iterate over the sparse array, will only report elements that
actually exist.  This affects methods such as C<.keys>, C<.values>, C<.pairs>,
C<.kv>, C<.iterator>, C<.head>, C<.tail>, etc.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Array-Sparse .
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2020, 2021, 2023, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
