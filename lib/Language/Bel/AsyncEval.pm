package Language::Bel::AsyncEval;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub new {
    my ($class, $expr, $denv, $cont_sub) = @_;

    my $obj = {
        expr => $expr,
        denv => $denv,
        cont_sub => $cont_sub,
    };
    return bless($obj, $class);
}

sub expr {
    my ($self) = @_;

    return $self->{expr};
}

sub denv {
    my ($self) = @_;

    return $self->{denv};
}

sub invoke_cont {
    my ($self, $value) = @_;

    return defined($self->{cont_sub})
        ? $self->{cont_sub}->($value)
        : $value;
}

sub is_async_eval {
    my ($value) = @_;

    return $value->isa(__PACKAGE__);
}

sub make_async_eval {
    my ($expr, $denv, $cont_sub) = @_;

    return __PACKAGE__->new($expr, $denv, $cont_sub);
}

our @EXPORT_OK = qw(
    is_async_eval
    make_async_eval
);

1;
