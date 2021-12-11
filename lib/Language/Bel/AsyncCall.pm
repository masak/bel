package Language::Bel::AsyncCall;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub new {
    my ($class, $fn, $args_ref, $cont_sub) = @_;

    my $obj = {
        fn => $fn,
        args_ref => $args_ref,
        cont_sub => $cont_sub,
    };
    return bless($obj, $class);
}

sub fn {
    my ($self) = @_;

    return $self->{fn};
}

sub args_ref {
    my ($self) = @_;

    return $self->{args_ref};
}

sub invoke_cont {
    my ($self, $value) = @_;

    return $self->{cont_sub}->($value);
}

sub is_async_call {
    my ($value) = @_;

    if (!ref($value)) {
        use Carp;
        confess "undefined value in is_async_call: $value";
    }
    return $value->isa(__PACKAGE__);
}

sub make_async_call {
    my ($fn, $args_ref, $cont_sub) = @_;

    return __PACKAGE__->new($fn, $args_ref, $cont_sub);
}

our @EXPORT_OK = qw(
    is_async_call
    make_async_call
);

1;
