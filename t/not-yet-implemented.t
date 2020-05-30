#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;
use Language::Bel::NotYetImplemented;

my %list = Language::Bel::NotYetImplemented::list();

plan tests => scalar(keys(%list));

for my $feature (sort(keys(%list))) {
    my $todo_tuple = $list{$feature};
    my ($input, $expected_future_output, $expected_error) = @$todo_tuple;

    bel_todo($input, $expected_future_output, $expected_error);
}
