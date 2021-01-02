#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s "tail")
"tail"

> (len (set names (namedups (list (append "head1" s)
                                  (append "head2" s)))))
1

> (ustring "" names)
nil

> (ustring "foo" names)
t

> (ustring \bel names)
nil

> (ustring "bel" names)
t

> (ustring s names)
nil

> (ustring "head3tail" names)
t

> (ustring (append "head4" s) names)
nil

