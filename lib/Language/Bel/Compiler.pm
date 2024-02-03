package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Compiler::Pass::Allocate;
use Language::Bel::Compiler::Pass::Alpha;
use Language::Bel::Compiler::Pass::Flatten;
use Language::Bel::Compiler::Generator qw(
    generate_bytefunc
);

use Exporter 'import';

sub make_pass {
    my ($name) = @_;

    return "Language::Bel::Compiler::Pass::$name"->new();
}

my @PASSES = map { make_pass($_) } qw<
    Alpha
    Flatten
    Allocate
>;

sub compile {
    my ($source) = @_;

    my $program = read_whole($source);

    for my $nanopass (@PASSES) {
        $program = $nanopass->translate($program);
    }

    return generate_bytefunc($program);
}

our @EXPORT_OK = qw(
    compile
);

1;
