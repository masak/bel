package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Compiler::Pass01;
use Language::Bel::Compiler::Pass02;
use Language::Bel::Compiler::Pass03;
use Language::Bel::Compiler::Generator qw(
    generate_bytefunc
);

use Exporter 'import';

my @PASSES = (
    Language::Bel::Compiler::Pass01->new(),
    Language::Bel::Compiler::Pass02->new(),
    Language::Bel::Compiler::Pass03->new(),
);

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
