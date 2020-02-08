package Language::Bel::Globals;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    make_pair
    make_symbol
    make_fastfunc
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_QUOTE
    SYMBOL_SYMBOL
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    PRIMITIVES
);
use Language::Bel::Globals::FastFuncs qw(
    FASTFUNCS
);

use Exporter 'import';

my %globals;

sub GLOBALS {
    return \%globals;
}

$globals{"car"} = PRIMITIVES->{"car"};

$globals{"cdr"} = PRIMITIVES->{"cdr"};

$globals{"id"} = PRIMITIVES->{"id"};

$globals{"join"} = PRIMITIVES->{"join"};

$globals{"type"} = PRIMITIVES->{"type"};

$globals{"xdr"} = PRIMITIVES->{"xdr"};

$globals{"no"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("id"), make_pair(make_symbol("x"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'no'});

$globals{"atom"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("id"),
    make_pair(make_pair(make_symbol("type"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_PAIR,
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)), SYMBOL_NIL))))),
    FASTFUNCS->{'atom'});

$globals{"all"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_T, make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("all"),
    make_pair(make_symbol("f"), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL)))))), SYMBOL_NIL))))),
    FASTFUNCS->{'all'});

$globals{"some"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_symbol("xs"),
    make_pair(make_pair(make_symbol("some"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))))), SYMBOL_NIL))))),
    FASTFUNCS->{'some'});

$globals{"reduce"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_symbol("f"), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), FASTFUNCS->{'reduce'});

$globals{"cons"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_symbol("join"), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'cons'});

$globals{"append"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("append"), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("args"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("append"), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("args"), SYMBOL_NIL)), SYMBOL_NIL)))),
    SYMBOL_NIL))), SYMBOL_NIL)))))), SYMBOL_NIL))))), FASTFUNCS->{'append'});

$globals{"snoc"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("args"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL))))), FASTFUNCS->{'snoc'});

$globals{"list"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("args"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))))), FASTFUNCS->{'list'});

$globals{"map"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_symbol("ls")),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("ls"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("some"), make_pair(make_symbol("no"),
    make_pair(make_symbol("ls"), SYMBOL_NIL))), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("ls"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("ls"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("ls"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("car"),
    make_pair(make_symbol("ls"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("map"),
    make_pair(make_symbol("f"), make_pair(make_pair(make_symbol("map"),
    make_pair(make_symbol("cdr"), make_pair(make_symbol("ls"),
    SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL))), SYMBOL_NIL)))))))),
    SYMBOL_NIL))))), FASTFUNCS->{'map'});

$globals{"fn"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("parms"),
    make_symbol("body")), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("body"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("list"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("lit"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("clo"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("scope"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("parms"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("body"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("list"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("lit"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("clo"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("scope"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("parms"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("do"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))),
    SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"vmark"} =
    make_pair(SYMBOL_NIL, SYMBOL_NIL);

$globals{"uvar"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("vmark"),
    SYMBOL_NIL)), SYMBOL_NIL)))));

$globals{"do"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("fn"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL),
    make_pair(make_symbol("y"), SYMBOL_NIL)))), make_pair(make_symbol("x"),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"let"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("parms"),
    make_pair(make_symbol("val"), make_symbol("body"))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("fn"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("parms"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("val"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"macro"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("list"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("lit"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("mac"), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("fn"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("args"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"set"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("v"),
    make_pair(make_symbol("e"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("do"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("xdr"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("globe"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("cons"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("cons"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("v"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("e"),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("globe"), SYMBOL_NIL)), SYMBOL_NIL), SYMBOL_NIL)),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(SYMBOL_T, SYMBOL_NIL), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"def"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("n"),
    make_symbol("rest")), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("set"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("n"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("fn"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("rest"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"mac"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("n"),
    make_symbol("rest")), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("set"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("n"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("macro"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("rest"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"or"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("let"), make_pair(make_symbol("v"),
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("or"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL)))),
    SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"and"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"), make_pair(make_symbol("es"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_symbol("es"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("or"), make_pair(make_symbol("args"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_T,
    SYMBOL_NIL), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"="} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(SYMBOL_T,
    make_pair(make_pair(make_symbol("some"), make_pair(make_symbol("atom"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("all"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("id"), make_pair(make_symbol("_"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("cdr"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))))), SYMBOL_NIL))))), FASTFUNCS->{'='});

$globals{"symbol"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("type"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_SYMBOL,
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'symbol'});

$globals{"pair"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("type"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_PAIR,
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'pair'});

$globals{"char"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("type"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_CHAR,
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'char'});

$globals{"proper"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(SYMBOL_PAIR, make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("proper"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))))), FASTFUNCS->{'proper'});

$globals{"string"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("proper"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("all"),
    make_pair(SYMBOL_CHAR, make_pair(make_symbol("x"), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'string'});

$globals{"mem"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("ys"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("="), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("some"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("_"),
    make_pair(make_symbol("x"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("ys"), SYMBOL_NIL))), SYMBOL_NIL))))),
    FASTFUNCS->{'mem'});

$globals{"in"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), make_symbol("ys")),
    make_pair(make_pair(make_symbol("mem"), make_pair(make_symbol("x"),
    make_pair(make_symbol("ys"), SYMBOL_NIL))), SYMBOL_NIL))))),
    FASTFUNCS->{'in'});

$globals{"cadr"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), FASTFUNCS->{'cadr'});

