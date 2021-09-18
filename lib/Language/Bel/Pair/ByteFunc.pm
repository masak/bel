package Language::Bel::Pair::ByteFunc;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    SYMBOL_NIL
);
use Language::Bel::Bytecode qw(
    run_bytefunc
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

    return run_bytefunc($self->{bytes}, $self->{reg_count}, $bel, @args);
}

sub reg_count {
    my ($self) = @_;

    return $self->{reg_count};
}

sub bytes {
    my ($self) = @_;

    return $self->{bytes};
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
