package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Compiler::Pass::AllocateRegisters;
use Language::Bel::Compiler::Pass::Alpha;
use Language::Bel::Compiler::Pass::Flatten;
use Language::Bel::Compiler::Generator qw(
    generate_bytefunc
);

use Exporter 'import';

my @PASSES = (
    Language::Bel::Compiler::Pass::Alpha->new(),
    Language::Bel::Compiler::Pass::Flatten->new(),
    Language::Bel::Compiler::Pass::AllocateRegisters->new(),
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
