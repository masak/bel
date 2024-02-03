package Language::Bel::Compiler::Pass;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    return bless({
        name => $name,
    }, $class);
}

sub translate {
    my ($self, $program) = @_;

    $self->check_precondition($program);
    my $result = $self->do_translate($program);
    $self->check_postcondition($result);

    return $result;
}

sub check_precondition {
    # do nothing by default
}

sub check_postcondition {
    # do nothing by default
}

# @abstract
sub do_translate {
    my ($self) = @_;

    my $name = $self->{name};

    die "The [$name] pass doesn't implement a 'do_translate' method";
}

1;