$globals{"cddr"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), FASTFUNCS->{'cddr'});

$globals{"caddr"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), FASTFUNCS->{'caddr'});

$globals{"case"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("expr"),
    make_symbol("args")), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("let"), make_pair(make_symbol("v"),
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("expr"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("="),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_QUOTE, SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cadr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("case"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"iflet"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("var"),
    make_symbol("args")), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("let"), make_pair(make_symbol("v"),
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("var"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cadr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("iflet"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("var"), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"aif"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("iflet"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("it"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("args"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"find"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("aif"),
    make_pair(make_pair(make_symbol("some"), make_pair(make_symbol("f"),
    make_pair(make_symbol("xs"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("it"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'find'});

$globals{"begins"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("xs"), make_pair(make_symbol("pat"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("="), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("pat"),
    SYMBOL_NIL)), make_pair(SYMBOL_T,
    make_pair(make_pair(make_symbol("atom"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("begins"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)), make_pair(make_symbol("f"),
    SYMBOL_NIL)))), make_pair(SYMBOL_NIL, SYMBOL_NIL)))))))),
    SYMBOL_NIL))))), FASTFUNCS->{'begins'});

$globals{"caris"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("y"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("="), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("begins"), make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), make_pair(make_symbol("f"), SYMBOL_NIL)))),
    SYMBOL_NIL))))), FASTFUNCS->{'caris'});

$globals{"hug"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("xs"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("list"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cadr"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("hug"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_symbol("f"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))))), SYMBOL_NIL))))), FASTFUNCS->{'hug'});

$globals{"with"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("parms"),
    make_symbol("body")), make_pair(make_pair(make_symbol("let"),
    make_pair(make_symbol("ps"), make_pair(make_pair(make_symbol("hug"),
    make_pair(make_symbol("parms"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("fn"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("car"),
    make_pair(make_symbol("ps"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("cadr"),
    make_pair(make_symbol("ps"), SYMBOL_NIL))), make_pair(SYMBOL_NIL,
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL))))),
    SYMBOL_NIL)));

$globals{"keep"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("keep"),
    make_pair(make_symbol("f"), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("keep"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))))), SYMBOL_NIL))))),
    FASTFUNCS->{'keep'});

$globals{"rem"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("ys"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("="), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("keep"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("_"),
    make_pair(make_symbol("x"), SYMBOL_NIL))), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_symbol("ys"), SYMBOL_NIL))), SYMBOL_NIL))))),
    FASTFUNCS->{'rem'});

$globals{"get"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("k"), make_pair(make_symbol("kvs"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("f"),
    make_pair(make_symbol("="), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("find"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("_"),
    SYMBOL_NIL)), make_pair(make_symbol("k"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("kvs"), SYMBOL_NIL))), SYMBOL_NIL))))),
    FASTFUNCS->{'get'});

