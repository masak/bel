package Language::Bel::Type::Pair;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $car, $cdr) = @_;

    my $obj = { car => $car, cdr => $cdr };
    return bless($obj, $class);
}

1;
