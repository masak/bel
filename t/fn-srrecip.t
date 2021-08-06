#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (srrecip (list '+ i1 i1))
(+ #1=(t) #1)

> (srrecip (list '+ (list t) (list t)))
(+ (t) (t))

> (srrecip (list '- i1 i1))
(- #1=(t) #1)

> (srrecip (list '- (list t) (list t)))
(- (t) (t))

> (srrecip (list '+ i0 i1))
!ERROR: mistype

> (srrecip (list '+ i2 i1))
(+ (t) (t t))

> (srrecip (list '- i2 i1))
(- (t) (t t))

> (srrecip (list '+ i1 i2))
(+ (t t) (t))

> (srrecip (list '+ i2 '(t t t)))
(+ (t t t) (t t))

> (srrecip (list '- i2 i2))
(- #1=(t t) #1)

> (srrecip (list '- (list t t) (list t t)))
(- (t t) (t t))

> (srrecip (list '+ i2 i0))
(+ nil (t t))

