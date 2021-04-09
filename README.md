# `Language::Bel`

![CI](https://github.com/masak/bel/workflows/CI/badge.svg)

A Perl 5 implementation of Paul Graham's [Bel](http://www.paulgraham.com/bel.html).
Bel is a self-hosting Lisp dialect, released October 2019.

## Installation

You need [Perl](https://www.perl.org/get.html) installed.

Only possible to install `Language::Bel` through GitHub right now.

```sh
$ git clone https://github.com/masak/bel.git
Cloning into 'bel'...
[...]
done.
```

At some point soon, I'll also upload this distribution to CPAN.
Then you'll be able to install it using a CPAN installer, such as `cpanm`.

After downloading Bel, you can run it like this:

```sh
$ perl -Ilib bin/bel
Language::Bel 0.52 -- darwin.
>
> ;; loops
> (set n (len (apply append prims)))
16
> (each word `(there are ,n primitives) (prn word))
there
are
16
primitives
(there are 16 primitives)
>
> ;; sorting and de-duplication
> (sort < '(3 2 8 6 18 12 2 19 13 19))
(2 2 3 6 8 12 13 18 19 19)
> (dedup (sort < '(3 2 8 6 18 12 2 19 13 19)))
(2 3 6 8 12 13 18 19)
>
> ;; templates and places
> (tem vec2d x 0 y 0)
((x lit clo nil nil 0) (y lit clo nil nil 0))
> (set robot (make vec2d))
(lit tab (x . 0) (y . 0))
> robot!y
0
> (zap [+ 5 _] robot!y)
5
> robot!y
5
> (++ robot!y)
6
> ((of list robot) 'x 'y)
(0 6)
>
> ;; arrays
> (set I (array '(3 3) 0))
(lit arr (lit arr 0 0 0) (lit arr 0 0 0) (lit arr 0 0 0))
> (def diag (m n) (m n n))
(lit clo nil (m n) (m n n))
> (for n 1 3 (set (diag I n) 1))
nil
> I
(lit arr (lit arr 1 0 0) (lit arr 0 1 0) (lit arr 0 0 1))
```

## ...but is it feature-complete?

`Language::Bel` intends to be a complete implementation of the Bel spec.
It's not fully there yet, though it's under active development.

[The spec](https://github.com/masak/bel/blob/master/pg/bel.bel) contains 353 items.
`Language::Bel` currently defines 340 of them.

![340 of 353 definitions](images/definitions.svg)

A summary of the remaining big features:

* **Printer**; there's a printer written in Perl already. It's largely
  feature-complete, but just like the evaluator and reader, it's not extensible
  enough. It also doesn't handle cyclic structures and named pairs, although it
  could do that.

* **chars**; this global definition contains a very long Bel list of charater
  encodings. Although it would be feasible to build the entire list
  for millions of characters in memory (or to compromise and only build it for,
  say the Latin-1 subset or characters), probably a saner approach would be to
  generate this list on-demand. (Edit: Actually trying this reveals that it is
  too slow to be practical. Recursing down this list totally kills performance,
  and also fills the memory with pairs. It's _necessary_ to intercept the `nchar`
  and `charn` functions, and do something more efficient than a linear scan.)

## ...but is it fast?

*Make it work, make it right, make it fast.* &mdash; Kent Beck

This Bel implementation won't be usable in practice until it runs reasonably fast,
using various optimizations under the hood. Here is a brief summary:

* **Fast global lookup** (Complete, #194). A lot of time was saved in the test suite by
  turning the global lookup table into a hash under the hood.
  
* **Fast global functions** (Ongoing, #91 and #155). Instead of the interpreter
  painstakingly following the laid-down rules of Bel interpretation (and making thousands
  of function calls along the way), it can call into (manually) "pre-compiled" functions
  written in Perl (working directly against the runtime/primitives). As pointed out in
  #169, care needs to be taken when such a pre-compiled function has had a dependency
  overridden. In the fullness of time, these Perl functions shouldn't have to be created
  manually, but can be generated (ahead-of-time as well as at runtime) by a Bel compiler
  (see #106).

* **Fast numbers** (#140). Using Perl's numbers instead of building up and traversing the
  data structures in Bel. The fast functions can work directly with the numbers. If a user
  ever structurally inspects a fast number, it deoptimizes back into a plain Bel structure.

* **Fast strings** (#144). Just as with numbers, fast strings use a Perl representation
  internally. However, because strings are really just lists of characters and because
  lists can point to each other, the strings are built up as string fragments breaking at
  all the points where there could be a reference. That way, for example, strings can
  share suffixes.

* **Fast lists** (#221).

* **Backpointer-based de-optimization**.

* **A compiler**. (#106)

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like.
Pull requests are warmly welcome.

## License and copyright

This software is Copyright (c) 2019-2021 by Carl Mäsak.

This project is licensed under the GNU GPL 3.0.
For details, see [`LICENSE`](https://github.com/masak/bel/blob/master/LICENSE).
