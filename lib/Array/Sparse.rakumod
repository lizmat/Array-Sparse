use Array::Agnostic:ver<0.0.13+>:auth<zef:lizmat>;

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

# vim: expandtab shiftwidth=4
