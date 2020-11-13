package Language::Bel::Primitives;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    are_identical
    char_codepoint
    is_char
    is_nil
    is_pair
    is_stream
    is_symbol
    make_char
    make_pair
    make_stream
    make_symbol
    pair_car
    pair_cdr
    pair_set_car
    pair_set_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_EOF
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_STREAM
    SYMBOL_SYMBOL
    SYMBOL_T
);

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    $self = bless($self, $class);
    if (!defined($self->{output}) || ref($self->{output}) ne "CODE") {
        die "Named parameter 'output' of type CODE required";
    }
    if (!defined($self->{err}) || ref($self->{err}) ne "CODE") {
        die "Named parameter 'err' of type CODE required";
    }
    if (!defined($self->{wrb_buffer_of})) {
        $self->{wrb_buffer_of} = {
            nil => []
        };
    }
    return $self;
}

sub prim_car {
    my ($self, $object) = @_;

    if (is_nil($object)) {
        return SYMBOL_NIL;
    }
    elsif (!is_pair($object)) {
        return $self->{err}->("car-on-atom");
    }
    else {
        return pair_car($object);
    }
}

sub prim_cdr {
    my ($self, $object) = @_;

    if (is_nil($object)) {
        return SYMBOL_NIL;
    }
    elsif (!is_pair($object)) {
        return $self->{err}->("cdr-on-atom");
    }
    else {
        return pair_cdr($object);
    }
}

sub prim_cls {
    my ($self, $stream) = @_;

    if (is_stream($stream)) {
        $stream->close();
        return $stream;
    }
    else {
        return $self->{err}->("mistype");
    }
}

sub prim_coin {
    return rand() < 0.5
        ? SYMBOL_NIL
        : SYMBOL_T;
}

sub prim_id {
    my ($self, $first, $second) = @_;

    return are_identical($first, $second) ? SYMBOL_T : SYMBOL_NIL;
}

sub prim_join {
    my ($self, $first, $second) = @_;

    return make_pair($first, $second);
}

