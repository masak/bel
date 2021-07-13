package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Compiler::Pass01 qw(
    nanopass_01_alpha
);
use Language::Bel::Compiler::Pass02 qw(
    nanopass_02_flatten
);
use Language::Bel::Compiler::Pass03 qw(
    nanopass_03_allocate_registers
);
use Language::Bel::Compiler::Generator qw(
    generate_bytefunc
);

use Exporter 'import';

sub compile {
    my ($source) = @_;

    my $_00 = read_whole($source);
    my $_01 = nanopass_01_alpha($_00);
    my $_02 = nanopass_02_flatten($_01);
    my $_03 = nanopass_03_allocate_registers($_02);

    return generate_bytefunc($_03);
}

our @EXPORT_OK = qw(
    compile
);

1;
