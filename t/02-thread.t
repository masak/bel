#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (thread (+ 2 2))
4

> (do (thread 1)
      (thread (+ 2 2)))
4

> (set n 0)
0

> (do (thread
        (for i 1 10
          (++ n)))
      (thread
        (for i 1 10
          (-- n))))
!IGNORE: result of racing the two threads

> n
0