$globals{"put"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("k"), make_pair(make_symbol("v"),
    make_pair(make_symbol("kvs"), make_pair(make_pair(make_symbol("o"),
    make_pair(make_symbol("f"), make_pair(make_symbol("="), SYMBOL_NIL))),
    SYMBOL_NIL)))), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("k"),
    make_pair(make_symbol("v"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("rem"), make_pair(make_symbol("k"),
    make_pair(make_symbol("kvs"), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_symbol("y"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'put'});

$globals{"rev"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("xs"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("snoc"),
    make_pair(make_pair(make_symbol("rev"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), FASTFUNCS->{'rev'});

$globals{"snap"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("xs"), make_pair(make_symbol("ys"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("acc"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_symbol("acc"), make_pair(make_symbol("ys"),
    SYMBOL_NIL))), make_pair(make_pair(make_symbol("snap"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("ys"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("snoc"), make_pair(make_symbol("acc"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("ys"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL)))),
    SYMBOL_NIL))))), FASTFUNCS->{'snap'});

$globals{"udrop"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("xs"), make_pair(make_symbol("ys"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cadr"),
    make_pair(make_pair(make_symbol("snap"), make_pair(make_symbol("xs"),
    make_pair(make_symbol("ys"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL))))), FASTFUNCS->{'udrop'});

$globals{"idfn"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_symbol("x"), SYMBOL_NIL))))), FASTFUNCS->{'idfn'});

$globals{"is"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("_"),
    make_pair(make_symbol("x"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"literal"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("e"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("in"), make_pair(make_symbol("e"),
    make_pair(SYMBOL_T, make_pair(SYMBOL_NIL, make_pair(make_symbol("o"),
    make_pair(make_symbol("apply"), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("in"),
    make_pair(make_pair(make_symbol("type"), make_pair(make_symbol("e"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE, make_pair(SYMBOL_CHAR,
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("stream"), SYMBOL_NIL)), SYMBOL_NIL)))),
    make_pair(make_pair(make_symbol("caris"), make_pair(make_symbol("e"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("string"),
    make_pair(make_symbol("e"), SYMBOL_NIL)), SYMBOL_NIL))))),
    SYMBOL_NIL)))));

$globals{"variable"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("e"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("atom"), make_pair(make_symbol("e"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("literal"), make_pair(make_symbol("e"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("id"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("e"),
    SYMBOL_NIL)), make_pair(make_symbol("vmark"), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"isa"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("name"),
    SYMBOL_NIL), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("begins"), make_pair(make_symbol("_"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("name"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("id"), SYMBOL_NIL)))),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"function"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("find"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_pair(make_symbol("isa"),
    make_pair(make_symbol("_"), SYMBOL_NIL)), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("prim"), make_pair(make_symbol("clo"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"con"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("fn"), make_pair(make_symbol("args"),
    make_pair(make_symbol("x"), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"compose"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("g"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("or"),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("list"),
    make_pair(make_symbol("idfn"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"combine"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("op"),
    SYMBOL_NIL), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("g"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("op"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("or"),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("con"),
    make_pair(make_pair(make_symbol("op"), SYMBOL_NIL), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"cand"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("op"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"), make_pair(make_symbol("es"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_symbol("es"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("or"), make_pair(make_symbol("args"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_pair(SYMBOL_T,
    SYMBOL_NIL), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))))), SYMBOL_NIL)))), SYMBOL_NIL),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("g"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("op"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("or"),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("con"),
    make_pair(make_pair(make_symbol("op"), SYMBOL_NIL), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"cor"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("op"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("let"), make_pair(make_symbol("v"),
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("or"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL)))),
    SYMBOL_NIL))))), SYMBOL_NIL)))), SYMBOL_NIL),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("reduce"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("g"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("fn"),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("op"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_pair(make_symbol("or"),
    make_pair(make_symbol("fs"), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("con"),
    make_pair(make_pair(make_symbol("op"), SYMBOL_NIL), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"foldl"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("base"),
    make_symbol("args"))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("some"),
    make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_symbol("base"),
    make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("foldl"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("snoc"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_symbol("base"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("cdr"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), FASTFUNCS->{'foldl'});

$globals{"foldr"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("base"),
    make_symbol("args"))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("some"),
    make_pair(make_symbol("no"), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_symbol("base"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("snoc"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("foldr"), make_pair(make_symbol("f"),
    make_pair(make_symbol("base"), make_pair(make_pair(make_symbol("map"),
    make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), FASTFUNCS->{'foldr'});

$globals{"of"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("f"),
    make_pair(make_symbol("g"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("fn"), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("map"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"upon"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("_"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"pairwise"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cadr"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("pairwise"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))))), FASTFUNCS->{'pairwise'});

$globals{"fuse"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_symbol("args")),
    make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("map"),
    make_pair(make_symbol("f"), make_pair(make_symbol("args"),
    SYMBOL_NIL)))), SYMBOL_NIL))), SYMBOL_NIL))))), FASTFUNCS->{'fuse'});

$globals{"letu"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("v"),
    make_symbol("body")), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_pair(make_symbol("cor"),
    make_pair(make_symbol("variable"), make_pair(make_symbol("atom"),
    SYMBOL_NIL))), make_pair(make_symbol("v"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("with"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("fuse"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("_"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("uvar"), SYMBOL_NIL), SYMBOL_NIL)),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_symbol("v"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL))))),
    SYMBOL_NIL)));

$globals{"pcase"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("expr"),
    make_symbol("args")), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("args"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("letu"), make_pair(make_symbol("v"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("let"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("expr"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cadr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("pcase"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("v"), make_pair(make_pair(make_symbol("append"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("args"),
    SYMBOL_NIL)), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"match"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("pat"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("pat"),
    make_pair(SYMBOL_T, SYMBOL_NIL))), make_pair(SYMBOL_T,
    make_pair(make_pair(make_symbol("function"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("pat"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("or"),
    make_pair(make_pair(make_symbol("atom"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("atom"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("x"),
    make_pair(make_symbol("pat"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("match"),
    make_pair(make_pair(make_symbol("car"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("match"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("pat"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))))))), SYMBOL_NIL))))),
    FASTFUNCS->{'match'});

$globals{"split"} =
    make_fastfunc(make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("xs"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("acc"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_pair(make_symbol("cor"),
    make_pair(make_symbol("atom"),
    make_pair(make_pair(make_symbol("compose"), make_pair(make_symbol("f"),
    make_pair(make_symbol("car"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("xs"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("acc"),
    make_pair(make_symbol("xs"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("split"), make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("xs"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("snoc"),
    make_pair(make_symbol("acc"), make_pair(make_pair(make_symbol("car"),
    make_pair(make_symbol("xs"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL))))), FASTFUNCS->{'split'});

$globals{"when"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("expr"),
    make_symbol("body")), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("if"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("expr"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("do"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(SYMBOL_NIL, SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"unless"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("expr"),
    make_symbol("body")), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("when"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("no"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("expr"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_pair(make_symbol("append"),
    make_pair(make_symbol("body"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"i0"} =
    SYMBOL_NIL;

$globals{"i1"} =
    make_pair(SYMBOL_T, SYMBOL_NIL);

$globals{"i2"} =
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, SYMBOL_NIL));

$globals{"i10"} =
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, SYMBOL_NIL))))))))));

$globals{"i16"} =
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, make_pair(SYMBOL_T, make_pair(SYMBOL_T,
    make_pair(SYMBOL_T, SYMBOL_NIL))))))))))))))));

$globals{"i<"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("xs"),
    make_pair(make_symbol("ys"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cadr"),
    make_pair(make_pair(make_symbol("snap"), make_pair(make_symbol("xs"),
    make_pair(make_symbol("ys"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))));

$globals{"i+"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("apply"),
    make_pair(make_symbol("append"), make_pair(make_symbol("args"),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"i-"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), make_pair(make_symbol("y"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), make_pair(make_symbol("x"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i-"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_symbol("y"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL)))))), SYMBOL_NIL)))));

$globals{"i*"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("foldr"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("x"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("fuse"),
    make_pair(make_pair(make_symbol("con"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_symbol("y"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("i1"), make_pair(make_symbol("args"),
    SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"i/"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), make_pair(make_pair(make_symbol("o"),
    make_pair(make_symbol("q"), SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("no"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_symbol("q"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i<"), make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("q"),
    make_pair(make_symbol("x"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i/"),
    make_pair(make_pair(make_symbol("udrop"), make_pair(make_symbol("y"),
    make_pair(make_symbol("x"), SYMBOL_NIL))), make_pair(make_symbol("y"),
    make_pair(make_pair(make_symbol("i+"), make_pair(make_symbol("q"),
    make_pair(make_symbol("i1"), SYMBOL_NIL))), SYMBOL_NIL)))),
    SYMBOL_NIL)))))), SYMBOL_NIL)))));

$globals{"i^"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("foldr"), make_pair(make_symbol("i*"),
    make_pair(make_symbol("i1"), make_pair(make_pair(make_symbol("map"),
    make_pair(make_pair(make_symbol("con"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_symbol("y"), SYMBOL_NIL))), SYMBOL_NIL)))),
    SYMBOL_NIL)))));

$globals{"r+"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yn"), make_pair(make_symbol("yd"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("i+"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xd"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"r-"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yn"), make_pair(make_symbol("yd"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("let"),
    make_pair(make_pair(make_symbol("s"), make_pair(make_symbol("n"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("i-"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("list"), make_pair(make_symbol("s"),
    make_pair(make_symbol("n"), make_pair(make_pair(make_symbol("i*"),
    make_pair(make_symbol("xd"), make_pair(make_symbol("yd"), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"r*"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yn"), make_pair(make_symbol("yd"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yn"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xd"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"r/"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yn"), make_pair(make_symbol("yd"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xd"),
    make_pair(make_symbol("yn"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"srzero"} =
    make_pair(make_symbol("+"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(SYMBOL_T, SYMBOL_NIL), SYMBOL_NIL)));

$globals{"srone"} =
    make_pair(make_symbol("+"), make_pair(make_pair(SYMBOL_T, SYMBOL_NIL),
    make_pair(make_pair(SYMBOL_T, SYMBOL_NIL), SYMBOL_NIL)));

$globals{"sr+"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xs"),
    make_symbol("xr")), make_pair(make_pair(make_symbol("ys"),
    make_symbol("yr")), SYMBOL_NIL)), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("xs"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("ys"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("r+"),
    make_pair(make_symbol("xr"), make_pair(make_symbol("yr"), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_pair(make_symbol("r-"),
    make_pair(make_symbol("yr"), make_pair(make_symbol("xr"), SYMBOL_NIL))),
    SYMBOL_NIL)))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("ys"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("r-"),
    make_pair(make_symbol("xr"), make_pair(make_symbol("yr"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("r+"),
    make_pair(make_symbol("xr"), make_pair(make_symbol("yr"), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"sr-"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("sr+"), make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("srinv"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"srinv"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("s"),
    make_pair(make_symbol("n"), make_pair(make_symbol("d"), SYMBOL_NIL))),
    SYMBOL_NIL), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("s"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_pair(make_symbol("compose"),
    make_pair(make_symbol("no"), make_pair(make_symbol("="), SYMBOL_NIL))),
    make_pair(make_symbol("n"), make_pair(make_symbol("i0"), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("-"), SYMBOL_NIL)),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), SYMBOL_NIL)))), make_pair(make_symbol("n"),
    make_pair(make_symbol("d"), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"sr*"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xs"),
    make_symbol("xr")), make_pair(make_pair(make_symbol("ys"),
    make_symbol("yr")), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("xs"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("-"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("case"),
    make_pair(make_symbol("ys"), make_pair(make_symbol("-"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("-"), SYMBOL_NIL)), SYMBOL_NIL))))),
    make_pair(make_symbol("ys"), SYMBOL_NIL)))),
    make_pair(make_pair(make_symbol("r*"), make_pair(make_symbol("xr"),
    make_pair(make_symbol("yr"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"sr/"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_symbol("y"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("sr*"), make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("srrecip"), make_pair(make_symbol("y"),
    SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"srrecip"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("s"),
    make_pair(make_pair(SYMBOL_T, make_pair(make_symbol("n"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_pair(make_symbol("compose"),
    make_pair(make_symbol("no"), make_pair(make_symbol("="), SYMBOL_NIL))),
    make_pair(make_symbol("_"), make_pair(make_symbol("i0"), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), make_pair(make_symbol("d"), SYMBOL_NIL))),
    SYMBOL_NIL), make_pair(make_pair(make_symbol("list"),
    make_pair(make_symbol("s"), make_pair(make_symbol("d"),
    make_pair(make_symbol("n"), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"sr<"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xs"),
    make_pair(make_symbol("xn"), make_pair(make_symbol("xd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("ys"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("xs"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("ys"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), SYMBOL_NIL))), make_pair(make_pair(make_symbol("i<"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(SYMBOL_NIL, SYMBOL_NIL)))),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("ys"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), SYMBOL_NIL))),
    make_pair(make_pair(make_pair(make_symbol("compose"),
    make_pair(make_symbol("no"), make_pair(make_symbol("="), SYMBOL_NIL))),
    make_pair(make_symbol("xn"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("i0"), SYMBOL_NIL)))),
    make_pair(make_pair(make_symbol("i<"),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("yn"),
    make_pair(make_symbol("xd"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("i*"), make_pair(make_symbol("xn"),
    make_pair(make_symbol("yd"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"srnum"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))));

$globals{"srden"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cddr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))));

$globals{"c+"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xr"),
    make_pair(make_symbol("xi"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yr"), make_pair(make_symbol("yi"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("sr+"), make_pair(make_symbol("xr"),
    make_pair(make_symbol("yr"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("sr+"), make_pair(make_symbol("xi"),
    make_pair(make_symbol("yi"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"c*"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_pair(make_symbol("xr"),
    make_pair(make_symbol("xi"), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("yr"), make_pair(make_symbol("yi"),
    SYMBOL_NIL)), SYMBOL_NIL)), make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("sr-"),
    make_pair(make_pair(make_symbol("sr*"), make_pair(make_symbol("xr"),
    make_pair(make_symbol("yr"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("sr*"), make_pair(make_symbol("xi"),
    make_pair(make_symbol("yi"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("sr+"),
    make_pair(make_pair(make_symbol("sr*"), make_pair(make_symbol("xi"),
    make_pair(make_symbol("yr"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("sr*"), make_pair(make_symbol("xr"),
    make_pair(make_symbol("yi"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"litnum"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("i"),
    make_pair(make_symbol("srzero"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("num"), SYMBOL_NIL)), make_pair(make_symbol("r"),
    make_pair(make_symbol("i"), SYMBOL_NIL))))), SYMBOL_NIL)))));

$globals{"number"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("let"), make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("y"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("match"), make_pair(make_symbol("y"),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(make_symbol("fn"),
    make_pair(make_pair(make_symbol("_"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("in"), make_pair(make_symbol("_"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("-"), SYMBOL_NIL)), SYMBOL_NIL)))), SYMBOL_NIL))),
    make_pair(make_symbol("proper"), make_pair(make_symbol("proper"),
    SYMBOL_NIL)))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("match"), make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("num"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("r"), make_pair(make_pair(make_symbol("cons"),
    make_pair(make_symbol("r"), make_pair(SYMBOL_NIL, SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"numr"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("prim"), make_pair(make_symbol("car"),
    SYMBOL_NIL)))), make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("prim"),
    make_pair(make_symbol("car"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))));

$globals{"numi"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))));

$globals{"rpart"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("prim"), make_pair(make_symbol("car"),
    SYMBOL_NIL)))), make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("prim"),
    make_pair(make_symbol("car"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))))), make_pair(make_pair(make_symbol("f"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("i"),
    make_pair(make_symbol("srzero"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("num"), SYMBOL_NIL)), make_pair(make_symbol("r"),
    make_pair(make_symbol("i"), SYMBOL_NIL))))), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("i"),
    make_pair(make_symbol("srzero"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("num"), SYMBOL_NIL)), make_pair(make_symbol("r"),
    make_pair(make_symbol("i"), SYMBOL_NIL))))), SYMBOL_NIL))))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("prim"), make_pair(make_symbol("car"),
    SYMBOL_NIL)))), make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("prim"),
    make_pair(make_symbol("car"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL))))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))));

$globals{"ipart"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))))), make_pair(make_pair(make_symbol("f"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("i"),
    make_pair(make_symbol("srzero"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("num"), SYMBOL_NIL)), make_pair(make_symbol("r"),
    make_pair(make_symbol("i"), SYMBOL_NIL))))), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("r"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("i"),
    make_pair(make_symbol("srzero"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("list"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("lit"),
    SYMBOL_NIL)), make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("num"), SYMBOL_NIL)), make_pair(make_symbol("r"),
    make_pair(make_symbol("i"), SYMBOL_NIL))))), SYMBOL_NIL))))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(make_pair(make_pair(make_symbol("g"),
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("f"), make_pair(make_symbol("lit"),
    make_pair(make_symbol("clo"), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL)))))),
    make_pair(make_pair(make_symbol("fs"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("car"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("cdr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL))),
    SYMBOL_NIL))), make_pair(make_symbol("args"),
    make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL))))), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_symbol("args"), make_pair(make_pair(make_symbol("f"),
    make_pair(make_pair(make_symbol("apply"), make_pair(make_symbol("g"),
    make_pair(make_symbol("args"), SYMBOL_NIL))), SYMBOL_NIL)),
    SYMBOL_NIL)))));

$globals{"real"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("and"),
    make_pair(make_pair(make_symbol("number"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("="),
    make_pair(make_pair(make_symbol("numi"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), make_pair(make_symbol("srzero"), SYMBOL_NIL))),
    SYMBOL_NIL))), SYMBOL_NIL)))));

$globals{"inv"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("litnum"),
    make_pair(make_pair(make_pair(make_symbol("compose"),
    make_pair(make_symbol("srinv"), make_pair(make_symbol("numr"),
    SYMBOL_NIL))), make_pair(make_symbol("x"), SYMBOL_NIL)),
    make_pair(make_pair(make_pair(make_symbol("compose"),
    make_pair(make_symbol("srinv"), make_pair(make_symbol("numi"),
    SYMBOL_NIL))), make_pair(make_symbol("x"), SYMBOL_NIL)), SYMBOL_NIL))),
    SYMBOL_NIL)))));

$globals{"abs"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"), SYMBOL_NIL),
    make_pair(make_pair(make_symbol("litnum"),
    make_pair(make_pair(make_symbol("cons"),
    make_pair(make_pair(SYMBOL_QUOTE, make_pair(make_symbol("+"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("cdr"),
    make_pair(make_pair(make_symbol("numr"), make_pair(make_symbol("x"),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))), SYMBOL_NIL)), SYMBOL_NIL)))));

$globals{"factor"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("o"), make_pair(make_symbol("d"),
    make_pair(make_symbol("i2"), SYMBOL_NIL))), SYMBOL_NIL)),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("i<"), make_pair(make_symbol("x"),
    make_pair(make_symbol("d"), SYMBOL_NIL))), make_pair(SYMBOL_NIL,
    make_pair(make_pair(make_symbol("let"),
    make_pair(make_pair(make_symbol("q"), make_pair(make_symbol("r"),
    SYMBOL_NIL)), make_pair(make_pair(make_symbol("i/"),
    make_pair(make_symbol("x"), make_pair(make_symbol("d"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("if"),
    make_pair(make_pair(make_symbol("="), make_pair(make_symbol("r"),
    make_pair(make_symbol("i0"), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("cons"), make_pair(make_symbol("d"),
    make_pair(make_pair(make_symbol("factor"), make_pair(make_symbol("q"),
    make_pair(make_symbol("d"), SYMBOL_NIL))), SYMBOL_NIL))),
    make_pair(make_pair(make_symbol("factor"), make_pair(make_symbol("x"),
    make_pair(make_pair(make_symbol("i+"), make_pair(make_symbol("d"),
    make_pair(make_symbol("i1"), SYMBOL_NIL))), SYMBOL_NIL))),
    SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL)))), SYMBOL_NIL)))));

$globals{"err"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"), SYMBOL_NIL))));

$globals{"comma"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("err"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("comma-outside-backquote"), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"comma-at"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("err"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("comma-at-outside-backquote"), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL)));

$globals{"splice"} =
    make_pair(make_symbol("lit"), make_pair(make_symbol("mac"),
    make_pair(make_pair(make_symbol("lit"), make_pair(make_symbol("clo"),
    make_pair(SYMBOL_NIL, make_pair(make_symbol("args"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_pair(make_symbol("err"),
    make_pair(make_pair(SYMBOL_QUOTE,
    make_pair(make_symbol("comma-at-outside-list"), SYMBOL_NIL)),
    SYMBOL_NIL)), SYMBOL_NIL)), SYMBOL_NIL))))), SYMBOL_NIL)));

our @EXPORT_OK = qw(
    GLOBALS
);

1;
