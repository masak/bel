#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (lit num (+ nil (t)) (+ nil (t)))
0

> (lit num (+ (t) (t)) (+ nil (t)))
1

> (lit num (- (t) (t)) (+ nil (t)))
-1

> (lit num (+ (t t) (t)) (+ nil (t)))
2

> (lit num (+ (t) (t t)) (+ nil (t)))
1/2

> (lit num (- (t) (t t)) (+ nil (t)))
-1/2

> (lit num (+ nil (t)) (+ (t) (t)))
+i

> (lit num (+ nil (t)) (- (t) (t)))
-i

> (lit num (+ (t t) (t)) (+ (t t t) (t)))
2+3i

> (lit num (- (t t) (t)) (+ (t t t) (t)))
-2+3i

> (lit num (+ (t t) (t)) (- (t t t) (t)))
2-3i

> (lit num (- (t t) (t)) (- (t t t) (t)))
-2-3i

> (lit num (+ (t t t) (t t)) (+ (t) (t t t t)))
3/2+1/4i

> 0
0

> 1
1

> -1
-1

> 5
5

> 12
12

> +i
+i

> -i
-i

> +1i
+i

> -1i
-i

> +3i
+3i

> -4i
-4i

> 0+0i
0

> 0+i
+i

> 0+1i
+i

> 0-i
-i

> 0-1i
-i

> 1+i
1+i

> -2+1i
-2+i

> +3-2i
3-2i

> -4-i
-4-i

> 1/2
1/2

> 3/4-1/2i
3/4-1/2i

> 2/4
1/2

> -3/9
-1/3

> 0/5
0

> -0/3
0

> 2.5
5/2

> .1
1/10

> 2.5/3
5/6

> 1.2/.3
4