sub prim_nom {
    my ($self, $value) = @_;

    if (is_symbol($value)) {
        my $result = SYMBOL_NIL;
        for my $char (reverse(split //, symbol_name($value))) {
            $result = make_pair(
                make_char(ord($char)),
                $result,
            );
        }
        return $result;
    }
    else {
        return $self->{err}->("mistype");
    }
}

sub prim_ops {
    my ($self, $path, $mode) = @_;

    my @stack;
    while (is_pair($path)) {
        my $elem = pair_car($path);
        return $self->{err}->("mistype")
            unless is_char($elem);
        push @stack, chr(char_codepoint($elem));
        $path = pair_cdr($path);
    }
    if (!is_nil($path)) {
        return $self->{err}->("mistype");
    }
    else {
        my $path_str = join("", @stack);

        if (is_symbol($mode) &&
            (symbol_name($mode) eq "in" || symbol_name($mode) eq "out")) {
            return make_stream($path_str, $mode);
        }
        else {
            return $self->{err}->("mistype");
        }
    }

    return SYMBOL_NIL;
}

my $CHAR_0 = make_char(ord("0"));
my $CHAR_1 = make_char(ord("1"));

sub prim_rdb {
    my ($self, $stream) = @_;

    die "'mistype\n"
        unless is_nil($stream) || is_stream($stream);
    die "XXX: can't handle nil stream just yet"
        if is_nil($stream);
    die "'badmode\n"
        if is_stream($stream) && $stream->mode() ne "in";

    my $rdb_buffer = is_nil($stream)
        ? $self->{rdb_buffer_of}{nil}
        : ($self->{rdb_buffer_of}{$stream} ||= []);
    if (@{$rdb_buffer} == 0) {
        my $chr = $stream->read_char();
        if (length($chr) == 0) {
            return SYMBOL_EOF;
        }
        for my $bit (split("", sprintf("%08b", ord($chr)))) {
            push(@{$rdb_buffer}, $bit eq "1" ? $CHAR_1 : $CHAR_0);
        }
    }

    my $bit = shift(@{$rdb_buffer});
    return $bit;
}

sub prim_stat {
    my ($self, $stream) = @_;

    die "'mistype\n"
        unless is_stream($stream);

    return make_symbol($stream->stat());
}

sub prim_sym {
    my ($self, $value) = @_;

    my @stack;
    while (is_pair($value)) {
        my $elem = pair_car($value);
        die "not-a-string"
            unless is_char($elem);
        push @stack, chr(char_codepoint($elem));
        $value = pair_cdr($value);
    }
    die "not-a-string"
        unless is_nil($value);

    my $name = join("", @stack);
    return make_symbol($name);
}

sub prim_type {
    my ($self, $value) = @_;

    if (is_symbol($value)) {
        return SYMBOL_SYMBOL;
    }
    elsif (is_pair($value)) {
        return SYMBOL_PAIR;
    }
    elsif (is_char($value)) {
        return SYMBOL_CHAR;
    }
    elsif (is_stream($value)) {
        return SYMBOL_STREAM;
    }
    else {
        die "unknown type";
    }
}

sub prim_wrb {
    my ($self, $bit, $stream) = @_;

    my $codepoint;
    die "'mistype\n"
        unless is_char($bit)
            && ($codepoint = char_codepoint($bit)) == ord("0")
                || $codepoint == ord("1");
    die "'mistype\n"
        unless is_nil($stream) || is_stream($stream);
    die "'badmode\n"
        if is_stream($stream) && $stream->mode() ne "out";

    my $n = is_char($bit) && $codepoint eq ord("1") ? 1 : 0;
    my $wrb_buffer = is_nil($stream)
        ? $self->{wrb_buffer_of}{nil}
        : ($self->{wrb_buffer_of}{$stream} ||= []);
    push(@{$wrb_buffer}, $n);
    # XXX: Turn this into a real Unicode check, not just `8`
    if (@{$wrb_buffer} == 8) {
        my $bits = "0b" . (join "", @{$wrb_buffer});
        my $ord = oct($bits);  # yes, you can use `oct` to convert binary to decimal
        my $chr = chr($ord);
        if (is_nil($stream)) {
            $self->{output}->($chr);
        }
        else {  # stream
            $stream->write_char($chr);
        }
        @{$wrb_buffer} = ();
    }
    return $bit;
}

sub prim_xar {
    my ($self, $object, $a_value) = @_;

    if (!is_pair($object)) {
        die "xar-on-atom\n";
    }
    pair_set_car($object, $a_value);
    return $a_value;
}

sub prim_xdr {
    my ($self, $object, $d_value) = @_;

    if (!is_pair($object)) {
        die "xdr-on-atom\n";
    }
    pair_set_cdr($object, $d_value);
    return $d_value;
}

sub all_primitives {
    my ($class) = @_;

    return qw(car cdr cls coin id join nom ops rdb stat sym type wrb xar xdr);
}

# (def applyprim (f args s r m)
#   (aif (some [mem f _] prims)
#        (if (udrop (cdr it) args)
#            (sigerr 'overargs s r m)
#            (with (a (car args)
#                   b (cadr args))
#              (eif v (case f
#                       id   (id a b)
#                       join (join a b)
#                       car  (car a)
#                       cdr  (cdr a)
#                       type (type a)
#                       xar  (xar a b)
#                       xdr  (xdr a b)
#                       sym  (sym a)
#                       nom  (nom a)
#                       wrb  (wrb a b)
#                       rdb  (rdb a)
#                       ops  (ops a b)
#                       cls  (cls a)
#                       stat (stat a)
#                       coin (coin)
#                       sys  (sys a))
#                     (sigerr v s r m)
#                     (mev s (cons v r) m))))
#        (sigerr 'unknown-prim s r m)))
sub call {
    my ($self, $name, $_a, $_b) = @_;

    if ($name eq "id") {
        return $self->prim_id($_a, $_b);
    }
    elsif ($name eq "join") {
        return $self->prim_join($_a, $_b);
    }
    elsif ($name eq "car") {
        return $self->prim_car($_a);
    }
    elsif ($name eq "cdr") {
        return $self->prim_cdr($_a);
    }
    elsif ($name eq "type") {
        return $self->prim_type($_a);
    }
    elsif ($name eq "xar") {
        return $self->prim_xar($_a, $_b);
    }
    elsif ($name eq "xdr") {
        return $self->prim_xdr($_a, $_b);
    }
    elsif ($name eq "sym") {
        return $self->prim_sym($_a);
    }
    elsif ($name eq "nom") {
        return $self->prim_nom($_a);
    }
    elsif ($name eq "wrb") {
        return $self->prim_wrb($_a, $_b);
    }
    elsif ($name eq "rdb") {
        return $self->prim_rdb($_a);
    }
    elsif ($name eq "ops") {
        return $self->prim_ops($_a, $_b);
    }
    elsif ($name eq "cls") {
        return $self->prim_cls($_a);
    }
    elsif ($name eq "stat") {
        return $self->prim_stat($_a);
    }
    elsif ($name eq "coin") {
        return $self->prim_coin();
    }
    # XXX: skipping 'sys'
    else {
        # XXX: skipping the 'unknown-prim case for now
        die "unknown-prim\n";
    }
    # XXX: skipping the `sigerr` case
}

1;
