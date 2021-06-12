package Language::Bel::Pair::ByteFunc;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_nil
    SYMBOL_NIL
    SYMBOL_T
);
use Exporter 'import';

sub new {
    my ($class, $reg_count, $bytes) = @_;

    my $obj = {
        reg_count => $reg_count,
        bytes => $bytes,
    };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub cdr {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub xar {
    my ($self, $car) = @_;

    die "Attempted to modify a bytefunc\n";
}

sub xdr {
    my ($self, $cdr) = @_;

    die "Attempted to modify a bytefunc\n";
}

sub apply {
    my ($self, $bel, @args) = @_;

    my $first = @args > 0 ? $args[0] : SYMBOL_NIL;
    return is_nil($first) ? SYMBOL_T : SYMBOL_NIL;
}

sub is_bytefunc {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_bytefunc {
    my ($regcount, $bytes) = @_;

    return __PACKAGE__->new($regcount, $bytes);
}

our @EXPORT_OK = qw(
    is_bytefunc
    make_bytefunc
);

1;
