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

# abstract
sub translate {
    my ($self) = @_;

    my $name = $self->{name};

    die "The [$name] pass doesn't implement a 'translate' method";
}

1;
