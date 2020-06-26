package Language::Bel::Type::Symbol;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    my $obj = { name => $name };
    return bless($obj, $class);
}

1;
