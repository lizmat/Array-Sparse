use v6.c;

# Since we cannot export a proto sub trait_mod:<is> with "is export", we
# need to do this manually with an EXPORT sub.  So we create a hash here
# to be set in compilation of the mainline and then return that in the
# EXPORT sub.
my %EXPORT;

# Save the original trait_mod:<is> candidates, so we can pass on through
# all of the trait_mod:<is>'s that cannot be handled here.
BEGIN my $original_trait_mod_is = &trait_mod:<is>;

module Array::Sparse:ver<0.0.1>:auth<cpan:ELIZABETH> {

    role sparse[::TYPE = Mu] {
        has %!sparse;
        has $.end;

        submethod TWEAK() {
            %!sparse := TYPE =:= Mu ?? Hash.new !! Hash[TYPE].new;
            $!end = -1;
        }

        method AT-POS(Int:D $pos) is raw {
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

        method STORE(*@values, :$initialize) {
            %!sparse := %!sparse.WHAT.new unless $initialize;
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

        method append(|) { ... }
        method prepend(|) { ... }
        method push(|) { ... }
        method unshift(|) { ... }
        method splice(|) { ... }

        method !find-end() {
            $!end = %!sparse.elems
              ?? %!sparse.keys.map( *.Int ).max
              !! -1
        }
    }

    # Manually mark this proto for export
    %EXPORT<&trait_mod:<is>> := proto sub trait_mod:<is>(|) {*}

    # Handle the "is sparse" / is sparse(Type) cases
    multi sub trait_mod:<is>(Variable:D \v, :$sparse!) {
        my $name = v.var.name;

        if $sparse ~~ Bool && $sparse {
            trait_mod:<does>(v, sparse);
            v.var.WHAT.^set_name("$name\[sparse]");
        }
        else {  # assume type
            trait_mod:<does>(v, sparse[$sparse<>]);
            v.var.WHAT.^set_name("$name\[{$sparse.^name},sparse]");
        }
    }

    # Make sure we handle all of the standard traits correctly
    multi sub trait_mod:<is>(|c) { $original_trait_mod_is(|c) }
}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Array::Sparse - add "is sparse" trait to Arrays

=head1 SYNOPSIS

  use Array::Sparse;

  my @a is sparse;       # any type of value

  my @a is sparse(Str);  # only allow strings as values

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
